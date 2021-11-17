//
//  WaterCounterViewModel.swift
//  SamaraCounter
//
//  Created by Sergey Balalaev on 21.04.2021.
//

import Foundation
import BxInputController

class WaterCounterViewModel {
    
    var id: String = ""
    var order: Int = 0
    
    var nameRow = BxInputTextRow(title: "Название", subtitle: "для себя", maxCount: 100, value: "")
    
    var hotCountRow = BxInputTextRow(title: "Показание горячей воды", subtitle: "Только целые числа, без дробных", maxCount: 10, value: "")
    var hotSerialNumberRow = BxInputTextRow(title: "Номер сч-ка гор. воды", maxCount: 20, value: "")
    
    var coldCountRow = BxInputTextRow(title: "Показание холодной воды", subtitle: "Только целые числа, без дробных", maxCount: 10, value: "")
    var coldSerialNumberRow = BxInputTextRow(title: "Номер сч-ка хол. воды", maxCount: 20, value: "")
    
    var section : BxInputSection {
        let title = (id == "") ? "Добавить счётчик воды" : "Счётчик воды № \(order)"
        return BxInputSection(headerText: title,
                              rows: [nameRow, coldCountRow, coldSerialNumberRow, hotCountRow, hotSerialNumberRow],
                              footerText: nil)
    }
    
    func contains(_ row: BxInputRow) -> Bool
    {
        return self.nameRow === row ||
            self.coldCountRow === row ||
            self.coldSerialNumberRow === row ||
            self.hotCountRow === row ||
            self.hotSerialNumberRow === row
    }
    
    init() {
        hotCountRow.textSettings.keyboardType = .numberPad
        coldCountRow.textSettings.keyboardType = .numberPad
    }
    
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
    
    var isValid : Bool {
        return (nameRow.value ?? "").isEmpty == false ||
            (hotCountRow.value ?? "").isEmpty == false || (hotSerialNumberRow.value ?? "").isEmpty == false ||
            (coldCountRow.value ?? "").isEmpty == false || (coldSerialNumberRow.value ?? "").isEmpty == false
    }
    
    convenience init(entity: WaterCounterEntity) {
        self.init()
        self.id = entity.id
        self.order = entity.order
        self.nameRow.value = entity.name
        self.coldCountRow.value = "\(entity.coldCount)"
        self.coldSerialNumberRow.value = entity.coldSerialNumber
        self.hotCountRow.value = "\(entity.hotCount)"
        self.hotSerialNumberRow.value = entity.hotSerialNumber
    }
}
