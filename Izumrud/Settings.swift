//
//  Settings.swift
//  Izumrud
//
//  Created by Sergey Balalaev on 01.01.2021.
//  Copyright © 2021 Byterix. All rights reserved.
//

import Foundation
import UIKit

struct Settings {

    static let startCompanyDate = Settings.shortDateFormatter.date(from: "01.01.2020")!

    static let shortDateFormatter = DateFormatter(dateFormat: "MM.yy")
    
    struct Color {
        
        static let brand = UIColor(hex: 0x009F5C)
        static let secondAccent = UIColor(red: 61/255, green: 165/255, blue: 255/255, alpha: 1)
        
    }
}
