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
                           R.string.localizable.settingNotification(),
                           R.string.localizable.settingWidgetOption(),
                           R.string.localizable.settingOther()
    ]
    let appInfos = [R.string.localizable.settingAppVersion(),]
    let appOptions = [ R.string.localizable.settingAutoReaderMode(),
                      R.string.localizable.settingCleanMarkedNews(),
                      R.string.localizable.settingBlockPublisherSources(),
                      R.string.localizable.settingICloudBackup()]
    let notificationOptions = [R.string.localizable.settingNotificationManagement()]
    let widgetOptions = [R.string.localizable.settingWidgetOptionCategory()]
    let otherOptions = [R.string.localizable.settingUsageGuide(),
                        R.string.localizable.settingWriteComment(),
                        R.string.localizable.settingSendEmail()]
    
    var appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    lazy var appVersionInfo = appVersion
    
    let formatter = DateFormatter()
    
    var checkVersionDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingTableView.delegate = self
        settingTableView.dataSource = self
        navigationItem.title = R.string.localizable.setting()
        formatter.dateFormat = "yyyy-MM-dd-HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkAppVersionUpdate()
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
            return notificationOptions.count
        case 3:
            return widgetOptions.count
        case 4:
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
            notificationOptions[indexPath.row]
        case 3:
            widgetOptions[indexPath.row]
        case 4:
            otherOptions[indexPath.row]
        default:
            ""
        }
                
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let hasUpdate = newsSettingManager.getAppStoreVersion() > appVersion
            content.image = UIImage(systemName: "info.circle")
            content.imageProperties.tintColor = hasUpdate ? .orange : nil
            self.appVersionInfo = hasUpdate ? "(Update) \(appVersion)" : appVersion
            cell.accessoryView = getAccessLabel(desc: appVersionInfo)
        case (1, 0):
            content.image = UIImage(systemName: "hand.raised")
            let switchButton = UISwitch()
            switchButton.isOn = newsSettingManager.isAutoRead()
            switchButton.addTarget(self, action: #selector(setAutoRead), for: .valueChanged)
            cell.accessoryView = switchButton
        case (1, 1):
            content.image = UIImage(systemName: "xmark.diamond")
        case (1, 2):
            content.image = UIImage(systemName: "slash.circle")
        case (1, 3):
            content.image = UIImage(systemName: "checkmark.icloud")
        case (2, 0):
            content.image = UIImage(systemName: "bell")
        case (3, 0):
            content.image = UIImage(systemName: "checkmark.icloud")
            let widgetCategory = newsSettingManager.getGroupCategory().chineseName
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width / 3, height: 100))
            button.setTitleColor(.secondaryLabel, for: .normal)
            button.setTitle(widgetCategory, for: .normal)
            button.contentHorizontalAlignment = .right
            button.showsMenuAsPrimaryAction = true
            button.menu = UIMenu(title: R.string.localizable.settingWidgetOptionCategory(), options: [.singleSelection], children: [
                getActions(category: .general),
                getActions(category: .business),
                getActions(category: .health),
                getActions(category: .science),
                getActions(category: .technology),
                getActions(category: .sports),
                getActions(category: .entertainment)
            ])
            
            func updateWidgetCategory(category: Category) {
                newsSettingManager.updateGroupCategory(category: category)
                button.setTitle(category.chineseName, for: .normal)
            }
            
            func getActions(category: Category) -> UIAction {
                return UIAction(title: category.chineseName, handler: { _ in
                    updateWidgetCategory(category: category)
                })
            }
            
            cell.accessoryView = button
        case (4, 0):
            content.image = UIImage(systemName: "rectangle.and.hand.point.up.left")
        case (4, 1):
            content.image = UIImage(systemName: "star")
        case (4, 2):
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
            self.presentNoActionAlert(title: R.string.localizable.settingReaderModeTitle(), message: R.string.localizable.settingReaderModeDesc())
        case (1, 1):
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
        case (1, 2):
            print("blocked:\(newsSettingManager.getBlockedSource())")
            if let vc = R.storyboard.newsContent.settingBlockedSourceViewController() {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case (1, 3):
            iCloudBackup()
        case (2, 0):
            if newsSettingManager.notificationState {
                if let vc = R.storyboard.newsContent.settingNotificationViewController() {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .cancel)
                let settingsAction = UIAlertAction(title: R.string.localizable.go(), style: .default) { _ in
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                          UIApplication.shared.canOpenURL(settingsUrl) else {
                        return
                    }

                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
                self.presentAlert(title: R.string.localizable.settingNotificationToSettingTitle(), message: R.string.localizable.settingNotificationToSettingDesc(), action: [cancelAction, settingsAction])
            }
        case (3, 0):
            self.presentNoActionAlert(title: R.string.localizable.settingWidgetOptionInfoTitle(), message: R.string.localizable.settingWidgetOptionInfoDesc())
        case (4, 0):
            let vc = getGuideViewSwiftUI()
            present(vc, animated: true)
        case (4, 1):
            if let url = URL(string: "itms-apps://itunes.apple.com/app/id6474076097") {
                UIApplication.shared.open(url)
            }
        case (4, 2):
            presentMailVC()
        default:
            return
        }
    }
}

