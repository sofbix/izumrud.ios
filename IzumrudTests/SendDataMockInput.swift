//
//  SendDataMockInput.swift
//  IzumrudTests
//
//  Created by Sergey Balalaev on 01.08.2023.
//  Copyright © 2023 Byterix. All rights reserved.
//

import Foundation
import iSamaraCounters
import BxInputController

struct SendDataMockInput : SendDataServiceInput {
    var surnameRow = BxInputTextRow(value: "")
    var nameRow = BxInputTextRow(value: "")
    var patronymicRow = BxInputTextRow(value: "")
    var streetRow = BxInputTextRow(value: "")
    var homeNumberRow = BxInputTextRow(value: "")
    var flatNumberRow = BxInputTextRow(value: "")
    var phoneNumberRow: BxInputFormattedTextRow = BxInputFormattedTextRow(enteredCharacters: "", value: "")
    var emailRow = BxInputTextRow(value: "!")
    var rksAccountNumberRow = BxInputTextRow(value: "")
    var esPlusAccountNumberRow = BxInputTextRow(value: "")
    var commentsRow = BxInputTextMemoRow(value: "")
    var electricAccountNumberRow = BxInputTextRow(value: "")
    var electricCounterNumberRow = BxInputTextRow(value: "")
    var dayElectricCountRow = BxInputTextRow(value: "")
    var nightElectricCountRow = BxInputTextRow(value: "")

    var waterCounters: [WaterCounterViewModel] = []
    func addChecker(_ checker: BxInputRowChecker, for row: BxInputRow) {
        //
    }

    init(
        surname: String = "",
        name: String = "",
        patronymic: String = "",
        street: String = "",
        homeNumber: String = "",
        flatNumber: String = "",
        phoneNumber: String = "",
        email: String = "",
        rksAccountNumber: String = "",
        esPlusAccountNumber: String = "",
        comments: String = "",
        electricAccountNumber: String = "",
        electricCounterNumber: String = "",
        dayElectricCount: String = "",
        nightElectricCount: String = "")
    {
        surnameRow = BxInputTextRow(value: surname)
        nameRow = BxInputTextRow(value: name)
        patronymicRow = BxInputTextRow(value: patronymic)
        streetRow = BxInputTextRow(value: street)
        homeNumberRow = BxInputTextRow(value: homeNumber)
        flatNumberRow = BxInputTextRow(value: flatNumber)
        phoneNumberRow = BxInputFormattedTextRow(enteredCharacters: "", value: phoneNumber)
        emailRow = BxInputTextRow(value: email)
        rksAccountNumberRow = BxInputTextRow(value: rksAccountNumber)
        esPlusAccountNumberRow = BxInputTextRow(value: esPlusAccountNumber)
        commentsRow = BxInputTextMemoRow(value: comments)
        electricAccountNumberRow = BxInputTextRow(value: electricAccountNumber)
        electricCounterNumberRow = BxInputTextRow(value: electricCounterNumber)
        dayElectricCountRow = BxInputTextRow(value: dayElectricCount)
        nightElectricCountRow = BxInputTextRow(value: nightElectricCount)
    }
}
