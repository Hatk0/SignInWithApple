import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}

@MainActor
class BaseCoordinator: @preconcurrency Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        fatalError("Start should be implemented by child")
    }
    
    func store(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    func free(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}
