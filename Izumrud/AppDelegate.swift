//
//  AppDelegate.swift
//  Izumrud
//
//  Created by Sergey Balalaev on 19.07.2020.
//  Copyright © 2020 Byterix. All rights reserved.
//

import UIKit
import CircularSpinner
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {

        UIView.appearance().tintColor = Settings.Color.brand
        CircularSpinner.trackPgColor = Settings.Color.brand
        //CircularSpinner.trackBgColor = Settings.Color.brand.withAlphaComponent(0.2)
        
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: Settings.Color.brand]
        
        print(DatabaseManager.documentDirectoryURL.path)
        let _ = DatabaseManager.shared
        
        window?.makeKey()
        
        return true
    }

    // deep link
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if url.host == "presentation" {
            if url.path == "/newFlatCounters" {
                if let rootController = NavigationUtils.tabBarController {
                    let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
                    let viewController = FlatCountersDetailsController()
                    let navigationController = UINavigationController(rootViewController: viewController)
                    let flatCountersController: HistoryTableController? = NavigationUtils.findController()
                    NavigationRoute.newFlatCounters(for: viewController, root: flatCountersController, components: components)
                    rootController.present(navigationController, animated: true)
                }
            }
        } else if url.host == "navigation" {
            if url.path == "/flatCounters/new" {
                if let rootController: HistoryTableController = NavigationUtils.findController() {
                    let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
                    let viewController = FlatCountersDetailsController()
                    NavigationRoute.newFlatCounters(for: viewController, root: rootController, components: components)
                    rootController.navigationController?.popToRootViewController(animated: false)
                    rootController.navigationController?.pushViewController(viewController, animated: false)
                    NavigationUtils.openTab(with: rootController)
                }
            }
        }
        return true
    }

    // universal link
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool
    {
        return true
    }

}

