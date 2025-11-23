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
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.addTarget(self, action: #selector(signOutTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var deleteAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete Account", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.addTarget(self, action: #selector(deleteAccountTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [signOutButton, deleteAccountButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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
        view.addSubview(buttonStackView)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate(
            [
                userInfoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                userInfoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                userInfoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
                
                buttonStackView.topAnchor.constraint(equalTo: userInfoLabel.bottomAnchor, constant: 40),
                buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
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
        let alert = UIAlertController(
            title: "Sign Out",
            message: "Are you sure you want to sign out?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .default) { [weak self] _ in
            self?.coordinator?.signOut()
        })
        
        present(alert, animated: true)
    }
    
    @objc private func deleteAccountTapped() {
        let alert = UIAlertController(
            title: "Delete Account",
            message: "Are you sure you want to delete your account? This action cannot be undone. All your data will be permanently deleted.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(
            UIAlertAction(
                title: "Delete",
                style: .destructive
            ) { [weak self] _ in
                self?.coordinator?.deleteAccount()
            }
        )
        
        present(alert, animated: true)
    }
}
