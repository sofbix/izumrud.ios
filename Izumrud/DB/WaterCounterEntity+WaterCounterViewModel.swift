//
//  WaterCounterEntity+WaterCounterViewModel.swift
//  Izumrud
//
//  Created by Sergey Balalaev on 27.06.2023.
//  Copyright © 2023 Byterix. All rights reserved.
//

import Foundation
import iSamaraCounters

extension WaterCounterViewModel {

    var entity : WaterCounterEntity {
        let result = WaterCounterEntity()
        result.id = id
        result.order = order
        result.name = nameRow.value ?? ""

        result.hotCount = hotCountRow.value ?? ""
        result.hotSerialNumber = hotSerialNumberRow.value ?? ""
        result.coldCount = coldCountRow.value ?? ""
        result.coldSerialNumber = coldSerialNumberRow.value ?? ""

        return result
    }

    convenience init(entity: WaterCounterEntity, fields: [String: String], index: Int) {
        self.init()
        self.id = entity.id
        self.order = entity.order
        updateRow(nameRow, fields: fields, index: index, with: "name", defaultValue: entity.name)
        updateRow(coldCountRow, fields: fields, index: index, with: "coldCount", defaultValue: entity.coldCount)
        updateRow(coldSerialNumberRow, fields: fields, index: index, with: "coldSerialNumber", defaultValue: entity.coldSerialNumber)
        updateRow(hotCountRow, fields: fields, index: index, with: "hotCount", defaultValue: entity.hotCount)
        updateRow(hotSerialNumberRow, fields: fields, index: index, with: "hotSerialNumber", defaultValue: entity.hotSerialNumber)
    }

}
