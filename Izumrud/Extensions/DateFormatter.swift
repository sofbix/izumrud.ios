//
//  DateFormatter.swift
//  SamaraCounter
//
//  Created by Sergey Balalaev on 25.10.2021.
//

import Foundation

extension DateFormatter
{
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }
    
    convenience init(dateStyle: DateFormatter.Style = .none, timeStyle: DateFormatter.Style = .none) {
        self.init()
        self.dateStyle = dateStyle
        self.timeStyle = timeStyle
    }
    
    static let shortDateFormatter = DateFormatter(dateFormat: "dd.MM.yyyy")
    static let shortDateTimeFormatter = DateFormatter(dateFormat: "dd.MM.yyyy HH:mm")
    
}
