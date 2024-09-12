import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let viewModel = PhotoSearchViewModel()
        let viewController = PhotoSearchViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        
        window = UIWindow()
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }
}

