//
//  FlatCountersDetailsController.swift
//  SamaraCounter
//
//  Created by Sergey Balalaev on 20.12.2020.
//

import UIKit

import UIKit
import BxInputController
import CircularSpinner
import Alamofire
import PromiseKit
//import iSamaraCounters

class FlatCountersDetailsController: BxInputController, SendDataServiceInput {
    
    let waterCounterMaxCount = 3
    
    // Input Fields:
    
    var id: String = ""
    var order: Int = 0
    var fields: [String: String] = [:]
    
    override var isEditing: Bool {
        didSet {
            guard isViewLoaded else {
                return
            }
            updateData()
        }
    }
    
    var newBranchHandler: (()-> Void)? = nil
    
    let surnameRow = BxInputTextRow(title: "Фамилия", maxCount: 200, value: "")
    let nameRow = BxInputTextRow(title: "Имя", maxCount: 200, value: "")
    let patronymicRow = BxInputTextRow(title: "Отчества", maxCount: 200, value: "")
    let streetRow = BxInputTextRow(title: "Улица", maxCount: 200, value: "5 ПРОСЕКА")
    let homeNumberRow = BxInputTextRow(title: "Номер дома", maxCount: 5, value: "")
    let flatNumberRow = BxInputTextRow(title: "Номер квартиры", maxCount: 5, value: "")
    let phoneNumberRow = BxInputFormattedTextRow(title: "Телефон", prefix: "+7", format: "(###)###-##-##")
    let emailRow = BxInputTextRow(title: "E-mail", maxCount: 50, value: "")
    let rksAccountNumberRow = BxInputTextRow(title: "Номер счета РКС", subtitle: "если необходим", maxCount: 15, value: "")
    let esPlusAccountNumberRow = BxInputTextRow(title: "Лицевой счёт Т+", subtitle: "если необходим", maxCount: 20, value: "")
    let commentsRow = BxInputTextMemoRow(title: "Коментарии", maxCount: 1000, value: "")

    let electricAccountNumberRow = BxInputTextRow(title: "Лицевой счет", subtitle: "как правило 8 цифр", maxCount: 20, value: "")
    let electricCounterNumberRow = BxInputTextRow(title: "Номер счётчика", maxCount: 20, value: "")
    let dayElectricCountRow = BxInputTextRow(title: "День", subtitle: "целые числа, без дробных", maxCount: 10, value: "")
    let nightElectricCountRow = BxInputTextRow(title: "Ночь", subtitle: "для однофазного счетчика оставте пустым", maxCount: 10, value: "")

    private(set) var waterCounters: [WaterCounterViewModel] = []

    private lazy var servicesRows : [CheckProviderProtocol] = [
        CheckProviderRow(SamGESSendDataService()),
        CheckProviderRow(RKSSendDataService()),
        CheckProviderRow(EsPlusSendDataService()),
        CheckProviderRow(UpravdomSendDataService()),
    ]
    
    private lazy var sendFooter: UIView = UIButton.createOnView(title: "Отправить показания", target: self, action: #selector(start))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        isEstimatedContent = true
        
        homeNumberRow.textSettings.keyboardType = .numberPad
        flatNumberRow.textSettings.keyboardType = .numberPad

        electricAccountNumberRow.textSettings.keyboardType = .numberPad
        electricCounterNumberRow.textSettings.keyboardType = .decimalPad
        dayElectricCountRow.textSettings.keyboardType = .numberPad
        nightElectricCountRow.textSettings.keyboardType = .numberPad
        
        esPlusAccountNumberRow.textSettings.keyboardType = .numberPad
        
        
        updateData()
        
        URLSessionConfiguration.default.timeoutIntervalForRequest = 60
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firstLoadIfNeeded(servicesRows)
    }

    private func updateRow(_ row: BxInputTextRow, with fieldName: String, defaultValue: String) {
        if let value = fields[fieldName] {
            row.value = value
        } else {
            row.value = defaultValue
        }
    }
    
