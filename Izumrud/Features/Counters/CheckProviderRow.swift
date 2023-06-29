//
//  CheckProviderRow.swift
//  SamaraCounter
//
//  Created by Sergey Balalaev on 21.04.2021.
//

import Foundation
import BxInputController
import PromiseKit
import iSamaraCounters

protocol CheckProviderProtocol : BxInputRow {
    
    var value: Bool {get}
    
    var serviceName: String {get}

    func updateValue(_ entity: FlatEntity)
    
    func addCheckers(for input: SendDataServiceInput)
    func startUpdate(services: inout [Promise<Data>], input: SendDataServiceInput)

    var isNeedFirstLoad: Bool {get}
    func firstLoadUpdate(services: inout [Promise<Data>], input: SendDataServiceInput)
}

class CheckProviderRow<T: SendDataService>: BxInputCheckRow
{

    let service: T
    
    required init(_ service: T){
        self.service = service
        super.init(title: service.title, subtitle: nil, placeholder: nil, value: true)
    }
    
    fileprivate func createSelfChecker() -> BxInputRowChecker {
        let checker = BxInputBlockChecker(row: self)
        checker.handler =
        {[weak checker, weak self] (row: CheckProviderRow) -> Bool in
            guard let this = self, let checker = checker else {
                return false
            }
            guard this.value else {
                return true
            }
            if let errorMessage = this.service.firstlyCheckAvailable() {
                let decorator = BxInputStandartErrorRowDecorator()
                decorator.subtitle = errorMessage
                checker.decorator = decorator
                return false
            }
            return true
        }
        return checker
    }

    var serviceName: String {
        return service.name
    }

    func updateValue(_ entity: FlatEntity) {
        let serviceProvidersToSending = entity.serviceProvidersToSending
        guard serviceProvidersToSending.isEmpty == false else {
            value = false
            return
        }
        let services = serviceProvidersToSending.split(separator: FlatEntity.serviceProvidersToSendingDevider)
        value = services.contains(Substring(serviceName))
    }

    var isNeedFirstLoad: Bool {
        return service.isNeedFirstLoad
    }
    
}

extension CheckProviderRow: CheckProviderProtocol
{

    func addCheckers(for input: SendDataServiceInput)
    {
        input.addChecker(createSelfChecker(), for: self)
        service.addCheckers(for: input)
    }

    func startUpdate(services: inout [Promise<Data>], input: SendDataServiceInput) {
        if value {
            services.append(ProgressService().start(with: "Передача в " + service.title))
            services.append(service.start(with: input))
        }
    }

    func firstLoadUpdate(services: inout [Promise<Data>], input: SendDataServiceInput) {
        if value {
            if isNeedFirstLoad, let firstLoadPromise = service.firstLoad(with: input) {
                services.append(ProgressService().start(with: service.title + ": загрузка"))
                services.append(firstLoadPromise)
            }
        }
    }
}
