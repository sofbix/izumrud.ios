//
//  RKSSendDataService.swift
//  Izumrud
//
//  Created by Sergey Balalaev on 22.12.2020.
//  Copyright © 2020 Byterix. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

struct RKSSendDataService : Service {
    
    
    typealias Input = ViewController
    
    
    let title: String = "РКС"
    
    
    func map(_ input: ViewController) -> Promise<Data> {
        
        
        let headers = [
            "Content-Type" : "multipart/form-data; boundary=---------------------------207598656814045288261793191761",
            "Cookie" : "_ym_uid=1595532639642879152; _ym_d=1595532639; _ym_isad=1; PHPSESSID=f0hd9f3vmak8l4khjt2ac87ts0; _csrf=1b16c5592b7d182619cc6f6396cc26e8edcc52fc1a3a5960226d31afb49b7bc6a%3A2%3A%7Bi%3A0%3Bs%3A5%3A%22_csrf%22%3Bi%3A1%3Bs%3A32%3A%223ZfJdPO2A1PgF4lw63FNASiO0-m9-j1h%22%3B%7D; hide_privacy=true"
        ]
        
        #warning("account_number has 15 digital with any zeros in first position!")
        
        
        var coldCounters = ["", "", "", "", ""]
        var hotCounters = coldCounters
        
        for waterCounter in input.waterCounters {
            if waterCounter.isValid { #warning("Has problem with checking realy params. Order can be invalided.")
                let index = waterCounter.order - 1
                guard index >= 0 || index < coldCounters.count else {
                    continue
                }
                coldCounters[index] = "\(waterCounter.coldCountRow.value ?? "")"
                hotCounters[index] = "\(waterCounter.hotCountRow.value ?? "")"
            }
        }
        
        let body = """
-----------------------------207598656814045288261793191761
Content-Disposition: form-data; name="_csrf"

EC4PuD4YqipJiOsDRPiwSQq-Glkew2wQib1n_S08hP0jdGnyWkjlGAi5u2QCzNw-PI1cF1-QBV-5kArEAFa1lQ==
-----------------------------207598656814045288261793191761
Content-Disposition: form-data; name="SendDataWithoutRegForm[step_2]"

1
-----------------------------207598656814045288261793191761
Content-Disposition: form-data; name="SendDataWithoutRegForm[account_number]"

\(input.rksAccountNumberRow.value ?? "")
-----------------------------207598656814045288261793191761
Content-Disposition: form-data; name="SendDataWithoutRegForm[email]"

\(input.emailRow.value ?? "")
-----------------------------207598656814045288261793191761
Content-Disposition: form-data; name="SendDataWithoutRegForm[address]"

5 ПРОСЕКА, дом № \(input.homeNumberRow.value ?? ""), кв.№\(input.flatNumberRow.value ?? "")
-----------------------------207598656814045288261793191761
Content-Disposition: form-data; name="SendDataWithoutRegForm[XVS_P01]"


-----------------------------207598656814045288261793191761
Content-Disposition: form-data; name="SendDataWithoutRegForm[XVS_N01]"

\(coldCounters[0])
-----------------------------207598656814045288261793191761
Content-Disposition: form-data; name="SendDataWithoutRegForm[XVS_P02]"


-----------------------------207598656814045288261793191761
Content-Disposition: form-data; name="SendDataWithoutRegForm[XVS_N02]"

\(coldCounters[1])
-----------------------------207598656814045288261793191761
Content-Disposition: form-data; name="SendDataWithoutRegForm[XVS_P03]"


-----------------------------207598656814045288261793191761
Content-Disposition: form-data; name="SendDataWithoutRegForm[XVS_N03]"

\(coldCounters[2])
-----------------------------207598656814045288261793191761
Content-Disposition: form-data; name="SendDataWithoutRegForm[XVS_P04]"


-----------------------------207598656814045288261793191761
Content-Disposition: form-data; name="SendDataWithoutRegForm[XVS_N04]"

\(coldCounters[3])
-----------------------------207598656814045288261793191761
Content-Disposition: form-data; name="SendDataWithoutRegForm[XVS_P05]"


-----------------------------207598656814045288261793191761
Content-Disposition: form-data; name="SendDataWithoutRegForm[XVS_N05]"

\(coldCounters[4])
-----------------------------207598656814045288261793191761
Content-Disposition: form-data; name="SendDataWithoutRegForm[GVS_P01]"


-----------------------------207598656814045288261793191761
Content-Disposition: form-data; name="SendDataWithoutRegForm[GVS_N01]"

\(hotCounters[0])
-----------------------------207598656814045288261793191761
Content-Disposition: form-data; name="SendDataWithoutRegForm[GVS_P02]"


-----------------------------207598656814045288261793191761
Content-Disposition: form-data; name="SendDataWithoutRegForm[GVS_N02]"

\(hotCounters[1])
-----------------------------207598656814045288261793191761
Content-Disposition: form-data; name="SendDataWithoutRegForm[GVS_P03]"


-----------------------------207598656814045288261793191761
Content-Disposition: form-data; name="SendDataWithoutRegForm[GVS_N03]"

\(hotCounters[2])
-----------------------------207598656814045288261793191761
Content-Disposition: form-data; name="SendDataWithoutRegForm[GVS_P04]"


-----------------------------207598656814045288261793191761
Content-Disposition: form-data; name="SendDataWithoutRegForm[GVS_N04]"

\(hotCounters[3])
-----------------------------207598656814045288261793191761
Content-Disposition: form-data; name="SendDataWithoutRegForm[GVS_P05]"


-----------------------------207598656814045288261793191761
Content-Disposition: form-data; name="SendDataWithoutRegForm[GVS_N05]"

\(hotCounters[4])
-----------------------------207598656814045288261793191761--
"""
        

        var request = try! URLRequest(url: "https://lk.samcomsys.ru/submit-values", method: .post, headers: headers)
        request.httpBody = body.data(using: .utf8)
        
        return service(request)

    }
    
    func checkOutputData(with data: Data) -> String? {
        
        if let stringData = String(data: data, encoding: .utf8)
            
        {
            if stringData.contains("Показания приборов учета приняты") {
                return nil
            } else {
                print(stringData)
                return "Что то пошло не так с РКС"
            }
        }
        
        return "Ошибка отправки для РКС. Нет данных."
    }
    
    
}
