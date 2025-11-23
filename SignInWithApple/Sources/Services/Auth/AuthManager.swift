import AuthenticationServices

final class AuthManager {
    
    // MARK: - Singleton
    
    static let shared = AuthManager()
    
    // MARK: - Properties
    
    private let userDefaults = UserDefaults.standard
    private let userKey = "user_data"
    private let userIDKey = "user_id"
    
    private(set) var currentUser: User? {
        didSet {
            saveNonSensitiveUser()
            notifyAuthStateChanged()
        }
    }
    
    var isAuthorized: Bool {
        (try? KeychainManager.shared.load(for: userIDKey)) != nil
    }
    
    // MARK: - Callbacks
    
    var onAuthStateChanged: ((Bool) -> Void)?
    
    // MARK: - Initializers
    
    private init() {
        loadUser()
    }
    
    // MARK: - Public Methods
    
    func signIn(with creditential: ASAuthorizationAppleIDCredential) {
        let userId = creditential.user
        let email = creditential.email ?? currentUser?.email
        let fullName = [creditential.fullName?.givenName, creditential.fullName?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")
        
        let user = User(
            id: userId,
            email: email,
            fullName: fullName.isEmpty ? currentUser?.fullName : fullName
        )
        currentUser = user
        
        do {
            try KeychainManager.shared.save(Data(userId.utf8), for: userIDKey)
        } catch {
            print("[AuthManager] Failed to save userID to Keychain: \(error)")
        }
    }
    
    func signOut() {
        currentUser = nil
        userDefaults.removeObject(forKey: userKey)
        do {
            try KeychainManager.shared.delete(for: userIDKey)
        } catch {
            print("[AuthManager] Failed to delete userID from Keychain: \(error)")
        }
    }
    
    @MainActor
    func checkAuthorizationState() async throws -> Bool {
        guard let userIdData = try KeychainManager.shared.load(for: userIDKey),
              let userId = String(data: userIdData, encoding: .utf8) else {
            return false
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let provider = ASAuthorizationAppleIDProvider()
            provider.getCredentialState(forUserID: userId) { [weak self] state, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                switch state {
                case .authorized:
                    continuation.resume(returning: true)
                case .revoked, .notFound:
                    self?.signOut()
                    continuation.resume(returning: false)
                default:
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func loadUser() {
        guard let data = userDefaults.data(forKey: userKey),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            currentUser = nil
            return
        }
        
        currentUser = user
    }
    
    private func saveNonSensitiveUser() {
        guard let user = currentUser,
              let data = try? JSONEncoder().encode(user) else { return }
        userDefaults.set(data, forKey: userKey)
    }
    
    private func notifyAuthStateChanged() {
        onAuthStateChanged?(isAuthorized)
        NotificationCenter.default.post(name: .authStateDidChange, object: isAuthorized)
    }
}
