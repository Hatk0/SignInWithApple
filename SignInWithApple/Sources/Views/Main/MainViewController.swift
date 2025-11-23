import UIKit

class MainViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: MainCoordinator?
    
    // MARK: - UI
    
    private lazy var signOutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Out", for: .normal)
        button.addTarget(self, action: #selector(signOutTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupHierarchy()
        setupLayout()
        
        if let user = AuthManager.shared.currentUser {
            print("User: \(user.fullName ?? "No name"), email: \(user.email ?? "No email")")
        }
    }
    
    // MARK: - Setup
    
    private func setupView() {
        title = "Budget Planner"
        view.backgroundColor = .systemBackground
    }
    
    private func setupHierarchy() {
        view.addSubview(signOutButton)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate(
            [
                signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                signOutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ]
        )
    }
    
    // MARK: - Actions
    
    @objc private func signOutTapped() {
        coordinator?.signOut()
    }
}
