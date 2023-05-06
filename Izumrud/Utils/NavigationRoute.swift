//
//  NavigationRoute.swift
//  Izumrud
//
//  Created by Sergey Balalaev on 05.05.2023.
//  Copyright © 2023 Byterix. All rights reserved.
//

import Foundation

struct NavigationRoute {

    static func newFlatCounters(for viewController: FlatCountersDetailsController,
                                root historyController: HistoryTableController? = nil,
                                components: URLComponents? = nil)
    {
        viewController.isEditing = true
        viewController.title = "Новые показания"
        viewController.fields = components?.queryItems?.reduce(into:[String: String]()) { result, component in
            if let value = component.value, !value.isEmpty {
                result[component.name] = value
            }
        } ?? [:]
        viewController.newBranchHandler = {[weak historyController] in
            historyController?.refresh()
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
