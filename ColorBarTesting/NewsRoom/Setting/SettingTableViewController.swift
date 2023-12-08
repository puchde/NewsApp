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
    
    let settingSections = [R.string.localizable.settingAppVersionInfo(),
                           R.string.localizable.settingOption(),
                           R.string.localizable.settingOther()
    ]
    let appInfos = [R.string.localizable.settingAppVersion(),]
    let appOptions = [R.string.localizable.settingNewsAPIKey(),
                      R.string.localizable.settingAutoReaderMode(),
                      R.string.localizable.settingCleanMarkedNews()]
    let otherOptions = [R.string.localizable.settingWriteComment(),
                        R.string.localizable.settingSendEmail()]
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
                cell.accessoryView = getAccessLabel(desc: R.string.localizable.settingDefault())
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
            self.presentNoActionAlert(title: R.string.localizable.settingReaderModeTitle(), message: R.string.localizable.settingReaderModeDesc())
        case (1, 2):
            let confirmAct = UIAlertAction(title: R.string.localizable.settingCleanUp(), style: .destructive) { _ in
                newsSettingManager.deleteNewsMarkLists()
            }
            let cancelAct = UIAlertAction(title: R.string.localizable.cancel(), style: .cancel) { _ in
                self.dismiss(animated: true)
            }
            let alert = UIAlertController(title: R.string.localizable.settingCleanMarkedTitle(), message: R.string.localizable.settingCleanMarkedDesc(), preferredStyle: .alert)
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
            let errorAlert = UIAlertController(title: R.string.localizable.settingSendEmailFail(), message: error?.localizedDescription, preferredStyle: .alert)
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
