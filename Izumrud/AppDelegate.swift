//
//  AppDelegate.swift
//  Izumrud
//
//  Created by Sergey Balalaev on 19.07.2020.
//  Copyright © 2020 Byterix. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        
        print(DatabaseManager.documentDirectoryURL.path)
        let _ = DatabaseManager.shared
        
        window?.makeKey()
        
        return true
    }


}