// MARK: - Cell Selected Action
extension SettingTableViewController {
    func iCloudBackup() {
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .cancel)
        if newsSettingManager.icloudState {
            let iCloudData = cloudDefaults.data(forKey: UserdefaultKey.icloudMarkList.rawValue)
            let iCloudDateStr = cloudDefaults.string(forKey: UserdefaultKey.icloudMarkListDate.rawValue)
            let iCloudDate = {
                if let dateStr = iCloudDateStr,
                   let date = self.formatter.date(from: dateStr) {
                    return self.formatter.string(from: date)
                }
                return "-"
            }()
            
            // iCloud List Preview
            let showListAction = UIAlertAction(title: "list", style: .default) { _ in
                if let data = iCloudData,
                   let markList = try? JSONDecoder().decode([MarkedArticle].self, from: data) {
                    guard !markList.isEmpty else {
                        self.view.makeToast(R.string.localizable.settingDownloadMarkFailure())
                        return
                    }
                    let list = markList.map({MarkedArticleSUI(mark: $0.mark, article: $0.article)})
                    let vc = self.getiCloudNewsListSwiftUI(news: list)
                    vc.modalPresentationStyle = .pageSheet
                    vc.isModalInPresentation = true
                    self.present(vc, animated: true)
                } else {
                    self.view.makeToast("no icloud data")
                }
            }
            
            let uploadAction = UIAlertAction(title: R.string.localizable.settingUploadMark(), style: .default) { _ in
                let confirmAction = UIAlertAction(title: R.string.localizable.confirm(), style: .destructive) { _ in
                    let markList = newsSettingManager.getNewsMarkList()
                    do {
                        let data = try JSONEncoder().encode(markList)
                        cloudDefaults.set(data, forKey: UserdefaultKey.icloudMarkList.rawValue)
                        cloudDefaults.set(self.formatter.string(from: Date.now), forKey: UserdefaultKey.icloudMarkListDate.rawValue)
                        print("upload")
                        self.view.makeToast(R.string.localizable.settingUploadMarkSuccess())
                    } catch {
                        return
                    }
                }
                                        
                self.presentAlert(title: R.string.localizable.settingSyncMarkCheckTitle(), message: iCloudDate, action: [cancelAction, confirmAction], preferredStyle: .actionSheet)
            }
            
            let syncAction = UIAlertAction(title: R.string.localizable.settingDownloadMark(), style: .default) { _ in
                if let data = iCloudData {
                    do {
                        let markList = try JSONDecoder().decode([MarkedArticle].self, from: data)
                        guard !markList.isEmpty else {
                            self.view.makeToast(R.string.localizable.settingDownloadMarkFailure())
                            return
                        }
                        
                        let confirmAction = UIAlertAction(title: R.string.localizable.confirm(), style: .destructive) { _ in
                            newsSettingManager.overwriteNewsMarkList(markList)
                            self.view.makeToast(R.string.localizable.settingDownloadMarkSuccess())
                        }
                                                
                        self.presentAlert(title: R.string.localizable.settingSyncMarkCheckTitle(), message: R.string.localizable.settingSyncMarkCheckDesc(iCloudDate), action: [cancelAction, confirmAction], preferredStyle: .actionSheet)
                    } catch {
                        print(error)
                        return
                    }
                } else {
                    self.view.makeToast(R.string.localizable.settingDownloadMarkFailure())
                }
            }

            self.presentAlert(title: R.string.localizable.settingIcloudTitle(), message: R.string.localizable.settingIcloudDesc(), action: [showListAction, uploadAction, syncAction, cancelAction], preferredStyle: .actionSheet)
        } else {
            let settingsAction = UIAlertAction(title: R.string.localizable.go(), style: .default) { _ in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                      UIApplication.shared.canOpenURL(settingsUrl) else {
                    return
                }

                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
            self.presentAlert(title: R.string.localizable.settingIcloudToSettingTitle(), message: R.string.localizable.settingIcloudToSettingDesc(), action: [cancelAction, settingsAction], preferredStyle: .actionSheet)
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

//MARK: Check AppStore Update
extension SettingTableViewController {
    func checkAppVersionUpdate() {
        appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        if checkVersionDate.addingTimeInterval(24*60*60) < Date() {
            checkVersionDate = Date()
            _ = try? getAppStoreVersion { (versionNum, error) in
                if let error = error {
                    print(error)
                } else {
                    let version = versionNum ?? "1.0"
                    newsSettingManager.updateAppStoreVersion(version)
                    DispatchQueue.main.async {
                        self.settingTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    }
                }
            }
        } else {
            settingTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        
        enum VersionError: Error {
            case invalidResponse, invalidBundleInfo
        }

        @discardableResult
        func getAppStoreVersion(completion: @escaping (String?, Error?) -> Void) throws -> URLSessionDataTask {
            // For Test
//            var identifier = ""

            guard let info = Bundle.main.infoDictionary,
                let identifier = info["CFBundleIdentifier"] as? String,
                let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                    throw VersionError.invalidBundleInfo
            }
                
            let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData)
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                do {
                    if let error = error { throw error }
                    
                    guard let data = data else { throw VersionError.invalidResponse }
                                
                    let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
                                
                    guard let result = (json?["results"] as? [Any])?.first as? [String: Any], let lastVersion = result["version"] as? String else {
                        throw VersionError.invalidResponse
                    }
                    completion(lastVersion, nil)
                } catch {
                    completion(nil, error)
                }
            }
            
            task.resume()
            return task
        }
    }
}
