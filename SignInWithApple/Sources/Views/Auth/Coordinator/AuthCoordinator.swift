import UIKit

@MainActor
final class AuthCoordinator: BaseCoordinator {
    
    // MARK: - Callbacks
    
    var onSignInComplete: (() -> Void)?
    
    // MARK: - Public Methods
    
    override func start() {
        let signInViewController = SignInViewController()
        signInViewController.coordinator = self
        navigationController.setViewControllers([signInViewController], animated: false)
    }
    
    func userDidSignIn() {
        onSignInComplete?()
    }
}
