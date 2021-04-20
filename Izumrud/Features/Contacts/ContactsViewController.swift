//
//  ContactsViewController.swift
//  Izumrud
//
//  Created by Sergey Balalaev on 20.04.2021.
//  Copyright © 2021 Byterix. All rights reserved.
//

import Foundation
import BxInputController

class ContactsViewController: BxInputController {
    
    static let iconSize = CGSize(width: 24, height: 24)
    
    let webSiteRow = BxInputIconActionRow<String>(
        icon: #imageLiteral(resourceName: "WebIcon"), iconSize: iconSize,
        title: "Сайт", value: "https://upravdom63.ru/")
    let controlRoomPhoneRow = BxInputIconActionRow<String>(
        icon: #imageLiteral(resourceName: "PhoneIcon"), iconSize: iconSize,
        title: "Диспетчерская", value: "tel://+7(846)313-18-75")
    let elevatorRepairPhoneRow = BxInputIconActionRow<String>(
        icon: #imageLiteral(resourceName: "PhoneIcon"), iconSize: iconSize,
        title: "ЛифтРемонт", value: "tel://+7(846)240-14-33")
    let officePhoneRow = BxInputIconActionRow<String>(
        icon: #imageLiteral(resourceName: "PhoneIcon"), iconSize: iconSize,
        title: "Офис", value: "tel://+7(846)247-54-45")
    let mailPhoneRow = BxInputIconActionRow<String>(
        icon: #imageLiteral(resourceName: "MailIcon"), iconSize: iconSize,
        title: "Почта", value: "mailto:upravdom-63@yandex.ru")


    override func viewDidLoad() {
        super.viewDidLoad()

        //isEstimatedContent = false

        updateData()
        
    }
    
    func updateData() {
        let handler = { (row: BxInputActionRow) in
            if let row = row as? BxInputIconActionRow<String>, let url = URL(string: row.value ?? "") {
                UIApplication.shared.openURL(url)
            }
        }
        
        webSiteRow.handler = handler
        controlRoomPhoneRow.handler = handler
        elevatorRepairPhoneRow.handler = handler
        officePhoneRow.handler = handler
        mailPhoneRow.handler = handler
        
        sections = [
            BxInputSection(headerText: "Контакты УК Управдом",
                           rows: [webSiteRow, controlRoomPhoneRow, elevatorRepairPhoneRow, officePhoneRow, mailPhoneRow],
                           footerText: nil)
        ]
    }
    

}

