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
    
    let upravdomWebSiteRow = BxInputIconActionRow<String>(
        icon: #imageLiteral(resourceName: "WebIcon"), iconSize: iconSize,
        title: "Сайт", subtitle: "https://upravdom63.ru/")
    let upravdomControlRoomPhoneRow = BxInputIconActionRow<String>(
        icon: #imageLiteral(resourceName: "PhoneIcon"), iconSize: iconSize,
        title: "Диспетчерская", subtitle: "tel://+7(846)313-18-75")
    let upravdomElevatorRepairPhoneRow = BxInputIconActionRow<String>(
        icon: #imageLiteral(resourceName: "PhoneIcon"), iconSize: iconSize,
        title: "ЛифтРемонт", subtitle: "tel://+7(846)240-14-33")
    let upravdomOfficePhoneRow = BxInputIconActionRow<String>(
        icon: #imageLiteral(resourceName: "PhoneIcon"), iconSize: iconSize,
        title: "Офис", subtitle: "tel://+7(846)247-54-45")
    let upravdomMailRow = BxInputIconActionRow<String>(
        icon: #imageLiteral(resourceName: "MailIcon"), iconSize: iconSize,
        title: "Почта", subtitle: "mailto:upravdom-63@yandex.ru")
    
    let bcWebSiteRow = BxInputIconActionRow<String>(
        icon: #imageLiteral(resourceName: "WebIcon"), iconSize: iconSize,
        title: "Сайт", subtitle: "https://vk.com/uk_bc63")
    let bcControlRoomPhone1Row = BxInputIconActionRow<String>(
        icon: #imageLiteral(resourceName: "PhoneIcon"), iconSize: iconSize,
        title: "Диспетчерская", subtitle: "tel://+7(846)313-13-86")
    let bcControlRoomPhone2Row = BxInputIconActionRow<String>(
        icon: #imageLiteral(resourceName: "PhoneIcon"), iconSize: iconSize,
        title: "Диспетчерская", subtitle: "tel://+7(846)313-13-87")
    let bcOfficePhoneRow = BxInputIconActionRow<String>(
        icon: #imageLiteral(resourceName: "PhoneIcon"), iconSize: iconSize,
        title: "Офис", subtitle: "tel://+7(846)279-07-45")
    let bcMailRow = BxInputIconActionRow<String>(
        icon: #imageLiteral(resourceName: "MailIcon"), iconSize: iconSize,
        title: "Почта", subtitle: "mailto:2007biznesproffi071@mail.ru")
    let bcMailCounterRow = BxInputIconActionRow<String>(
        icon: #imageLiteral(resourceName: "MailIcon"), iconSize: iconSize,
        title: "Показания", subtitle: "mailto:data_5proseka@mail.ru")


    override func viewDidLoad() {
        super.viewDidLoad()

        //isEstimatedContent = false

        updateData()
        
    }
    
    func updateData() {
        let handler = { (row: BxInputActionRow) in
            if let row = row as? BxInputIconActionRow<String>, let url = URL(string: row.subtitle ?? "") {
                UIApplication.shared.openURL(url)
            }
        }
        
        upravdomWebSiteRow.handler = handler
        upravdomControlRoomPhoneRow.handler = handler
        upravdomElevatorRepairPhoneRow.handler = handler
        upravdomOfficePhoneRow.handler = handler
        upravdomMailRow.handler = handler
        
        bcWebSiteRow.handler = handler
        bcControlRoomPhone1Row.handler = handler
        bcControlRoomPhone2Row.handler = handler
        bcOfficePhoneRow.handler = handler
        bcMailRow.handler = handler
        bcMailCounterRow.handler = handler
        
        sections = [
            BxInputSection(headerText: "УК Бизнес-Центр",
                           rows: [bcWebSiteRow, bcControlRoomPhone1Row, bcControlRoomPhone2Row, bcOfficePhoneRow, bcMailRow, bcMailCounterRow],
                           footerText: nil),
            BxInputSection(headerText: "УК Управдом",
                           rows: [upravdomWebSiteRow, upravdomControlRoomPhoneRow, upravdomElevatorRepairPhoneRow, upravdomOfficePhoneRow, upravdomMailRow],
                           footerText: nil)
        ]
    }
    

}

