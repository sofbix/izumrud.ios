//
//  String.swift
//  SamaraCounter
//
//  Created by Sergey Balalaev on 29.10.2021.
//

import Foundation

extension String {
    
    var isNumber: Bool {
        guard isEmpty == false else {
            return false
        }
        let numberRegEx = "^[0-9]+$"
        let numberTest = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        return numberTest.evaluate(with: self)
    }
    
}
