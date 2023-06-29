//
//  WaterCounterViewModel.swift
//  SamaraCounter
//
//  Created by Sergey Balalaev on 21.04.2021.
//

import Foundation
import BxInputController

public class WaterCounterViewModel {
    
    public var id: String = ""
    public var order: Int = 0
    
    public private(set) var nameRow = BxInputTextRow(title: "Название", subtitle: "для себя", maxCount: 100, value: "")
    
    public private(set) var hotCountRow = BxInputTextRow(title: "Показание горячей воды", subtitle: "Только целые числа, без дробных", maxCount: 10, value: "")
    public private(set) var hotSerialNumberRow = BxInputTextRow(title: "Номер сч-ка гор. воды", maxCount: 20, value: "")
    
    public private(set) var coldCountRow = BxInputTextRow(title: "Показание холодной воды", subtitle: "Только целые числа, без дробных", maxCount: 10, value: "")
    public private(set) var coldSerialNumberRow = BxInputTextRow(title: "Номер сч-ка хол. воды", maxCount: 20, value: "")
    
    public var section : BxInputSection {
        let title = (id == "") ? "Добавить счётчик воды" : "Счётчик воды № \(order)"
        return BxInputSection(headerText: title,
                              rows: [nameRow, coldCountRow, coldSerialNumberRow, hotCountRow, hotSerialNumberRow],
                              footerText: nil)
    }
    
    public func contains(_ row: BxInputRow) -> Bool
    {
        return self.nameRow === row ||
            self.coldCountRow === row ||
            self.coldSerialNumberRow === row ||
            self.hotCountRow === row ||
            self.hotSerialNumberRow === row
    }
    
    public init() {
        hotCountRow.textSettings.keyboardType = .numberPad
        coldCountRow.textSettings.keyboardType = .numberPad
    }
    

    
    public var isValid : Bool {
        return (nameRow.value ?? "").isEmpty == false ||
            (hotCountRow.value ?? "").isEmpty == false || (hotSerialNumberRow.value ?? "").isEmpty == false ||
            (coldCountRow.value ?? "").isEmpty == false || (coldSerialNumberRow.value ?? "").isEmpty == false
    }

    public func updateRow(_ row: BxInputTextRow, fields: [String: String], index: Int, with fieldName: String, defaultValue: String) {
        if let value = fields["waterCounters[\(index)]\(fieldName)"] {
            row.value = value
        } else {
            row.value = defaultValue
        }
    }
}