    private func updateData() {
        
        var flatEntity = FlatEntity()
        
        if id.isEmpty == false, let entity = DatabaseManager.shared.commonRealm.object(ofType: FlatEntity.self, forPrimaryKey: id)
        {
            flatEntity = entity
        } else if let entity = DatabaseManager.shared.commonRealm.objects(FlatEntity.self).filter("sentDate == nil").first {
            flatEntity = entity
        } else {
            DatabaseManager.shared.commonRealm.beginWrite()
            flatEntity.id = UUID().uuidString
            flatEntity.order = 1 // for a future multi flat
            // New counters sending to all Services:
            flatEntity.serviceProvidersToSending = servicesRows.map{ row -> String in
                return row.serviceName
            }.joined(separator: String(FlatEntity.serviceProvidersToSendingDevider))
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

        updateRow(surnameRow, with: "surname", defaultValue: flatEntity.surname)
        updateRow(nameRow, with: "name", defaultValue: flatEntity.name)
        updateRow(patronymicRow, with: "patronymic", defaultValue: flatEntity.patronymic)
        updateRow(homeNumberRow, with: "homeNumber", defaultValue: flatEntity.homeNumber)
        updateRow(flatNumberRow, with: "flatNumber", defaultValue: flatEntity.flatNumber)
        updateRow(phoneNumberRow, with: "phoneNumber", defaultValue: flatEntity.phoneNumber)
        updateRow(emailRow, with: "email", defaultValue: flatEntity.email)
        updateRow(rksAccountNumberRow, with: "rksAccountNumber", defaultValue: flatEntity.rksAccountNumber)
        updateRow(esPlusAccountNumberRow, with: "esPlusAccountNumber", defaultValue: flatEntity.esPlusAccountNumber)
        updateRow(commentsRow, with: "comments", defaultValue: flatEntity.comments)


        updateRow(electricAccountNumberRow, with: "electricAccountNumber", defaultValue: flatEntity.electricAccountNumber)
        updateRow(electricCounterNumberRow, with: "electricCounterNumber", defaultValue: flatEntity.electricCounterNumber)
        updateRow(dayElectricCountRow, with: "dayElectricCount", defaultValue: flatEntity.dayElectricCount)
        updateRow(nightElectricCountRow, with: "nightElectricCount", defaultValue: flatEntity.nightElectricCount)
        
        var sections = [
            BxInputSection(headerText: "Данные собственника",
                           rows: [surnameRow, nameRow, patronymicRow, homeNumberRow, flatNumberRow, phoneNumberRow, emailRow, rksAccountNumberRow, esPlusAccountNumberRow],
                           footerText: nil),
            BxInputSection(headerText: "Комментарии для УК", rows: [commentsRow], footerText: nil),
            BxInputSection(headerText: "Показания электрического счётчика", rows: [electricAccountNumberRow, electricCounterNumberRow, dayElectricCountRow, nightElectricCountRow], footerText: nil)
        ]
        
        waterCounters = []
        for (index, waterCounterEntity) in flatEntity.waterCounters.enumerated() {
            let waterCounter = WaterCounterViewModel(entity: waterCounterEntity, fields: fields, index: index)
            
            waterCounters.append(waterCounter)
            sections.append(waterCounter.section)
        }
        
        // New Water Counter
        if waterCounters.count < waterCounterMaxCount && isEditing {
            let waterCounter = WaterCounterViewModel()
            
            waterCounters.append(waterCounter)
            sections.append(waterCounter.section)
        }
        
        servicesRows.forEach{ row in
            row.updateValue(flatEntity)
        }
        let servicesSection = BxInputSection(headerText: "Куда отправляем", rows: servicesRows, footerText: "Выберите поставщиков комунальных услуг, для которых требуется отправлять показания приборов")
        sections.append(servicesSection)
        
        
        if isEditing {
            sections.append(BxInputSection(headerText: "Проверьте данные и нажмите:", rows: [], footerText: nil))
            sections.append(BxInputSection(header: BxInputSectionView(sendFooter), rows: []))
        }
        
        self.sections = sections
        updateCheckers()
        setEnabled(isEditing, with: .none)
    }
    
    private func updateCheckers(){
        for row in servicesRows {
            row.addCheckers(for: self)
        }
    }
    
    private func branchAllFlatData(){
        if let flatEntity = DatabaseManager.shared.commonRealm.object(ofType: FlatEntity.self, forPrimaryKey: id)
        {
            DatabaseManager.shared.commonRealm.beginWrite()
            let flatEntity = FlatEntity(value: flatEntity)
            flatEntity.id = UUID().uuidString
            flatEntity.sentDate = Date()
            let waterCounters: [WaterCounterEntity] = flatEntity.waterCounters.map{ counter in
                let counter = WaterCounterEntity(value: counter)
                counter.id = UUID().uuidString
                DatabaseManager.shared.commonRealm.add(counter, update: .error)
                return counter
            }
            flatEntity.waterCounters.removeAll()
            flatEntity.waterCounters.append(objectsIn: waterCounters)
            DatabaseManager.shared.commonRealm.add(flatEntity, update: .error)
            do {
                try DatabaseManager.shared.commonRealm.commitWrite()
            } catch let error {
                DatabaseManager.shared.commonRealm.cancelWrite()
                showAlert(title: "Ошибка данных", message: "Данные в телефоне сохранены не будут: \(error)")
            }
            newBranchHandler?()
        } else {
            showAlert(title: "Ошибка данных", message: "Данные в телефоне сохранены не будут")
        }
    }
    
    private func saveFlatData(){
        if let flatEntity = DatabaseManager.shared.commonRealm.object(ofType: FlatEntity.self, forPrimaryKey: id)
        {
            DatabaseManager.shared.commonRealm.beginWrite()
            
            flatEntity.sentDate = nil
            
            flatEntity.surname = surnameRow.value ?? ""
            flatEntity.name = nameRow.value ?? ""
            flatEntity.patronymic = patronymicRow.value ?? ""
            flatEntity.homeNumber = homeNumberRow.value ?? ""
            flatEntity.flatNumber = flatNumberRow.value ?? ""
            flatEntity.phoneNumber = phoneNumberRow.value ?? ""
            flatEntity.email = emailRow.value ?? ""
            flatEntity.rksAccountNumber = rksAccountNumberRow.value ?? ""
            flatEntity.esPlusAccountNumber = esPlusAccountNumberRow.value ?? ""
            flatEntity.comments = commentsRow.value ?? ""
            
            #warning("Please check dayElectricCountRow & nightElectricCountRow to Int values")

            flatEntity.electricAccountNumber = electricAccountNumberRow.value ?? ""
            flatEntity.electricCounterNumber = electricCounterNumberRow.value ?? ""
            flatEntity.dayElectricCount = dayElectricCountRow.value ?? ""
            flatEntity.nightElectricCount = nightElectricCountRow.value ?? ""
            
            flatEntity.serviceProvidersToSending = servicesRows.compactMap{ row -> String? in
                if row.value {
                    return row.serviceName
                }
                return nil
            }.joined(separator: String(FlatEntity.serviceProvidersToSendingDevider))
            
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
    
    private func saveData(waterCounter: WaterCounterViewModel){
        guard let flatEntity = DatabaseManager.shared.commonRealm.object(ofType: FlatEntity.self, forPrimaryKey: id) else
        {
            return
        }
        if let waterCounterEntity = DatabaseManager.shared.commonRealm.object(ofType: WaterCounterEntity.self, forPrimaryKey: waterCounter.id)
        {
            DatabaseManager.shared.commonRealm.beginWrite()
            var isRemove = false
            if waterCounter.isValid {
                let waterCounterEntity = waterCounter.entity
                DatabaseManager.shared.commonRealm.add(waterCounterEntity, update: .modified)
            } else {
                if let index = flatEntity.waterCounters.index(of: waterCounterEntity){
                    flatEntity.waterCounters.remove(at: index)
                    isRemove = true
                }
                var index = 1
                flatEntity.waterCounters.forEach { entity in
                    flatEntity.order = index
                    index += 1
                }
                DatabaseManager.shared.commonRealm.delete(waterCounterEntity)
            }
            do {
                try DatabaseManager.shared.commonRealm.commitWrite()
                if isRemove {
                    updateData()
                }
            } catch let error {
                DatabaseManager.shared.commonRealm.cancelWrite()
                showAlert(title: "Ошибка данных", message: "Данные в телефоне сохранены не будут: \(error)")
            }
        } else {
            DatabaseManager.shared.commonRealm.beginWrite()
            let waterCounterEntity = waterCounter.entity
            waterCounterEntity.id = UUID().uuidString
            
            let waterCounterOrder : Int = flatEntity.waterCounters.max(of: \.order) ?? 0
            waterCounterEntity.order = waterCounterOrder + 1
            DatabaseManager.shared.commonRealm.add(waterCounterEntity, update: .all)
            flatEntity.waterCounters.append(waterCounterEntity)
            do {
                try DatabaseManager.shared.commonRealm.commitWrite()
                updateData()
            } catch let error {
                DatabaseManager.shared.commonRealm.cancelWrite()
                showAlert(title: "Ошибка данных", message: "Данные в телефоне сохранены не будут: \(error)")
            }
        }
    }
    
    private func saveData(for row: BxInputValueRow) {
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
        if let checkProviderRow = row as? CheckProviderProtocol {
            firstLoadIfNeeded([checkProviderRow])
        }
        saveData(for: row)
    }
    
    @objc
    private func start() {
        startServices()
    }
    
    private func firstLoadIfNeeded(_ servicesRows : [CheckProviderProtocol]) {
        var services : [Promise<Data>] = []

        servicesRows.forEach{ row in
            if isEditing, row.value {
                row.firstLoadUpdate(services: &services, input: self)
            }
        }
        when(fulfilled: services)
        .done { datas in
            CircularSpinner.hide()
        }.catch {[weak self] error in
            CircularSpinner.hide()
            self?.showAlert(title: "Ошибка", message: error.localizedDescription)
        }
    }
    
    private func startServices() {
        
        var services : [Promise<Data>] = []
        servicesRows.forEach{ row in
            row.startUpdate(services: &services, input: self)
        }
        guard services.count > 0 else {
            showAlert(title: "Ошибка", message: "Выберите хотябы одного провайдера в 'Куда отправляем'")
            return
        }
        when(fulfilled: services)
        .done {[weak self] datas in
            self?.branchAllFlatData()
            CircularSpinner.hide()
            self?.showAlert(title: "Bingo!", message: "Ваши показания успешно отправлены"){
                self?.navigationController?.popViewController(animated: true)
            }
        }.catch {[weak self] error in
            CircularSpinner.hide()
            self?.showAlert(title: "Ошибка", message: error.localizedDescription)
        }
    }
    
    private func showAlert(title: String, message: String, handler : (() -> Void)? = nil){
        let okAction = UIAlertAction(title: "OK", style: .default) {[weak self] _ in
            self?.dismiss(animated: true, completion: handler)
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    


}



