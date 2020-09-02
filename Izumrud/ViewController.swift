//
//  ViewController.swift
//  Izumrud
//
//  Created by Sergey Balalaev on 19.07.2020.
//  Copyright © 2020 Byterix. All rights reserved.
//

import UIKit
import BxInputController
import CircularSpinner
import Alamofire
import Fuzi

class ViewController: BxInputController {
    
    class WaterCounter {
        
        var id: String = ""
        var order: Int = 0
        
        var nameRow = BxInputTextRow(title: "Название", subtitle: "для себя", maxCount: 100, value: "")
        
        var hotCountRow = BxInputTextRow(title: "Показание горячей воды", subtitle: "Только целые числа, без дробных", maxCount: 10, value: "")
        var hotSerialNumberRow = BxInputTextRow(title: "Номер сч-ка гор. воды", maxCount: 20, value: "")
        
        var coldCountRow = BxInputTextRow(title: "Показание холодной воды", subtitle: "Только целые числа, без дробных", maxCount: 10, value: "")
        var coldSerialNumberRow = BxInputTextRow(title: "Номер сч-ка хол. воды", maxCount: 20, value: "")
        
        var section : BxInputSection {
            let title = (id == "") ? "Добавить счётчик воды" : "Счётчик воды № \(order)"
            return BxInputSection(headerText: title,
                                  rows: [nameRow, coldCountRow, coldSerialNumberRow, hotCountRow, hotSerialNumberRow],
                                  footerText: nil)
        }
        
        func contains(_ row: BxInputRow) -> Bool
        {
            return self.nameRow === row ||
                self.coldCountRow === row ||
                self.coldSerialNumberRow === row ||
                self.hotCountRow === row ||
                self.hotSerialNumberRow === row
        }
        
        init() {
            hotCountRow.textSettings.keyboardType = .numberPad
            coldCountRow.textSettings.keyboardType = .numberPad
        }
        
        var entity : WaterCounterEntity {
            let result = WaterCounterEntity()
            result.id = id
            result.order = order
            result.name = nameRow.value ?? ""

            #warning("need throw exception if isn't Int value")
            result.hotCount = hotCountRow.value ?? ""
            result.hotSerialNumber = hotSerialNumberRow.value ?? ""
            
            #warning("need throw exception if isn't Int value")
            result.coldCount = coldCountRow.value ?? ""
            result.coldSerialNumber = coldSerialNumberRow.value ?? ""
            
            return result
        }
        
        var isValid : Bool {
            return (nameRow.value ?? "").isEmpty == false ||
                (hotCountRow.value ?? "").isEmpty == false || (hotSerialNumberRow.value ?? "").isEmpty == false ||
                (coldCountRow.value ?? "").isEmpty == false || (coldSerialNumberRow.value ?? "").isEmpty == false
        }
        
        convenience init(entity: WaterCounterEntity) {
            self.init()
            self.id = entity.id
            self.order = entity.order
            self.nameRow.value = entity.name
            self.coldCountRow.value = "\(entity.coldCount)"
            self.coldSerialNumberRow.value = entity.coldSerialNumber
            self.hotCountRow.value = "\(entity.hotCount)"
            self.hotSerialNumberRow.value = entity.hotSerialNumber
        }
    }
    
    let waterCounterMaxCount = 3
    
    // Go button
    
    let startRow = BxInputIconActionRow<String>(icon: nil, title: "Start")
    
    // Input Fields:
    
    var id: String = ""
    var order: Int = 0
    
