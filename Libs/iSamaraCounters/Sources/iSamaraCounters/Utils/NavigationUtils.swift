//
//  NavigationUtils.swift
//  Izumrud
//
//  Created by Sergey Balalaev on 05.05.2023.
//  Copyright © 2023 Byterix. All rights reserved.
//

import UIKit

struct NavigationUtils {

    static var firstWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared
                .connectedScenes.lazy
                .compactMap { $0 as? UIWindowScene }
                .flatMap(\.windows)
                .first(where: \.isKeyWindow)
        } else {
            return UIApplication.shared.keyWindow
        }
    }

    static var rootController: UIViewController? {
        firstWindow?.rootViewController
    }

    static func findController<T: UIViewController>(viewController: UIViewController? = rootController) -> T? {
        guard let viewController = viewController else {
            return nil
        }

        if let tabBarController = viewController as? T {
            return tabBarController
        }

        for childViewController in viewController.children {
            return findController(viewController: childViewController)
        }

        return nil
    }

    static var navigationController: UINavigationController? {
        findController()
    }

    static var tabBarController: UITabBarController? {
        findController()
    }

    static func openTab(with rootController: UIViewController) {
        guard let tabBarController = self.tabBarController else {
            return
        }
        guard let index = tabBarController.viewControllers?.firstIndex(where: { findController in
            return (findController as? UINavigationController)?.viewControllers.first === rootController
        }) else {
            return
        }
        tabBarController.selectedIndex = index
    }

}
