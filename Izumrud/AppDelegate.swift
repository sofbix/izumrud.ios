//
//  AppDelegate.swift
//  Izumrud
//
//  Created by Sergey Balalaev on 19.07.2020.
//  Copyright © 2020 Byterix. All rights reserved.
//

import UIKit
import CircularSpinner

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {

        UIView.appearance().tintColor = Settings.Color.brand
        CircularSpinner.trackPgColor = Settings.Color.brand
        //CircularSpinner.trackBgColor = Settings.Color.brand.withAlphaComponent(0.2)
        
        print(DatabaseManager.documentDirectoryURL.path)
        let _ = DatabaseManager.shared
        
        window?.makeKey()
        
        return true
    }


}

