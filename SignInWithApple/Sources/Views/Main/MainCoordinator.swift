import UIKit

@MainActor
final class MainCoordinator: BaseCoordinator {
    
    // MARK: - Callbacks
    
    var onSignOut: (() -> Void)?
    
    // MARK: - Public Methods
    
    override func start() {
        let mainViewController = MainViewController()
        mainViewController.coordinator = self
        navigationController.setViewControllers([mainViewController], animated: true)
    }
    
    func signOut() {
        AuthManager.shared.signOut()
        onSignOut?()
    }
}
