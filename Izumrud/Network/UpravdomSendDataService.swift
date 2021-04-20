//
//  UpravdomSendDataService.swift
//  Izumrud
//
//  Created by Sergey Balalaev on 22.12.2020.
//  Copyright © 2020 Byterix. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

struct UpravdomSendDataService : Service {
    
    
    typealias Input = CountersViewController
    
    
    let title: String = "Управдом"
    
    
    func map(_ input: Input) -> Promise<Data> {
        
        
        guard let form_build_id = input.form_build_id,
              let honeypot_time = input.honeypot_time,
              let form_id = input.form_id
        else {
            return error(with: "Не случилась первоначальная загрузка для Управдома. Проверте сеть. Может вы подаете показания не в промежуток с 15 по 20 число месяца.")
        }
        
        let headers = [
            "Content-Type" : "application/x-www-form-urlencoded"
        ]
        
        var parameters = [
            "pokazaniya_den": "\(input.dayElectricCountRow.value ?? "")",
            "pokazaniya_noch": "\(input.nightElectricCountRow.value ?? "")",
            "fio":    "\(input.surnameRow.value ?? "")+\(input.nameRow.value ?? "")+\(input.patronymicRow.value ?? "")",
            "adres":    "Самара,+Пятая+просека,+дом+\(input.homeNumberRow.value ?? ""),+квартира+\(input.flatNumberRow.value ?? "")",
            "telefon":    "\(input.phoneNumberRow.value ?? "")",
            "kommentariy":    "\(input.commentsRow.value ?? "")",
            "op":    "Отправить",
            "form_build_id":    form_build_id,
            "form_id":    form_id,
            "honeypot_time":    honeypot_time,
            "phone":    ""
        ]
        
        for waterCounter in input.waterCounters {
            if waterCounter.isValid { #warning("Has problem with checking realy params. Order can be invalided.")
                let entity = waterCounter.entity
                parameters["no_schyotchika_gvs_\(entity.order)"] = "\(entity.hotSerialNumber)"
                parameters["pokazaniya_gvs_\(entity.order)"] = "\(entity.hotCount)"
                parameters["no_schyotchika_hvs_\(entity.order)"] = "\(entity.coldSerialNumber)"
                parameters["pokazaniya_hvs_\(entity.order)"] = "\(entity.coldCount)"
                if entity.order > 1 {
                    parameters["dobavit_schyotchik_gvs_\(entity.order)"] = "1"
                    parameters["dobavit_schyotchik_hvs_\(entity.order)"] = "1"
                }
                #warning("3th counter should all empty values, or 2th for realy one. Please will add it if need. Without dobavit_schyotchik_hvs_(3/2) each other")
            }
        }
        
        //let request = try! URLRequest(url: "https://upravdom63.ru/", method: .post)
        //let encode = try! URLEncoding.default.encode(request , with: parameters)
        //let stringData = String(data: encode.httpBody!, encoding: .utf8)!
        //print("\(stringData)")
        
        return service("https://upravdom63.ru/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)

    }
    
    func checkOutputData(with data: Data) -> String? {
        
        if let stringData = String(data: data, encoding: .utf8)
            
        {
            if stringData.contains("Ваши показания успешно отправлены") {
                return nil
            } else {
                print(stringData)
                return "Что то пошло не так с Управдомом"
            }
        }
        
        return "Ошибка отправки для Управдома. Нет данных."
    }
    
    
}
