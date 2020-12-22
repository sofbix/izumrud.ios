//
//  Service.swift
//  Izumrud
//
//  Created by Sergey Balalaev on 22.12.2020.
//  Copyright © 2020 Byterix. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

protocol Service {
    
    associatedtype Input
    
    var title: String {get}
    
    func map(_ input: Input) -> Promise<Data>
    
    func checkInputData(_ data: Input) -> String?
    func checkOutputData(with data: Data) -> String?
    
}


extension Service {
    
    // default realization have not input error
    func checkInputData(_ data: Input) -> String? {
        return nil
    }
    
    // default realization have not output error
    func checkOutputData(with data: Data) -> String? {
        return nil
    }
    
    func start(with input: Input) -> Promise<Data> {
        if var errorMessage = self.checkInputData(input) {
            if errorMessage.isEmpty {
                errorMessage = "Ошибка входных данных"
            }
            return error(with: errorMessage)
        }
        return map(input)
    }
    
    func error(with message: String) -> Promise<Data> {
        let error = NSError(domain: self.title, code: 412, userInfo: [NSLocalizedDescriptionKey: message])
        return Promise { seal in
            seal.reject(error)
        }
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
                } else if let data = response.data {
                    
                    if var errorMessage = self.checkOutputData(with: data) {
                        if errorMessage.isEmpty {
                            errorMessage = "Данные не переданы"
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
    
}
