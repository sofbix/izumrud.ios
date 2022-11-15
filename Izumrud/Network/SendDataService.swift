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
import CircularSpinner
import BxInputController

struct ProgressService {

    func start(with title: String) -> Promise<Data> {
        return Promise { seal in
            #warning("May be is sync? Please fixed and test! I think it can show only first message")
            DispatchQueue.main.async {
                CircularSpinner.show(title, animated: true, type: .indeterminate, showDismissButton: false)
                seal.fulfill(Data())
            }
        }
    }
    
}

protocol SendDataService: Any {
    
    var name: String {get}
    var title: String {get}
    
    var days: Range<Int> {get}
    
    associatedtype Input

    func map(_ input: Input) -> Promise<Data>
    
    func addCheckers(for input: Input)
    
    func checkOutputData(with data: Data) -> String?
    
    func firstlyCheckAvailable() -> String?
}


extension SendDataService {
    
    // default realization has not input error
    func addCheckers(for input: Input) {
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
            return "Принимает с \(days.lowerBound) по \(days.upperBound) число"
        }
        return nil
    }
    
    func start(with input: Input) -> Promise<Data> {
        return map(input)
    }
    
    func errorObject(with message: String) -> NSError {
        return NSError(domain: self.title, code: 412, userInfo: [NSLocalizedDescriptionKey: message])
    }
    
    func error(with message: String) -> Promise<Data> {
        return Promise(error: errorObject(with: message))
    }
    
    func service(_ urlRequest: URLRequest) -> Promise<Data> {
        return map(Alamofire.SessionManager.default.request(urlRequest))
    }
    
    func service(_ url: URLConvertible,
                 method: HTTPMethod = .get,
                 parameters: Parameters? = nil,
                 encoding: ParameterEncoding = URLEncoding.default,
                 headers: HTTPHeaders? = nil) -> Promise<Data>
    {
        return map(Alamofire.SessionManager.default.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers))
    }
    
    private func map(_ request: DataRequest) -> Promise<Data> {
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
                    if var errorMessage = self.checkOutputData(with: data) {
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
    
}
