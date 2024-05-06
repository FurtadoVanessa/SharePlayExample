import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let customView = OrderTogetherView()
        let model = OrderTogetherModel(shoppingBag: ShoppingBag(id: "id", items: []))
        let viewController = OrderTogetherViewController(orderTogetherModel: model, customView: customView)
        model.delegate = viewController
        
        customView.setupDelegatesAndDataSources(dataSourceDelegate: viewController, textFieldDelegate: viewController, delegate: viewController)
        viewController.isModalInPresentation = false
        
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.isModalInPresentation = false
        navigationController.setNavigationBarHidden(true, animated: false)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }

    var orientationLock = UIInterfaceOrientationMask.all

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
            return self.orientationLock
    }
}
