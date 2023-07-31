//
//  IzumrudTests.swift
//  IzumrudTests
//
//  Created by Sergey Balalaev on 31.07.2023.
//  Copyright © 2023 Byterix. All rights reserved.
//

import XCTest
import iSamaraCounters

final class IzumrudTests: XCTestCase {

    let service = SamaraEnergoSendDataService()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSamaraEnergo() throws {
        let expectation = expectation(description: "SamaraEnergo")

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
