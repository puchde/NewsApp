//
//  SettingTableViewController.swift
//  ColorBarTesting
//
//  Created by Willy on 2023/11/13.
//

import UIKit

class SettingTableViewController: UIViewController {
    @IBOutlet var settingTableView: UITableView!
    
    let settingSections = ["版本資訊", "功能選項", "其他"]
    let appInfos = ["版本"]
    let appOptions = ["News API Key", "自動開啟閱讀器模式", "清空已標記的新聞"]
    let otherOptions = ["寫評論", "信件詢問"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingTableView.delegate = self
        settingTableView.dataSource = self
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

// MARK: - Table Seciton Header
extension SettingTableViewController {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingSections[section]
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
}

// MARK: - Table view data source
extension SettingTableViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return appInfos.count
        case 1:
            return appOptions.count
        case 2:
            return otherOptions.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = switch indexPath.section {
        case 0:
            appInfos[indexPath.row]
        case 1:
            appOptions[indexPath.row]
        case 2:
            otherOptions[indexPath.row]
        default:
            ""
        }
                
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            content.image = UIImage(systemName: "info.circle")
            cell.accessoryView = getAccessLabel(desc: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
        case (1, 0):
            content.image = UIImage(systemName: "key")
            cell.accessoryView = getAccessLabel(desc: appOptions[indexPath.row])
        case (1, 1):
            content.image = UIImage(systemName: "hand.raised")
            let switchButton = UISwitch()
            switchButton.isOn = newsSettingManager.isAutoRead()
            switchButton.addTarget(self, action: #selector(setAutoRead), for: .valueChanged)
            cell.accessoryView = switchButton
        case (1, 2):
            content.image = UIImage(systemName: "xmark.diamond")
        case (2, 0):
            content.image = UIImage(systemName: "star")
        case (2, 1):
            content.image = UIImage(systemName: "envelope")
        default:
            break
        }
        
        cell.contentConfiguration = content

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (1, 0):
            print("api")
        case (1, 2):
            let confirmAct = UIAlertAction(title: "清空", style: .destructive) { _ in
                newsSettingManager.deleteNewsMarkLists()
            }
            let cancelAct = UIAlertAction(title: "取消", style: .cancel) { _ in
                self.dismiss(animated: true)
            }
            let alert = UIAlertController(title: "清空Mark列表", message: "此動作會清空所有已標記的新聞", preferredStyle: .alert)
            alert.addAction(cancelAct)
            alert.addAction(confirmAct)
            self.present(alert, animated: true)
        default:
            return
        }
    }
}

extension SettingTableViewController {
    func getAccessLabel(desc: String) -> UILabel {
        let accessView = UILabel()
        accessView.text = desc
        accessView.sizeToFit()
        return accessView
    }
    
    @objc
    func setAutoRead(sender: UISwitch) {
        newsSettingManager.updateAutoReadMode(isAuto: sender.isOn)
    }
}
