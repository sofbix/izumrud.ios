//
//  NavigationRoute.swift
//  Izumrud
//
//  Created by Sergey Balalaev on 05.05.2023.
//  Copyright © 2023 Byterix. All rights reserved.
//

import UIKit

struct NavigationRoute {

    static func newFlatCounters(for viewController: FlatCountersDetailsController,
                                root historyController: HistoryTableController? = nil,
                                url: URL? = nil)
    {
        viewController.isEditing = true
        viewController.title = "Новые показания"
        if  let url,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems
        {
            viewController.fields = queryItems.reduce(into:[String: String]()) { result, component in
                if let value = component.value, !value.isEmpty {
                    result[component.name] = value
                }
            }
        }
        viewController.newBranchHandler = {[weak historyController] in
            historyController?.refresh()
        }
    }

    static func openNavigationNewFlatCounters(url: URL) {
        if let rootController: HistoryTableController = NavigationUtils.findController() {
            let viewController = FlatCountersDetailsController()
            newFlatCounters(for: viewController, root: rootController, url: url)
            rootController.navigationController?.popToRootViewController(animated: false)
            rootController.navigationController?.pushViewController(viewController, animated: false)
            NavigationUtils.openTab(with: rootController)
        }
    }

    static func openPresentationNewFlatCounters(url: URL) {
        if let rootController = NavigationUtils.tabBarController {
            let viewController = FlatCountersDetailsController()
            let navigationController = UINavigationController(rootViewController: viewController)
            let flatCountersController: HistoryTableController? = NavigationUtils.findController()
            newFlatCounters(for: viewController, root: flatCountersController, url: url)
            rootController.present(navigationController, animated: true)
        }
    }

    static func detailsFlatCounters(for viewController: FlatCountersDetailsController, entity: FlatEntity)
    {
        viewController.isEditing = false
        if let sentDate = entity.sentDate {
            viewController.title = "Показания от " + DateFormatter.shortDateTimeFormatter.string(from: sentDate)
        } else {
            viewController.title = "Отправленные показания"
        }
        viewController.id = entity.id
    }

}
