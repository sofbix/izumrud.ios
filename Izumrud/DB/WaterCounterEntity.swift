//
//  WaterCounterEntity.swift
//  Izumrud
//
//  Created by Sergey Balalaev on 27.08.2020.
//  Copyright © 2020 Byterix. All rights reserved.
//

import Foundation
import RealmSwift

class WaterCounterEntity: Object {
    
    @objc dynamic var id: String = ""
    
    // for many Counters
    @objc dynamic var order: Int = 0
    
    @objc dynamic var name: String = ""
    @objc dynamic var hotCount: String = ""
    @objc dynamic var hotSerialNumber: String = ""
    @objc dynamic var coldCount: String = ""
    @objc dynamic var coldSerialNumber: String = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    override class func indexedProperties() -> [String] {
        return ["order"]
    }
    
}
