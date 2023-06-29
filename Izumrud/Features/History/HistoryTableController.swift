//
//  HistoryTableController.swift
//  SamaraCounter
//
//  Created by Sergey Balalaev on 25.10.2021.
//

import Foundation
import UIKit
import RealmSwift

class HistoryTableController: UITableViewController
{
    let newSegue = "new"
    let detailsSegue = "details"
    
    private var entities = DatabaseManager.shared.commonRealm.objects(FlatEntity.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableHeaderView = UIButton.createOnView(title: "Новые показания", target: self, action: #selector(new))
        refresh()
    }
    
    func refresh() {
        entities = DatabaseManager.shared.commonRealm.objects(FlatEntity.self).filter("sentDate != nil").sorted(by: \.sentDate, ascending: false)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < entities.count else {
            return UITableViewCell()
        }
        let entity = entities[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        if let sentDate = entity.sentDate {
            cell.textLabel?.text = DateFormatter.shortDateTimeFormatter.string(from: sentDate)
        } else {
            cell.textLabel?.text = "???"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < entities.count else {
            return
        }
        let entity = entities[indexPath.row]
        self.performSegue(withIdentifier: detailsSegue, sender: entity)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return entities.count > 0 ? "Отправленные показания" : "Список отправленных показаний пуст"
    }
    
    @objc func new() {
        self.performSegue(withIdentifier: newSegue, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? FlatCountersDetailsController {
            if segue.identifier == newSegue {
                NavigationRoute.newFlatCounters(for: controller, root: self)
            } else if segue.identifier == detailsSegue, let entity = sender as? FlatEntity {
                NavigationRoute.detailsFlatCounters(for: controller, entity: entity)
            }
        }
    }
    
}
