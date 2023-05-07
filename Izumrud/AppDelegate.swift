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

        if let activityDictionary = launchOptions?[UIApplication.LaunchOptionsKey.userActivityDictionary] as? [AnyHashable: Any],
            let userActivity = activityDictionary ["UIApplicationLaunchOptionsUserActivityKey"] as? NSUserActivity ?? nil
        {
            handleUniversalUrl(userActivity: userActivity)
        }
        
        return true
    }

    // deep link
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        guard url.host == "app" else {
            return true
        }
        handle(with: url)
        return true
    }

    // universal link
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool
    {
        return handleUniversalUrl(userActivity: userActivity)
    }

    @discardableResult
    private func handleUniversalUrl(userActivity: NSUserActivity) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL,
              url.host == "byterix.com"
        else {
            return false
        }
        handle(with: url)
        return true
    }

    private func handle(with url: URL) {
        if url.path.hasSuffix("/presentation/newFlatCounters"){
            NavigationRoute.openPresentationNewFlatCounters(url: url)
        } else if url.path.hasSuffix("/navigation/flatCounters/new"){
            NavigationRoute.openNavigationNewFlatCounters(url: url)
        }
    }

}

