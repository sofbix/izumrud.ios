//
//  IzumrudTests.swift
//  IzumrudTests
//
//  Created by Sergey Balalaev on 31.07.2023.
//  Copyright © 2023 Byterix. All rights reserved.
//

import XCTest
import iSamaraCounters
import BxInputController

final class IzumrudTests: XCTestCase {

    private struct SendDataMockInput : SendDataServiceInput {
        var surnameRow = BxInputTextRow(value: "")
        var nameRow = BxInputTextRow(value: "")
        var patronymicRow = BxInputTextRow(value: "")
        var streetRow = BxInputTextRow(value: "")
        var homeNumberRow = BxInputTextRow(value: "")
        var flatNumberRow = BxInputTextRow(value: "")
        var phoneNumberRow: BxInputFormattedTextRow = BxInputFormattedTextRow(enteredCharacters: "", value: "")
        var emailRow = BxInputTextRow(value: "")
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
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSamaraEnergo() throws {
        let expectation = expectation(description: "SamaraEnergo")
        let service = SamaraEnergoSendDataService()
        service
            .map(SendDataMockInput())
            .done{ _ in
                expectation.fulfill()
            }.catch{ error in
                XCTFail(error.localizedDescription)
                expectation.fulfill()
            }

        waitForExpectations(timeout: 30) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

}
