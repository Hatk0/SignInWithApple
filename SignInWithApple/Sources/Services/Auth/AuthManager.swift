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
    
    func signIn(with credential: ASAuthorizationAppleIDCredential) {
        let userId = credential.user
        let email = credential.email ?? currentUser?.email
        let fullName = getFullName(from: credential)
        
        let user = User(
            id: userId,
            email: email,
            fullName: fullName
        )
        currentUser = user
        
        do {
            try KeychainManager.shared.save(Data(userId.utf8), for: userIDKey)
        } catch {
            print("[AuthManager] Failed to save userID to Keychain: \(error)")
        }
    }
    
    func signOut() {
        try? KeychainManager.shared.delete(for: userIDKey)
        
        notifyAuthStateChanged()
    }
    
    func deleteAccount() {
        currentUser = nil
        userDefaults.removeObject(forKey: userKey)
        try? KeychainManager.shared.delete(for: userIDKey)
        notifyAuthStateChanged()
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
                if let error {
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
    
    private func getFullName(from credential: ASAuthorizationAppleIDCredential) -> String? {
        if let givenName = credential.fullName?.givenName,
           let familyName = credential.fullName?.familyName {
            return "\(givenName) \(familyName)"
        }
        
        if let givenName = credential.fullName?.givenName {
            return givenName
        }
        
        return currentUser?.fullName
    }
    
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
