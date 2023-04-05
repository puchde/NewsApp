//
//  SheetViewController.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2022/11/25.
//

import UIKit

protocol SheetVCDelegate {
    func presentDocument(fileSource: FileSource)
    func resetTableData()
}

class SheetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var cellIsEdit = false
    var openFileType: FileType = FileType.none
    var fileSource: FileSource = FileSource.none
    var delegate: SheetVCDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        self.sheetPresentationController?.detents = [.medium()]
    }
}

extension SheetViewController {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "選擇來源"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SheetCell", for: indexPath)
        cell.textLabel?.font =  UIFont.systemFont(ofSize: UIFont.systemFontSize + 5)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "ICloud"
            cell.imageView?.image = UIImage(systemName: "icloud.and.arrow.down")
        case 1:
            switch openFileType {
            case .Image:
                let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(checkInfo))
                cell.addGestureRecognizer(longPressGesture)
                cell.accessoryType = .detailDisclosureButton
                cell.textLabel?.text = "使用已選取的圖片"
            case .Model:
                cell.textLabel?.text = "選擇已下載的Model"
            default:
                break
            }
            cell.imageView?.image = UIImage(systemName: "folder")
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            fileSource = .Icloud
        case 1:
            fileSource = .Local
        default:
            break
        }
        guard let delegate = delegate else { return }
        self.dismiss(animated: true)
        delegate.presentDocument(fileSource: fileSource)
    }
}


//MARK: Local file action(check to delete)
extension SheetViewController {
    @objc func checkInfo() {
        let deleteAct = UIAlertAction(title: "確定", style: .default) { _ in
            self.localFileClean()
            guard let delegate = self.delegate else { return }
            delegate.resetTableData()
            self.dismiss(animated: true)
        }
        let cancelAct = UIAlertAction(title: "取消", style: .cancel)
        let alert = UIAlertController(title: "刪除已選取圖片", message: "", preferredStyle: .alert)
        alert.addAction(cancelAct)
        alert.addAction(deleteAct)
        present(alert, animated: true)
    }
    
    @objc func localFileClean() {
        localFileManager.deleteTestFile()
    }
}
