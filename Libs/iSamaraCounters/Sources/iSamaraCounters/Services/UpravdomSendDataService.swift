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
import Fuzi

public class UpravdomSendDataService : SendDataService {

    public init() { }

    public let title: String = "Управдом"
    public let name: String = "Upravdom"
    public let days = Range<Int>(uncheckedBounds: (lower: 15, upper: 20))
    

    private var form_build_id: String?
    private var honeypot_time: String?
    private var form_id: String?
    private let urls = [
        "https://upravdom63.ru/",
        "https://upravdom63.ru/passport"
    ]
    private var currentUrl: String? = nil
    
    
    public func map(_ input: SendDataServiceInput) -> Promise<Data> {
        
        
        let form_build_id = "input.form_build_id"
        let honeypot_time = "input.honeypot_time"
        let form_id = "input.form_id"

        
        let headers : HTTPHeaders = [
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
                parameters["no_schyotchika_gvs_\(waterCounter.order)"] = "\(waterCounter.hotSerialNumberRow.value ?? "")"
                parameters["pokazaniya_gvs_\(waterCounter.order)"] = "\(waterCounter.hotCountRow.value ?? "")"
                parameters["no_schyotchika_hvs_\(waterCounter.order)"] = "\(waterCounter.coldSerialNumberRow.value ?? "")"
                parameters["pokazaniya_hvs_\(waterCounter.order)"] = "\(waterCounter.coldCountRow.value ?? "")"
                if waterCounter.order > 1 {
                    parameters["dobavit_schyotchik_gvs_\(waterCounter.order)"] = "1"
                    parameters["dobavit_schyotchik_hvs_\(waterCounter.order)"] = "1"
                }
                #warning("3th counter should all empty values, or 2th for realy one. Please will add it if need. Without dobavit_schyotchik_hvs_(3/2) each other")
            }
        }

        let url = currentUrl ?? urls.first ?? ""

        //let request = try! URLRequest(url: url, method: .post)
        //let encode = try! URLEncoding.default.encode(request , with: parameters)
        //let stringData = String(data: encode.httpBody!, encoding: .utf8)!
        //print("\(stringData)")

        return service(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)

    }
    
    public func checkOutputData(with data: Data) -> String? {
        
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

// first load
extension UpravdomSendDataService {

    private static let firstLoadHeaders: HTTPHeaders = [
        "Host" : "upravdom63.ru",
        "User-Agent" : "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:74.0) Gecko/20100101 Firefox/74.0",
        "Accept" : "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
        "Accept-Language" : "ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3",
        "Accept-Encoding" : "gzip, deflate, br",
        "Content-Type" : "application/x-www-form-urlencoded",
        //"Content-Length" : "1086",
        "Origin" : "https://upravdom63.ru",
        "Connection" : "keep-alive",
        "Referer" : "https://upravdom63.ru/",
        "Upgrade-Insecure-Requests" : "1"
    ]

    private func firstLoadUpravdom() -> Promise<Data>{
        currentUrl = nil
        form_build_id = nil
        honeypot_time = nil
        form_id = nil
        return tryFirstLoadUpravdom()
    }

    private func tryFirstLoadUpravdom() -> Promise<Data> {
        var isNeedShowError = false
        if let currentUrl = currentUrl {
            if let index = urls.firstIndex(of: currentUrl) {
                if index + 1 < urls.count {
                    self.currentUrl = urls[index + 1]
                    if self.currentUrl == urls.last {
                        isNeedShowError = true
                    }
                } else {
                    isNeedShowError = true
                }
            }
        } else {
            currentUrl = urls.first
            if urls.count < 2 {
                isNeedShowError = true
            }
        }

        return Promise { seal in

            Alamofire.Session.default
                .request(currentUrl!, method: .get, headers: Self.firstLoadHeaders)
                .response
            {[weak self] (response) in

                guard let this = self else {
                    return
                }

                if let error = response.error {

                    if isNeedShowError {
                        seal.reject(NSError(domain: this.title, code: response.response?.statusCode ?? 404, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription]))
                    } else {
                        this.tryFirstLoadUpravdom()
                            .done { data in
                                seal.fulfill(data)
                            }.catch { error in
                                seal.reject(error)
                            }
                        return
                    }

                } else if let data = response.data {

                    var errorMessage: String? = nil

                    do {
                        let document = try XMLDocument(data: data)

                        let node = document.css("input")
                        for item in node {
                            if let name = item.attr("name"), let value = item.attr("value") {
                                if name == "form_build_id" {
                                    print("form_build_id : \(value)")
                                    this.form_build_id = value
                                } else if name == "honeypot_time" {
                                    print("honeypot_time : \(value)")
                                    this.honeypot_time = value
                                } else if name == "form_id" {
                                    print("form_id : \(value)")
                                    this.form_id = value
                                }
                            }
                        }

                    } catch let error {
                        errorMessage = error.localizedDescription
                    }

                    if errorMessage == nil, this.hasUpravdomData == false {
                        if let errorMessageAvailable = this.firstlyCheckAvailable() {
                            errorMessage = this.title + " " + errorMessageAvailable
                        } else {
                            errorMessage = "Данные с Управдома не получены.\nОбратитесь в поддержку."
                        }
                    }

                    if let errorMessage = errorMessage {
                        if isNeedShowError {
                            seal.reject(NSError(domain: this.title, code: 200, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                        } else {
                            this.tryFirstLoadUpravdom()
                                .done { data in
                                    seal.fulfill(data)
                                }.catch { error in
                                    seal.reject(error)
                                }
                            return
                        }
                    }

                }
            }

        }
    }

    private var hasUpravdomData: Bool {
        return form_build_id != nil && honeypot_time != nil && form_id != nil
    }

    public var isNeedFirstLoad: Bool {
        return !hasUpravdomData
    }
    public func firstLoad(with input: SendDataServiceInput) -> Promise<Data>? {
        return firstLoadUpravdom()
    }

}
