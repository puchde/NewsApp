//
//  DetailSheetViewcontroller.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2022/11/25.
//

import UIKit
import CoreML

protocol ModelSelectDelegate {
    func updateModelTitle()
}

class ModelSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var modelArr: [String] = []
    var delegate: ModelSelectDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.sheetPresentationController?.detents = [.medium()]
        let fileUrls = localFileManager.getDirectoryContents(path: localFileManager.modelPath)
        fileUrls?.forEach({ url in
            modelArr.append(url.lastPathComponent)
        })
                
    }
}

extension ModelSelectViewController {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "選擇Model"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModelCell", for: indexPath)
        let isSelectModel = modelArr[indexPath.row] == mlModelManager.getModelName()
        cell.textLabel?.font = UIFont.systemFont(ofSize: UIFont.systemFontSize + 5)
        cell.textLabel?.text = modelArr[indexPath.row]
        cell.backgroundColor = isSelectModel ? .systemPink : .systemBackground
        cell.layer.borderColor = CGColor.init(red: 1, green: 0, blue: 0, alpha: 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let modelName = self.modelArr[indexPath.row]
        let filePath = localFileManager.modelPath.appendingPathComponent(modelName, conformingTo: .url)
        mlModelManager.changeModelName(name: modelName)
        DispatchQueue.global().async {
            do {
                let model = try MLModel(contentsOf: MLModel.compileModel(at: filePath))
                mlModelManager.changeModel(name: modelName, model: model)
                DispatchQueue.main.async {
                    guard let delegate = self.delegate else { return }
                    delegate.updateModelTitle()
                }
            }catch{
                print("change model error: \(error)")
            }
        }
        tableView.reloadData()
    }
}
