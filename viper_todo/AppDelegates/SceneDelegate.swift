
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private lazy var coreDataStack: CoreDataStack = .shared

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)

        let taskListVC = TaskListModuleAssemler().assembly()
        let navigationController = UINavigationController(rootViewController: taskListVC)

        window.rootViewController = navigationController

        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        coreDataStack.saveContext()
    }


}

