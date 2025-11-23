import UIKit

class MainViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: MainCoordinator?
    
    // MARK: - UI
    
    private lazy var userInfoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
        
        displayUserData()
    }
    
    private func setupHierarchy() {
        view.addSubview(userInfoLabel)
        view.addSubview(signOutButton)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate(
            [
                userInfoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                userInfoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                userInfoLabel.bottomAnchor.constraint(equalTo: signOutButton.topAnchor, constant: -20),
                
                signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                signOutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ]
        )
    }
    
    // MARK: - Private Methods
    
    private func displayUserData() {
        guard let user = AuthManager.shared.currentUser else {
            userInfoLabel.text = "No user signed in"
            return
        }
        
        let fullName = user.fullName ?? "No name"
        let email = user.email ?? "No email"
        
        userInfoLabel.text = "Name: \(fullName)\nEmail: \(email)"
    }
    
    // MARK: - Actions
    
    @objc private func signOutTapped() {
        coordinator?.signOut()
    }
}
