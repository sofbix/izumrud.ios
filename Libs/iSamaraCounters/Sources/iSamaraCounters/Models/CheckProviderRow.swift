//
//  CheckProviderRow.swift
//  SamaraCounter
//
//  Created by Sergey Balalaev on 21.04.2021.
//

import Foundation
import BxInputController
import PromiseKit

public let serviceProvidersToSendingDevider : String.Element = ","

public protocol ProgressServiceProtocol {
    func start(with title: String) -> Promise<Data>
}

public protocol CheckProviderProtocol : BxInputRow {
    
    var value: Bool {get}
    
    var serviceName: String {get}

    func updateValue(from serviceProvidersToSending: String)
    
    func addCheckers(for input: SendDataServiceInput)
    func startUpdate(services: inout [Promise<Data>], input: SendDataServiceInput, progressService: ProgressServiceProtocol)

    var isNeedFirstLoad: Bool {get}
    func firstLoadUpdate(services: inout [Promise<Data>], input: SendDataServiceInput, progressService: ProgressServiceProtocol)
}

public class CheckProviderRow<T: SendDataService>: BxInputCheckRow
{

    let service: T
    
    public required init(_ service: T){
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

    public var serviceName: String {
        return service.name
    }

    public func updateValue(from serviceProvidersToSending: String) {
        let serviceProvidersToSending = serviceProvidersToSending
        guard serviceProvidersToSending.isEmpty == false else {
            value = false
            return
        }
        let services = serviceProvidersToSending.split(separator: serviceProvidersToSendingDevider)
        value = services.contains(Substring(serviceName))
    }

    public var isNeedFirstLoad: Bool {
        return service.isNeedFirstLoad
    }
    
}

extension CheckProviderRow: CheckProviderProtocol
{

    public func addCheckers(for input: SendDataServiceInput)
    {
        input.addChecker(createSelfChecker(), for: self)
        service.addCheckers(for: input)
    }

    public func startUpdate(services: inout [Promise<Data>], input: SendDataServiceInput, progressService: ProgressServiceProtocol) {
        if value {
            services.append(progressService.start(with: "Передача в " + service.title))
            services.append(service.start(with: input))
        }
    }

    public func firstLoadUpdate(services: inout [Promise<Data>], input: SendDataServiceInput, progressService: ProgressServiceProtocol) {
        if value {
            if isNeedFirstLoad, let firstLoadPromise = service.firstLoad(with: input) {
                services.append(progressService.start(with: service.title + ": загрузка"))
                services.append(firstLoadPromise)
            }
        }
    }
}
