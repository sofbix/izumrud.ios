//
//  ContactsViewController.swift
//  Izumrud
//
//  Created by Sergey Balalaev on 20.04.2021.
//  Copyright © 2021 Byterix. All rights reserved.
//

import Foundation
import UIKit
import BxInputController

class ContactsViewController: BxInputController {
    
    private static let iconSize = CGSize(width: 24, height: 24)
    
    private let upravdomWebSiteRow = BxInputIconActionRow<String>(
        icon: #imageLiteral(resourceName: "WebIcon"), iconSize: iconSize,
        title: "Сайт", subtitle: "https://upravdom63.ru/")
    private let upravdomControlRoomPhoneRow = BxInputIconActionRow<String>(
        icon: #imageLiteral(resourceName: "PhoneIcon"), iconSize: iconSize,
        title: "Диспетчерская", subtitle: "tel://+7(846)313-18-75")
    private let upravdomElevatorRepairPhoneRow = BxInputIconActionRow<String>(
        icon: #imageLiteral(resourceName: "PhoneIcon"), iconSize: iconSize,
        title: "ЛифтРемонт", subtitle: "tel://+7(846)240-14-33")
    private let upravdomOfficePhoneRow = BxInputIconActionRow<String>(
        icon: #imageLiteral(resourceName: "PhoneIcon"), iconSize: iconSize,
        title: "Офис", subtitle: "tel://+7(846)247-54-45")
    private let upravdomMailRow = BxInputIconActionRow<String>(
        icon: #imageLiteral(resourceName: "MailIcon"), iconSize: iconSize,
        title: "Почта", subtitle: "mailto:upravdom-63@yandex.ru")
    
    private let bcWebSiteRow = BxInputIconActionRow<String>(
        icon: #imageLiteral(resourceName: "WebIcon"), iconSize: iconSize,
        title: "Сайт", subtitle: "https://vk.com/uk_bc63")
    private let bcControlRoomPhone1Row = BxInputIconActionRow<String>(
        icon: #imageLiteral(resourceName: "PhoneIcon"), iconSize: iconSize,
        title: "Диспетчерская", subtitle: "tel://+7(846)313-13-86")
    private let bcControlRoomPhone2Row = BxInputIconActionRow<String>(
        icon: #imageLiteral(resourceName: "PhoneIcon"), iconSize: iconSize,
        title: "Диспетчерская", subtitle: "tel://+7(846)313-13-87")
    private let bcOfficePhoneRow = BxInputIconActionRow<String>(
        icon: #imageLiteral(resourceName: "PhoneIcon"), iconSize: iconSize,
        title: "Офис", subtitle: "tel://+7(846)279-07-45")
    private let bcMailRow = BxInputIconActionRow<String>(
        icon: #imageLiteral(resourceName: "MailIcon"), iconSize: iconSize,
        title: "Почта", subtitle: "mailto:2007biznesproffi071@mail.ru")
    private let bcMailCounterRow = BxInputIconActionRow<String>(
        icon: #imageLiteral(resourceName: "MailIcon"), iconSize: iconSize,
        title: "Показания", subtitle: "mailto:data_5proseka@mail.ru")


    override func viewDidLoad() {
        super.viewDidLoad()

        //isEstimatedContent = false

        updateData()
        
    }
    
    private func updateData() {
        let handler = { (row: BxInputActionRow) in
            if let row = row as? BxInputIconActionRow<String>, let url = URL(string: row.subtitle ?? "") {
                UIApplication.shared.open(url)
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

