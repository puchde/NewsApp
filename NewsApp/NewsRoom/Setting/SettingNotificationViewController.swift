//
//  SettingNotificationViewController.swift
//  NewsApp
//
//  Created by Willy on 2024/3/29.
//

import UIKit
import FirebaseMessaging

class SettingNotificationViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var confirmButton: UIBarButtonItem!

    let category = Category.allCases
    var subscribedCategory = Array(newsSettingManager.getSubscribeCategory()).sorted{ $0 < $1 }
    var selectedRow = Set<Int>() {
        didSet {
            confirmButton.isEnabled = selectedRow.count < 4 ? true : false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.popViewController(animated: false)
    }
}

// MARK: - Init
extension SettingNotificationViewController {
    func initView() {
        tableView.delegate = self
        tableView.dataSource = self
        confirmButton = UIBarButtonItem(title: R.string.localizable.update(), style: .done, target: self, action: #selector(subscribeAction))
        navigationItem.rightBarButtonItem = confirmButton
    }
    
    @objc
    func subscribeAction() {
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .cancel)
        let confirmAction = UIAlertAction(title: R.string.localizable.update(), style: .default) { _ in
            var selected = [Category]()
            self.selectedRow.sorted{ $0 > $1 }.forEach { num in
                selected.append(self.category[num])
            }
            
            // 篩選解除訂閱 (已訂閱 && 此次未選中)
            selected.forEach { c in
                if self.subscribedCategory.contains(c.rawValue) {
                    self.subscribedCategory = self.subscribedCategory.filter({ $0 != c.rawValue})
                }
                print(self.subscribedCategory)
            }
            
            self.subscribedCategory.forEach { categoryStr in
                print("unsub", categoryStr)
                Messaging.messaging().unsubscribe(fromTopic: categoryStr)
            }
            
            selected.forEach { category in
                print("sub", category)
                Messaging.messaging().subscribe(toTopic: category.rawValue)
            }
            
            newsSettingManager.updateSubscribeCategory(category: selected.map({$0.rawValue}))
            self.navigationController?.popViewController(animated: true)
        }
        
        var desc = selectedRow.isEmpty ? R.string.localizable.subscribeAlertDescUnsub() : R.string.localizable.subscribeAlertDesc()
        self.presentAlert(title: R.string.localizable.subscribeAlertTitle(), message: desc, action: [cancelAction, confirmAction])
    }
}

// MARK: - TableView
extension SettingNotificationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        category.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var cellConfig = UIListContentConfiguration.cell()
        cellConfig.image = subscribedCategory.contains(category[indexPath.row].rawValue) ? UIImage(systemName: "bell.square.fill") : UIImage(systemName: "square")
        cellConfig.text = category[indexPath.row].chineseName
        cell.contentConfiguration = cellConfig
        cell.accessoryType = selectedRow.contains(indexPath.row) ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedRow.contains(indexPath.row) {
            selectedRow.remove(indexPath.row)
        } else {
            selectedRow.insert(indexPath.row)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewCell().frame.height + 5
    }
}
