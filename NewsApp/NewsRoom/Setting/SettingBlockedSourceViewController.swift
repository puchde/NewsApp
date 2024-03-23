//
//  SettingBlockedSourceViewController.swift
//  ColorBarTesting
//
//  Created by Willy on 2023/12/8.
//

import UIKit

class SettingBlockedSourceViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var comfirmButton: UIBarButtonItem!
    
    var blockedSource = Array(newsSettingManager.getBlockedSource()).sorted{ $0 < $1 }
    var selectedRow = Set<Int>() {
        didSet {
            comfirmButton.isEnabled = selectedRow.isEmpty ? false : true
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
extension SettingBlockedSourceViewController {
    func initView() {
        tableView.delegate = self
        tableView.dataSource = self
        comfirmButton = UIBarButtonItem(title: R.string.localizable.unblock(), style: .done, target: self, action: #selector(unblockSource))
        comfirmButton.isEnabled = false
        navigationItem.rightBarButtonItem = comfirmButton
    }
    
    @objc
    func unblockSource() {
        self.presentAlert(title: R.string.localizable.unblockAlertTitle(),
                          message: R.string.localizable.unblockAlertDesc(), action: [
                            UIAlertAction(title: R.string.localizable.cancel(), style: .cancel),
                            UIAlertAction(title: R.string.localizable.unblock(), style: .default, handler: { _ in
                                self.selectedRow.sorted { $0 > $1 }.forEach { num in
                                    self.blockedSource.remove(at: num)
                                }
                                newsSettingManager.updateReplaceBlockedSource(source: self.blockedSource)
                                self.blockedSource = Array(newsSettingManager.getBlockedSource())
                                self.selectedRow.removeAll()
                                self.tableView.reloadData()
                            })
                          ])
    }
}

// MARK: - TableView
extension SettingBlockedSourceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        blockedSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var cellConfig = UIListContentConfiguration.cell()
        cellConfig.text = blockedSource[indexPath.row]
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
