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
        if url.host == "app" {

            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                return true
            }

            if url.path == "/newFlatCounters" {
                //
            } else if url.path == "/flatCounters/new" {
                if let rootController: HistoryTableController = NavigationUtils.findController() {
                    NavigationUtils.openTab(with: rootController)
                    let viewController = FlatCountersDetailsController()
                    viewController.isEditing = true
                    viewController.title = "Новые показания"
                    viewController.newBranchHandler = {
                        rootController.refresh()
                    }
                    rootController.navigationController?.pushViewController(viewController, animated: true)
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

