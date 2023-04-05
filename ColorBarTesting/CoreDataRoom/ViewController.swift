//
//  ViewController.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2022/10/24.
//

import UIKit
import CoreML
import Photos
import Vision


class ViewController: UIViewController {
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var addModelbutton: UIButton!
    @IBOutlet weak var modelTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // DocumentPicker
    let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.image, UTType.item], asCopy: true)
    var localPickerUI: UIDocumentPickerViewController?
    var pickedFolderURL = URL(string: "")
    var openFileType = FileType.none
    
    // Data
    var typeDic: [String:[String]] = [:]
    var dataArr: [String] = []
    var failDataName: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initStep()
    }
    
    @IBAction func addButtonAct(_ sender: Any) {
        openFileType = .Image
        performSegue(withIdentifier: "toSheetVC", sender: sender)
    }
    @IBAction func addModelBtnClick(_ sender: Any) {
        openFileType = .Model
        performSegue(withIdentifier: "toSheetVC", sender: sender)
    }
}

//MARK: VC Init
extension ViewController {
    func initStep() {
        tableView.delegate = self
        tableView.dataSource = self
        mlModelManager.changeModel(name: TabbarColorClassifier1027().model.configuration.modelDisplayName!, model: TabbarColorClassifier1027().model)
        updateModelTitle()
        if localFileManager.urlForUbiquityContainerIdentifier() != nil {
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = true
            documentPicker.modalPresentationStyle = .fullScreen
        }else{
            print("請登入ICloud")
        }
        
    }
}


//MARK: TableView
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataArr[section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return typeDic[dataArr[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReuseCell", for: indexPath)
        guard let title = typeDic[dataArr[indexPath.section]]?[indexPath.row] else {
            return UITableViewCell()
        }
        cell.textLabel?.text = title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        do{
            guard let urlString = typeDic[dataArr[indexPath.section]]?[indexPath.row] else {
                return
            }
            let docUrls = localFileManager.testDataTotalPath.appendingPathComponent(urlString, conformingTo: .url)
            let data = try Data(contentsOf: docUrls)
            let image = UIImage(data: data)
            guard let imageVC = storyboard?.instantiateViewController(withIdentifier: "ImageViewController") as? ImageViewController else {
                return
            }
            imageVC.image = image
            self.present(imageVC, animated: true)
        }catch{
            ShowTipsAlert(tips: "本地讀取失敗")
            return
        }
    }
}


//MARK: Present file Document
extension ViewController: SheetVCDelegate {
    func resetTableData() {
        viewDataClean()
    }
    
    func presentDocument(fileSource: FileSource) {
        switch fileSource {
        case .Icloud:
            documentPicker.allowsMultipleSelection = openFileType == .Image ? true : false
            present(documentPicker, animated: true)
        case .Local:
            switch openFileType {
            case .Image:
                guard let fileUrls = localFileManager.getDirectoryContents(path: localFileManager.testDataTotalPath), !fileUrls.isEmpty else {
                    ShowTipsAlert(tips: "尚未選取檔案")
                    return
                }
                 modelTesting(urls: fileUrls, writeToLocal: false)
                break
            case .Model:
                //MARK: 逮捕
                guard let modelSelectVC = storyboard?.instantiateViewController(withIdentifier: "ModelSelectViewController") as? ModelSelectViewController else {
                    return
                }
                modelSelectVC.delegate = self
                present(modelSelectVC, animated: true)
                break
            default:
                break
            }
        case .none:
            return
        }
    }
}


//MARK: UIDocument (Icloud)
extension ViewController: UIDocumentPickerDelegate,UINavigationControllerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        self.pickedFolderURL = urls.first!
        switch openFileType {
        case .Image:
            modelTesting(urls: urls)
            break
            
        case .Model:
            let url = urls.first!
            //開啟權限並讀取
            let writeToUrl = localFileManager.modelPath
            url.startAccessingSecurityScopedResource()
            checkAndDownloadFile(fileType: .Model, fileUrl: url, writeToUrl: writeToUrl)
            
            DispatchQueue.global().async {
                do{
                    let filePath = localFileManager.modelPath.appendingPathComponent(url.lastPathComponent, conformingTo: .url)
                    let modelName = url.lastPathComponent
                    let model = try MLModel(contentsOf: MLModel.compileModel(at: filePath))
                    mlModelManager.changeModel(name: modelName, model: model)
                    DispatchQueue.main.sync {
                        self.updateModelTitle()
                        self.viewDataClean()
                    }
                }catch{
                    self.ShowTipsAlert(tips: "Model讀取失敗")
                }
            }
            url.stopAccessingSecurityScopedResource()
            break
            
        case .none:
            break
        }
    }
}


