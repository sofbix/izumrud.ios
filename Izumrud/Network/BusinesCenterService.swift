//
//  BusinesCenterService.swift
//  Izumrud
//
//  Created by Sergey Balalaev on 18.05.2022.
//  Copyright © 2022 Byterix. All rights reserved.
//

import Foundation
import PromiseKit
import MessageUI

class BusinesCenterService : NSObject, SendDataService, MFMailComposeViewControllerDelegate {
    func map(_ input: FlatCountersDetailsController) -> Promise<Data> {
        
        if MFMailComposeViewController.canSendMail() {
            
            var waterBody = ""
            for waterCounter in input.waterCounters {
                if waterCounter.isValid { #warning("Has problem with checking realy params. Order can be invalided.")
                    let entity = waterCounter.entity
                    waterBody +=
                        """
                        Стояки № \(entity.order)
                        Номер счетчика горячей воды: \(entity.hotSerialNumber)
                        Значение счетчика горячей воды: \(entity.hotCount)
                        Номер счетчика холодной воды: \(entity.coldSerialNumber)
                        Значение счетчика холодной воды: \(entity.coldCount)
                        
                        """
                    #warning("3th counter should all empty values, or 2th for realy one. Please will add it if need. Without dobavit_schyotchik_hvs_(3/2) each other")
                }
            }
            
            let body =
                """
                Добрый день.
                Меня зовут \(input.surnameRow.value ?? "") \(input.nameRow.value ?? "") \(input.patronymicRow.value ?? "")
                Проживаю по адресу: Самара, Пятая+просека, дом \(input.homeNumberRow.value ?? ""), квартира+\(input.flatNumberRow.value ?? "")
                
                Передаю показания счетчиков электроэнергии:
                день: \(input.dayElectricCountRow.value ?? "")
                ночь: \(input.nightElectricCountRow.value ?? "")
                
                Информация по счётчикам воды:
                \(waterBody)
                """

             let mailComposeViewController = MFMailComposeViewController()
             mailComposeViewController.mailComposeDelegate = self
             mailComposeViewController.setToRecipients(["data_5proseka@mail.ru"])
             mailComposeViewController.setSubject("Показания сч-ов для УК БЦ")
             mailComposeViewController.setMessageBody(body, isHTML: false)

            input.present(mailComposeViewController, animated: true, completion: nil)

        }
        
        return .value(Data())
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {

         controller.dismiss(animated: true, completion: nil)

    }
    
    typealias Input = FlatCountersDetailsController
    
    
    let title: String = "Бизнес-центер"
    let name: String = "BusinesCenter"
    let days = Range<Int>(uncheckedBounds: (lower: 15, upper: 22))
    
    var url: String = ""
    
}