    var surnameRow = BxInputTextRow(title: "Фамилия", maxCount: 200, value: "")
    var nameRow = BxInputTextRow(title: "Имя", maxCount: 200, value: "")
    var patronymicRow = BxInputTextRow(title: "Отчества", maxCount: 200, value: "")
    var homeNumberRow = BxInputTextRow(title: "Номер дома", maxCount: 5, value: "")
    var flatNumberRow = BxInputTextRow(title: "Номер квартиры", maxCount: 5, value: "")
    var phoneNumberRow = BxInputFormattedTextRow(title: "Телефон", prefix: "+7", format: "(###)###-##-##")
    var emailRow = BxInputTextRow(title: "E-mail", maxCount: 50, value: "")
    var rksAccountNumberRow = BxInputTextRow(title: "Номер счета РКС", subtitle: "если необходим", maxCount: 20, value: "")
    var commentsRow = BxInputTextMemoRow(title: "Коментарии", maxCount: 1000, value: "")

    var dayElectricCountRow = BxInputTextRow(title: "День", subtitle: "целые числа, без дробных", maxCount: 10, value: "")
    var nightElectricCountRow = BxInputTextRow(title: "Ночь", subtitle: "целые числа, без дробных", maxCount: 10, value: "")
    
    let isSendingToUpravdomRow = BxInputCheckRow(title: "Управдом", value: true)
    let isSendingToRKSRow = BxInputCheckRow(title: "РКС", value: true)
    
    var waterCounters: [WaterCounter] = []
    
    // Internal data for requests:
    
    var form_build_id: String?
    var honeypot_time: String?
    var form_id: String?
    
