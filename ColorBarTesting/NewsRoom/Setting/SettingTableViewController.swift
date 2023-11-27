//
//  SettingTableViewController.swift
//  ColorBarTesting
//
//  Created by Willy on 2023/11/13.
//

import UIKit
import MessageUI

class SettingTableViewController: UIViewController, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var settingTableView: UITableView!
    
    let settingSections = ["版本資訊", "功能選項", "其他"]
    let appInfos = ["版本"]
    let appOptions = ["News API Key", "自動開啟閱讀器模式", "清空已標記的新聞"]
    let otherOptions = ["寫評論", "信件詢問"]
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    
    
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
            cell.accessoryView = getAccessLabel(desc: appVersion)
        case (1, 0):
            content.image = UIImage(systemName: "key")
            if let apiKey = newsSettingManager.getApiKey() {
                cell.accessoryView = getAccessLabel(desc: String("\(apiKey.prefix(5))..."))
            } else {
                cell.accessoryView = getAccessLabel(desc: "預設")
            }
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
        case (1, 1):
            self.presentNoActionAlert(title: "Safari閱讀器模式", message: "\n閱讀器模式可提供簡潔網頁版面，使閱讀更專注並改善文章排版。\n\n若部分複雜網頁顯示不完整，請關閉此選項。")
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
        case (2, 1):
            presentMailVC()
        default:
            return
        }
    }
}

// MARK: - Cell Access
extension SettingTableViewController {
    func getAccessLabel(desc: String) -> UILabel {
        let accessView = UILabel()
        accessView.text = desc
        accessView.sizeToFit()
        return accessView
    }
}

// MARK: - Cell Action
extension SettingTableViewController {
    @objc
    func setAutoRead(sender: UISwitch) {
        newsSettingManager.updateAutoReadMode(isAuto: sender.isOn)
    }
    
    @objc
    func presentMailVC() {
        guard MFMailComposeViewController.canSendMail() else {
            return
        }
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        mailVC.delegate = self
        mailVC.setToRecipients(["puch40435@gmail.com"])
        mailVC.setSubject("關於APP")
        mailVC.setMessageBody("description: \n\n\n\nVersion: \(appVersion)\nDevice Info: \(UIDevice().type) \(UIDevice.current.systemVersion)", isHTML: false)
        present(mailVC, animated: true)
    }
}

extension SettingTableViewController {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            dismiss(animated: true)
        case .saved:
            dismiss(animated: true)
        case .sent:
            dismiss(animated: true)
        case .failed:
            let errorAlert = UIAlertController(title: "發送失敗", message: error?.localizedDescription, preferredStyle: .alert)
            controller.present(errorAlert, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                errorAlert.dismiss(animated: true)
            }
            return
        default:
            dismiss(animated: true)
        }
    }
}
