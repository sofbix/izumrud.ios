//
//  UpravdomTests.swift
//  IzumrudTests
//
//  Created by Sergey Balalaev on 06.08.2023.
//  Copyright © 2023 Byterix. All rights reserved.
//

import Foundation
import Alamofire
import XCTest
import iSamaraCounters
import iSamaraCountersModels

final class UpravdomTests: XCTestCase {

    let service = UpravdomSendDataService()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCerteficateFromFirstLoad() throws {
        let expectation = expectation(description: "Upravdom")

        service
            .firstLoad(with: SendDataMockInput(email: "something@mail.ru", electricCounterNumber: "123", dayElectricCount: "600", nightElectricCount: "89"))!
            .done{ _ in
                expectation.fulfill()
            }.catch{ error in
                defer {
                    expectation.fulfill()
                }
                switch error.asAFError! {
                case .sessionTaskFailed(let error):
                    let error = error as NSError
                    XCTAssertEqual(CFNetworkErrors.cfurlErrorServerCertificateUntrusted.rawValue, Int32(error.code))
                    break
                // bingo
                default:
                    XCTFail()
                }

            }

        waitForExpectations(timeout: 30) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

}