    let sendFooter: UIView = {
        let foother = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        foother.backgroundColor = .clear
        
        let btSend = UIButton(frame: CGRect(x: 20, y: 10, width: 60, height: 40))
        btSend.layer.cornerRadius = 8
        btSend.backgroundColor = .systemRed
        btSend.setTitleColor(.white, for: .normal)
        btSend.setTitleColor(.yellow, for: .highlighted)
        btSend.setTitle("Отправить показания", for: .normal)
        btSend.addTarget(self, action: #selector(start), for: .touchUpInside)
        
        foother.addSubview(btSend)
        btSend.translatesAutoresizingMaskIntoConstraints = false
        btSend.leadingAnchor.constraint(equalTo: foother.leadingAnchor, constant: 20).isActive = true
        btSend.trailingAnchor.constraint(equalTo: foother.trailingAnchor, constant: -20).isActive = true
        btSend.topAnchor.constraint(equalTo: foother.topAnchor, constant: 10).isActive = true
        btSend.bottomAnchor.constraint(equalTo: foother.bottomAnchor, constant: -30).isActive = true
        btSend.widthAnchor.constraint(equalToConstant: 60).isActive = true
        btSend.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        return foother
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        isEstimatedContent = false
        
        homeNumberRow.textSettings.keyboardType = .numberPad
        flatNumberRow.textSettings.keyboardType = .numberPad
        dayElectricCountRow.textSettings.keyboardType = .numberPad
        nightElectricCountRow.textSettings.keyboardType = .numberPad
        
        updateData()
        
        startRow.isImmediatelyDeselect = true
        startRow.handler = {[weak self] _ in
            self?.start()
        }
        
        URLSessionConfiguration.default.timeoutIntervalForRequest = 60
        
        firstLoad()
    }
    
    func updateData() {
        
        var flatEntity = FlatEntity()
        
        if let entity = DatabaseManager.shared.commonRealm.objects(FlatEntity.self).first {
            flatEntity = entity
        } else {
            DatabaseManager.shared.commonRealm.beginWrite()
            flatEntity.id = UUID().uuidString
            flatEntity.order = 1
            DatabaseManager.shared.commonRealm.add(flatEntity, update: .all)
            do {
                try DatabaseManager.shared.commonRealm.commitWrite()
            } catch let error {
                DatabaseManager.shared.commonRealm.cancelWrite()
                showAlert(title: "Ошибка данных", message: "Данные в телефоне сохранены не будут: \(error)")
            }
        }
        
        id = flatEntity.id
        order = flatEntity.order
        
        surnameRow.value = flatEntity.surname
        nameRow.value = flatEntity.name
        patronymicRow.value = flatEntity.patronymic
        homeNumberRow.value = flatEntity.homeNumber
        flatNumberRow.value = flatEntity.flatNumber
        phoneNumberRow.value = flatEntity.phoneNumber
        emailRow.value = flatEntity.email
        rksAccountNumberRow.value = flatEntity.rksAccountNumber
        commentsRow.value = flatEntity.comments
        
        dayElectricCountRow.value = "\(flatEntity.dayElectricCount)"
        nightElectricCountRow.value = "\(flatEntity.nightElectricCount)"
        
        var sections = [
            BxInputSection(headerText: "Данные собственника",
                           rows: [surnameRow, nameRow, patronymicRow, homeNumberRow, flatNumberRow, phoneNumberRow, emailRow, rksAccountNumberRow],
                           footerText: nil),
            BxInputSection(headerText: "Комментарии для УК", rows: [commentsRow], footerText: nil),
            BxInputSection(headerText: "Показания электрического счётчика", rows: [dayElectricCountRow, nightElectricCountRow], footerText: nil)
        ]
        
        waterCounters = []
        for waterCounterEntity in flatEntity.waterCounters {
            let waterCounter = WaterCounter(entity: waterCounterEntity)
            
            waterCounters.append(waterCounter)
            sections.append(waterCounter.section)
        }
        
        if waterCounters.count < waterCounterMaxCount {
            let waterCounter = WaterCounter()
            
            waterCounters.append(waterCounter)
            sections.append(waterCounter.section)
        }
        
        // for a future
        //sections.append(BxInputSection(headerText: "Куда отправляем", rows: [isSendingToUpravdomRow, isSendingToRKSRow], footerText: nil))

        sections.append(BxInputSection(headerText: "Проверьте данные и нажмите:", rows: [], footerText: nil))
        sections.append(BxInputSection(header: BxInputSectionView(sendFooter), rows: []))
        
        self.sections = sections
    }
    
    func saveFlatData(){
        if let flatEntity = DatabaseManager.shared.commonRealm.object(ofType: FlatEntity.self, forPrimaryKey: id)
        {
            DatabaseManager.shared.commonRealm.beginWrite()
            flatEntity.surname = surnameRow.value ?? ""
            flatEntity.name = nameRow.value ?? ""
            flatEntity.patronymic = patronymicRow.value ?? ""
            flatEntity.homeNumber = homeNumberRow.value ?? ""
            flatEntity.flatNumber = flatNumberRow.value ?? ""
            flatEntity.phoneNumber = phoneNumberRow.value ?? ""
            flatEntity.email = emailRow.value ?? ""
            flatEntity.rksAccountNumber = rksAccountNumberRow.value ?? ""
            flatEntity.comments = commentsRow.value ?? ""
            
            #warning("Please check dayElectricCountRow & nightElectricCountRow to Int values")
            
            flatEntity.dayElectricCount = dayElectricCountRow.value ?? ""
            flatEntity.nightElectricCount = nightElectricCountRow.value ?? ""
            DatabaseManager.shared.commonRealm.add(flatEntity, update: .modified)
            do {
                try DatabaseManager.shared.commonRealm.commitWrite()
            } catch let error {
                DatabaseManager.shared.commonRealm.cancelWrite()
                showAlert(title: "Ошибка данных", message: "Данные в телефоне сохранены не будут: \(error)")
            }
        } else {
            showAlert(title: "Ошибка данных", message: "Данные в телефоне сохранены не будут")
        }
    }
    
    func saveData(waterCounter: WaterCounter){
        if let _ = DatabaseManager.shared.commonRealm.object(ofType: WaterCounterEntity.self, forPrimaryKey: waterCounter.id)
        {
            DatabaseManager.shared.commonRealm.beginWrite()
            let waterCounterEntity = waterCounter.entity
            DatabaseManager.shared.commonRealm.add(waterCounterEntity, update: .modified)
            do {
                try DatabaseManager.shared.commonRealm.commitWrite()
            } catch let error {
                DatabaseManager.shared.commonRealm.cancelWrite()
                showAlert(title: "Ошибка данных", message: "Данные в телефоне сохранены не будут: \(error)")
            }
        } else {
            DatabaseManager.shared.commonRealm.beginWrite()
            let waterCounterEntity = waterCounter.entity
            waterCounterEntity.id = UUID().uuidString
            let waterCounterOrder : Int = DatabaseManager.shared.commonRealm.objects(WaterCounterEntity.self).sorted(byKeyPath: "order").last?.order ?? 0
            waterCounterEntity.order = waterCounterOrder + 1
            DatabaseManager.shared.commonRealm.add(waterCounterEntity, update: .all)
            if let flatEntity = DatabaseManager.shared.commonRealm.object(ofType: FlatEntity.self, forPrimaryKey: id)
            {
                flatEntity.waterCounters.append(waterCounterEntity)
            }
            do {
                try DatabaseManager.shared.commonRealm.commitWrite()
                updateData()
            } catch let error {
                DatabaseManager.shared.commonRealm.cancelWrite()
                showAlert(title: "Ошибка данных", message: "Данные в телефоне сохранены не будут: \(error)")
            }
        }
    }
    
    func saveData(for row: BxInputValueRow) {
        if let waterCounter = waterCounters.first(where: { (waterCounter) -> Bool in
            return waterCounter.contains(row)
        })
        {
            saveData(waterCounter: waterCounter)
        } else {
            saveFlatData()
        }
    }
    
    override func didChangeValue(for row: BxInputValueRow) {
        super.didChangeValue(for: row)
        saveData(for: row)
    }
    
    @objc
    func start() {
        startUpravdom()
        //startRKS()
    }
    
//    let headers = [
//        "Acept" : "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
//        "Content-Type" : "application/x-www-form-urlencoded"
//    ]
    
    let headers = [
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
    
    func firstLoad(){
        
        CircularSpinner.show("Получаю данные с Управдома", animated: true, type: .indeterminate, showDismissButton: false)
        
        Alamofire.SessionManager.default
            .request("https://upravdom63.ru/", method: .get, headers: headers)
            .response
        {[weak self] (response) in
            
            if let error = response.error {
                
                self?.showAlert(title: "Ошибка", message: error.localizedDescription)
                
                CircularSpinner.hide()
            } else if let data = response.data {
                //let stringData = String(data: data, encoding: .utf8)
                
                
                
                do {
                  let document = try XMLDocument(data: data)
                    
                    let node = document.css("input")
                    for item in node {
                        if let name = item.attr("name"), let value = item.attr("value") {
                            if name == "form_build_id" {
                                print("form_build_id : \(value)")
                                self?.form_build_id = value
                            } else if name == "honeypot_time" {
                                print("honeypot_time : \(value)")
                                self?.honeypot_time = value
                            } else if name == "form_id" {
                                print("form_id : \(value)")
                                self?.form_id = value
                            }
                        }
                    }
                    
                } catch let error {
                  self?.showAlert(title: "Ошибка", message: error.localizedDescription)
                }
                
                CircularSpinner.hide()
            }
            
            
            
        }
        
    }
    
    // показания принимаются 15 по 20
    func startUpravdom() {
        
        guard let form_build_id = form_build_id, let honeypot_time = honeypot_time, let form_id = form_id else {
            showAlert(title: "Ошибка", message: "Не случилась первоначальная загрузка для Управдома. Проверте сеть. Может вы подаете показания не в промежуток с 15 по 20 число месяца.")
            return
        }
        
        CircularSpinner.show("Отправка в Управдом", animated: true, type: .indeterminate, showDismissButton: false)
        
        let headers = [
            "Content-Type" : "application/x-www-form-urlencoded"
        ]
        
        var parameters = [
            "pokazaniya_den": "\(dayElectricCountRow.value ?? "")",
            "pokazaniya_noch": "\(nightElectricCountRow.value ?? "")",
            "fio":    "\(surnameRow.value ?? "")+\(nameRow.value ?? "")+\(patronymicRow.value ?? "")",
            "adres":    "Самара,+Пятая+просека,+дом+\(homeNumberRow.value ?? ""),+квартира+\(flatNumberRow.value ?? "")",
            "telefon":    "\(phoneNumberRow.value ?? "")",
            "kommentariy":    "\(commentsRow.value ?? "")",
            "op":    "Отправить",
            "form_build_id":    form_build_id,
            "form_id":    form_id,
            "honeypot_time":    honeypot_time,
            "phone":    ""
        ]
        
        for waterCounter in waterCounters {
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
        
        Alamofire.SessionManager.default
            .request("https://upravdom63.ru/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .response
        {[weak self] (response) in
            
            if let error = response.error {
                
                self?.showAlert(title: "Ошибка", message: error.localizedDescription)
                
                CircularSpinner.hide()
            } else if let data = response.data {
                
                
                if let stringData = String(data: data, encoding: .utf8)
                    
                {
                    if stringData.contains("Ваши показания успешно отправлены") {
                        //self?.showAlert(title: "Bingo!", message: "Ваши показания успешно отправлены")
                        self?.startRKS()
                        return
                    } else {
                        self?.showAlert(title: "Ошибка отправки", message: "Что то пошло не так с Управдомом")
                        print(stringData)
                    }
                }
                
                CircularSpinner.hide()
            }
            
            
            
        }
        
        
        
    }
    
    // показания принимаются 7 по 23
    func startRKS() {
        CircularSpinner.show("Отправка в РКС", animated: true, type: .indeterminate, showDismissButton: false)
        
        let headers = [
            "Content-Type" : "multipart/form-data; boundary=---------------------------207598656814045288261793191761",
            "Cookie" : "_ym_uid=1595532639642879152; _ym_d=1595532639; _ym_isad=1; PHPSESSID=f0hd9f3vmak8l4khjt2ac87ts0; _csrf=1b16c5592b7d182619cc6f6396cc26e8edcc52fc1a3a5960226d31afb49b7bc6a%3A2%3A%7Bi%3A0%3Bs%3A5%3A%22_csrf%22%3Bi%3A1%3Bs%3A32%3A%223ZfJdPO2A1PgF4lw63FNASiO0-m9-j1h%22%3B%7D; hide_privacy=true"
        ]
        
        #warning("account_number has 15 digital with any zeros in first position!")
        
        
        var coldCounters = ["", "", "", "", ""]
        var hotCounters = coldCounters
        
        for waterCounter in waterCounters {
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

\(rksAccountNumberRow.value ?? "")
-----------------------------207598656814045288261793191761
Content-Disposition: form-data; name="SendDataWithoutRegForm[email]"

\(emailRow.value ?? "")
-----------------------------207598656814045288261793191761
Content-Disposition: form-data; name="SendDataWithoutRegForm[address]"

5 ПРОСЕКА, дом № \(homeNumberRow.value ?? ""), кв.№\(flatNumberRow.value ?? "")
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
        
        Alamofire.SessionManager.default
            .request(request)
            .response
        {[weak self] (response) in
            
            if let error = response.error {
                
                self?.showAlert(title: "Ошибка", message: error.localizedDescription)
                
                CircularSpinner.hide()
            } else if let data = response.data {
                
                
                if let stringData = String(data: data, encoding: .utf8)
                    
                {
                    if stringData.contains("Показания приборов учета приняты") {
                        self?.showAlert(title: "Bingo!", message: "Ваши показания успешно отправлены")
                    } else {
                        self?.showAlert(title: "Ошибка отправки", message: "Что то пошло не так с РКС")
                        print(stringData)
                    }
                }
                
                CircularSpinner.hide()
            }
            
            
            
        }
    }
    
    func showAlert(title: String, message: String){
        let okAction = UIAlertAction(title: "OK", style: .default) {[weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    


}