//MARK: Model Change
extension ViewController: ModelSelectDelegate {
    func updateModelTitle() {
        if #available(iOS 16.0, *) {
            modelTitle.text = mlModelManager.getModelName()
        } else {
            modelTitle.text = "Model"
        }
    }
}


//MARK: Model Testing
extension ViewController {
    func modelTesting(urls: [URL], writeToLocal: Bool = true) {
        
        viewDataClean()
        
        guard let model = mlModelManager.getVNCoreModel() else {
            ShowTipsAlert(tips: "Model載入失敗")
            return
        }

        let writeToUrl = localFileManager.testDataTotalPath
        localFileManager.creatFolder(rootFolderUrl: localFileManager.testDataPath, folderName: localFileManager.subFolder.total)

        urls.forEach { url in
            let fileName = url.lastPathComponent
            //開啟權限並讀取
            url.startAccessingSecurityScopedResource()
            
            if writeToLocal {
                //Write to local
                checkAndDownloadFile(fileType: .Image, fileUrl: url, writeToUrl: writeToUrl)
            }
            
            //ModelRequest
            let request = VNCoreMLRequest(model: model) { request, error in
                guard let result = request.results?.first as? VNClassificationObservation else {
                    return
                }
                self.dataArrAppend(dataType: result.identifier, fileName: fileName)
            }
            
            do {
                try VNImageRequestHandler(url: url).perform([request])
            }catch{
                ShowTipsAlert(tips: "檔案類型錯誤")
            }
            url.stopAccessingSecurityScopedResource()
        }
        
        for type in typeDic.keys {
            dataArr.append(type)
        }
        
        showImageFail()
        tableView.reloadData()
    }
}


//MARK: Local Data Check & Saving
extension ViewController {
    func checkAndDownloadFile(fileType: FileType, fileUrl: URL, writeToUrl: URL) {
        let fileName = fileUrl.lastPathComponent
        
        //Check Type
        if fileUrl.urlType != fileType {
            checkImageFail(name: fileName)
            return
        }
        
        //Write to local
        let data = NSData(contentsOf: fileUrl)
        data?.write(to: writeToUrl.appendingPathComponent(fileName).absoluteURL, atomically: true)
        print("docUrl: \(writeToUrl), file isExist: \(localFileManager.fileExist(docPath: writeToUrl.appendingPathComponent(fileUrl.lastPathComponent).path))")
    }
}


//MARK: Array Data
extension ViewController {
    func viewDataClean() {
        typeDic.removeAll()
        dataArr.removeAll()
        failDataName.removeAll()
        tableView.reloadData()
    }
    
    func dataArrAppend(dataType: String, fileName: String) {
        if self.typeDic[dataType] == nil {
            self.typeDic[dataType] = []
        }
        self.typeDic[dataType]?.append(fileName)
    }
    
    func checkImageFail(name: String) {
        failDataName.append(name)
    }
    
    func showImageFail() {
        if !failDataName.isEmpty{
            var message = ""
            failDataName.forEach { name in
                message += name + "\n"
            }
            ShowTipsAlert(tips: "讀取失敗:\n\(message)")
        }
    }
}


//MARK: TipsAlert
extension ViewController {
    func ShowTipsAlert(tips: String) {
        DispatchQueue.main.async {
            self.present(UIAlertController(title: "\(tips)", message: "", preferredStyle: .alert), animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.dismiss(animated: true)
                }
            }
            print("Error_\(tips)")
        }
    }
}


//MARK: Segue
extension ViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sheetVC = segue.destination as? SheetViewController {
            sheetVC.openFileType = openFileType
            sheetVC.delegate = self
        }
    }
}
