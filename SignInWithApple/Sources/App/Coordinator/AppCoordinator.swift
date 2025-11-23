import UIKit

@MainActor
final class AppCoordinator: BaseCoordinator {
    
    // MARK: - Properties
    
    private let authManager = AuthManager.shared
    
    // MARK: - Public Methods
    
    override func start() {
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let isAuthorized = try await self.authManager.checkAuthorizationState()
                
                if isAuthorized {
                    self.showMainApp()
                } else {
                    self.showAuth()
                }
                
                self.subscribeToAuthChanges()
                
            } catch {
                print("Auth state check failed: \(error)")
                self.showAuth()
                self.subscribeToAuthChanges()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func showAuth() {
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        authCoordinator.onSignInComplete = { [weak self] in
            self?.showMainApp()
        }
        store(authCoordinator)
        authCoordinator.start()
    }
    
    private func showMainApp() {
        let mainCoordinator = MainCoordinator(navigationController: navigationController)
        mainCoordinator.onSignOut = { [weak self] in
            self?.resetAppToAuth()
        }
        store(mainCoordinator)
        mainCoordinator.start()
    }
    
    private func resetAppToAuth() {
        childCoordinators.removeAll()
        navigationController.setViewControllers([], animated: false)

        showAuth()
    }
    
    private func subscribeToAuthChanges() {
        authManager.onAuthStateChanged = { [weak self] isAuthorized in
            if !isAuthorized {
                self?.showAuth()
            }
        }
    }
}
