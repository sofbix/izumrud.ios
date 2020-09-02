//
//  FlatEntity.swift
//  Izumrud
//
//  Created by Sergey Balalaev on 27.08.2020.
//  Copyright © 2020 Byterix. All rights reserved.
//

import Foundation
import RealmSwift

class FlatEntity: Object {
    
    @objc dynamic var id: String = ""
    
    // for multyaccount mode in a future
    @objc dynamic var order: Int = 0
    
    @objc dynamic var surname: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var patronymic: String = ""
    @objc dynamic var homeNumber: String = ""
    @objc dynamic var flatNumber: String = ""
    @objc dynamic var phoneNumber: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var comments: String = ""
    
    @objc dynamic var dayElectricCount: String = ""
    @objc dynamic var nightElectricCount: String = ""
    
    @objc dynamic var rksAccountNumber: String = ""
    
    @objc dynamic var isSendingToUpravdom: Bool = true
    @objc dynamic var isSendingToRKS: Bool = true
    
    let waterCounters = List<WaterCounterEntity>()
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    override class func indexedProperties() -> [String] {
        return ["order"]
    }
    
}
