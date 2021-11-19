//
//  EsPlusSendDataService.swift
//  SamaraCounter
//
//  Created by Sergey Balalaev on 24.12.2020.
//

import Foundation
import PromiseKit
import Alamofire
import SwiftUI

protocol EsPlusCounter{
    var identifier: String {get}
    var number: String {get}
}

struct EsPlusSendDataService : SendDataService {
    
    
    typealias Input = FlatCountersDetailsController
    
    
    let name: String = "EsPlus"
    let title: String = "T+"
    let days = Range<Int>(uncheckedBounds: (lower: 15, upper: 25))
    
    func addCheckers(for input: FlatCountersDetailsController) {
        #warning("need check Int value of counters value")
    }
    
    
    
    struct GetCounters : Codable {
        struct Counter : Codable, EsPlusCounter {
            let id: String
            let number: String
            
            var identifier: String {
                return number
            }
            
            private enum CodingKeys: String, CodingKey {
                case id = "Id"
                case number = "Serial"
            }
        }
        let error: String?
        let counters: [Counter]?
    }
    
    struct GetCountersKP24 : Codable {
        struct Counter : Codable, EsPlusCounter {
            let id: Int
            let number: String
            
            var identifier: String {
                return "\(id)"
            }
        }
        let error: String?
        let counters: [Counter]?
    }
    
    func url(_ input: Input) -> String {
        if isKP24(input) {
            return "https://samara.esplus.ru/local/include/ajax/lk/TransRead/TransReadMetersKP24.php"
        }
        return "https://samara.esplus.ru/local/include/ajax/lk/TransRead/TransReadMeters.php"
    }
    
    // Все дело в том, что сервисы Т+ по разному работают с разными идентификаторами и соответственно вызывают разные сервисы с разными ответами, пришлось тоже закостылить
    func isKP24(_ input: Input) -> Bool {
        let number = input.esPlusAccountNumberRow.value ?? ""
        // это точно квартплата
        if number.count == 11 && number.isNumber {
            return true
        }
        return false
    }
    
    let headers = [
        "Content-Type" : "application/x-www-form-urlencoded; charset=UTF-8",
        "Accept" : "application/json",
        "Cookie" : "BITRIX_SM_REGION=samara; BITRIX_SM_GUEST_ID=45522622; BITRIX_SM_LAST_VISIT=19.11.2021+21%3A08%3A17; BITRIX_SM_LAST_ADV=7; BITRIX_CONVERSION_CONTEXT_s1=%7B%22ID%22%3A7%2C%22EXPIRE%22%3A1637355540%2C%22UNIQUE%22%3A%5B%22conversion_visit_day%22%5D%7D; BX_USER_ID=a76f4426683dd762e62d6e8e931cb0b3; _ga=GA1.2.882972400.1635106065; _ym_uid=1635106065753404634; _ym_d=1635106065; _fbp=fb.1.1635106064865.1365375347; PHPSESSID=55f76f809a031e22371e118ba1281a9b; INVOLVE_SESSION_MONITOR=1; _gid=GA1.2.212971121.1637343798; _ym_isad=2; _gat_gtag_UA_112818786_12=1"
    ]
    
    func mapCounters(_ input: Input, outputCounters: [EsPlusCounter]) -> Promise<Data> {
        var body = "sessid=a289233cfe33cde50d08d7d1fb5185c9&status=GET_COUNTERS&nlsid=\(input.esPlusAccountNumberRow.value ?? "")"
        
        var counters: [String] = []
        
        for waterCounter in input.waterCounters {
            let sn = waterCounter.hotSerialNumberRow.value ?? ""
            if let counter = outputCounters.first(where: { counter in
                return counter.number == sn
            }){
                let label = counter.identifier
                body += "&counters%5B\(label)%5D%5BSh1%5D=\(waterCounter.hotCountRow.value ?? "")"
                counters.append(label)
            }
            
        }
        
        if counters.isEmpty {
            return self.error(with: "Не найдены счетчики для Т+")
        }
        
        let bodies = counters.map {counterId in
            return body + "&counter=\(counterId)"
        }
        
        let services : [Promise<Data>] = bodies.map{ body in
            var request = try! URLRequest(url: url(input), method: .post, headers: headers)
            request.httpBody = body.data(using: .utf8)
            return service(request)
        }
        return when(fulfilled: services).map{ datas -> Data in
            for data in datas {
                if let error = self.checkOutputData(with: data) {
                    throw self.errorObject(with: error)
                } else {
                    print("Bingo T+")
                }
            }
            return datas.first ?? Data()
        }
    }
    
    func map(_ input: Input) -> Promise<Data> {

        let body = "sessid=a289233cfe33cde50d08d7d1fb5185c9&status=GET_COUNTERS&nlsid=\(input.esPlusAccountNumberRow.value ?? "")&get_counters=Y&PR=0"
        var request = try! URLRequest(url: url(input), method: .post, headers: headers)
        request.httpBody = body.data(using: .utf8)
        
        return service(request).then{ data -> Promise<Data> in
            do {
                if isKP24(input) {
                    let output = try JSONDecoder().decode(GetCountersKP24.self, from: data)
                    if let error = output.error {
                        return self.error(with: error)
                    } else {
                        return mapCounters(input, outputCounters: output.counters ?? [])
                    }
                } else {
                    let output = try JSONDecoder().decode(GetCounters.self, from: data)
                    if let error = output.error {
                        return self.error(with: error)
                    } else {
                        return mapCounters(input, outputCounters: output.counters ?? [])
                    }
                }
                
            } catch let error {
                return Promise<Data>(error: error)
            }
        }

    }
    
    struct Output : Codable {
        let error: String?
    }
    
    func checkOutputData(with data: Data) -> String? {
        do {
            let output = try JSONDecoder().decode(Output.self, from: data)
            return output.error
        } catch let error {
            return error.localizedDescription
        }
    }
    
}
