//
//  SendDataService.swift
//  Izumrud
//
//  Created by Sergey Balalaev on 22.12.2020.
//  Copyright © 2020 Byterix. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire
import BxInputController

protocol SendDataServiceInput: Any {
    var surnameRow: BxInputTextRow {get}
    var nameRow: BxInputTextRow {get}
    var patronymicRow: BxInputTextRow {get}
    var streetRow: BxInputTextRow {get}
    var homeNumberRow: BxInputTextRow {get}
    var flatNumberRow: BxInputTextRow {get}
    var phoneNumberRow: BxInputFormattedTextRow {get}
    var emailRow: BxInputTextRow {get}
    var rksAccountNumberRow: BxInputTextRow {get}
    var esPlusAccountNumberRow: BxInputTextRow {get}
    var commentsRow: BxInputTextMemoRow {get}

    var electricAccountNumberRow: BxInputTextRow {get}
    var electricCounterNumberRow: BxInputTextRow {get}
    var dayElectricCountRow: BxInputTextRow {get}
    var nightElectricCountRow: BxInputTextRow {get}

    var waterCounters: [WaterCounterViewModel] {get}

    func addChecker(_ checker: BxInputRowChecker, for row: BxInputRow)
}

protocol SendDataService: Any {
    
    var name: String {get}
    var title: String {get}
    
    var days: Range<Int> {get}

    func map(_ input: SendDataServiceInput) -> Promise<Data>
    
    func addCheckers(for input: SendDataServiceInput)
    
    func checkOutputData(with data: Data) -> String?
    
    func firstlyCheckAvailable() -> String?

    var isNeedFirstLoad: Bool {get}
    func firstLoad(with input: SendDataServiceInput) -> Promise<Data>?
}


extension SendDataService {
    
    // default realization has not input error
    func addCheckers(for input: SendDataServiceInput) {
        //
    }
    
    // default realization has not output error
    func checkOutputData(with data: Data) -> String? {
        return nil
    }
    
    // default realization has error for dayes range
    func firstlyCheckAvailable() -> String? {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: Date())
        if day < days.lowerBound || day > days.upperBound {
            return "принимает с \(days.lowerBound) по \(days.upperBound) число"
        }
        return nil
    }
    
    func start(with input: SendDataServiceInput) -> Promise<Data> {
        return map(input)
    }
    
    func errorObject(with message: String) -> NSError {
        return NSError(domain: self.title, code: 412, userInfo: [NSLocalizedDescriptionKey: message])
    }
    
    func error(with message: String) -> Promise<Data> {
        return Promise(error: errorObject(with: message))
    }
    
    func service(_ urlRequest: URLRequest, isNeedCheckOutput: Bool = true) -> Promise<Data> {
        return map(Alamofire.SessionManager.default.request(urlRequest), isNeedCheckOutput: isNeedCheckOutput)
    }
    
    func service(_ url: URLConvertible,
                 method: HTTPMethod = .get,
                 parameters: Parameters? = nil,
                 encoding: ParameterEncoding = URLEncoding.default,
                 headers: HTTPHeaders? = nil,
                 isNeedCheckOutput: Bool = true) -> Promise<Data>
    {
        return map(Alamofire.SessionManager.default.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers), isNeedCheckOutput: isNeedCheckOutput)
    }
    
    private func map(_ request: DataRequest, isNeedCheckOutput: Bool = true) -> Promise<Data> {
        return Promise { seal in
            request.response{ (response) in

                if let error = response.error {
                    seal.reject(error)
                    return
                }
                
                guard let httpResponse = response.response else {
                    seal.reject(NSError(domain: self.title, code: 404, userInfo: [NSLocalizedDescriptionKey: "\(self.title): Нет ответа от сервера"]))
                    return
                }
                let status = httpResponse.statusCode
                if self.isError(statusCode: status) {
                    let localizedMessage = HTTPURLResponse.localizedString(forStatusCode: status)
                    let message = "\(self.title): \(localizedMessage) (\(status))"
                    seal.reject(NSError(domain: self.title, code: status, userInfo: [NSLocalizedDescriptionKey: message]))
                    return
                }
                
                if let data = response.data {
                    if isNeedCheckOutput, var errorMessage = self.checkOutputData(with: data) {
                        if errorMessage.isEmpty {
                            errorMessage = "\(self.title): Данные не переданы"
                        }
                        let error = NSError(domain: self.title, code: 412, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                        seal.reject(error)
                    } else {
                        seal.fulfill(data)
                    }
                }
            }
        }
    }
    
    private func isError(statusCode: Int) -> Bool {
        statusCode >= 300 || statusCode < 200
    }

    var isNeedFirstLoad: Bool {
        return false
    }
    func firstLoad(with input: SendDataServiceInput) -> Promise<Data>? {
        return nil
    }
    
}
