//
//  EsPlusSendDataService.swift
//  SamaraCounter
//
//  Created by Sergey Balalaev on 24.12.2020.
//

import Foundation
import PromiseKit
import Alamofire

struct EsPlusSendDataService : SendDataService {
    
    
    typealias Input = FlatCountersDetailsController
    
    
    let name: String = "EsPlus"
    let title: String = "T+"
    let days = Range<Int>(uncheckedBounds: (lower: 15, upper: 25))
    
    func addCheckers(for input: FlatCountersDetailsController) {
        #warning("need check Int value of counters value")
    }
    
    
    func map(_ input: Input) -> Promise<Data> {
        
        
        let headers = [
            "Content-Type" : "application/x-www-form-urlencoded",
            "Accept" : "application/json",
            "Cookie" : "PHPSESSID=rs3574vh1dlgq8buc00lmhota4; BITRIX_SM_REGION=samara; BITRIX_SM_GUEST_ID=30347255; BITRIX_SM_LAST_VISIT=24.12.2020+22%3A33%3A41; INVOLVE_SESSION_MONITOR=1; BITRIX_CONVERSION_CONTEXT_s1=%7B%22ID%22%3A7%2C%22EXPIRE%22%3A1608843540%2C%22UNIQUE%22%3A%5B%22conversion_visit_day%22%5D%7D; _ym_uid=1584365216943771550; _ym_d=1608838300; _ga=GA1.2.221495573.1608838300; _gid=GA1.2.1431768146.1608838300; _fbp=fb.1.1608838300564.409783820; BX_USER_ID=dab864944a1f7a0ce7716b01dbd35b77; _ym_isad=1"
        ]
        
        #warning("Only First! Please fix it when you can test")
        
        let onlyFirstSN = input.waterCounters.first?.hotSerialNumberRow.value ?? ""
        let onlyFirstValue = input.waterCounters.first?.hotCountRow.value ?? ""
        let onlyFirstLabel = "Sh1" // Next Sh2, Sh3.
        
        let body = "sessid=a28ec405cf626574af948e80de8e89bd&status=GET_COUNTERS&nlsid=\(input.esPlusAccountNumberRow.value ?? "")&counters%5B\(onlyFirstSN)%5D%5B\(onlyFirstLabel)%5D=\(onlyFirstValue)&counter=\(onlyFirstSN)"
        

        var request = try! URLRequest(url: "https://samara.esplus.ru/local/include/ajax/send-counters-3.php", method: .post, headers: headers)
        request.httpBody = body.data(using: .utf8)
        
        return service(request)

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
