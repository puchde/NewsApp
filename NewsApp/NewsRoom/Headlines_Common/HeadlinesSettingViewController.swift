//
//  HeadlinesSettingViewController.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/4.
//

import UIKit
import FirebaseMessaging

class HeadlinesSettingViewController: UIViewController {

    @IBOutlet weak var countryPickerView: UIPickerView!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    
    var countrys = CountryCode.allCases
    var category = Category.allCases
    
    var isFirstHeightSetting = true
    var reloadNotificationPost = false
    
    var unsubscribeCountry: CountryCode = newsSettingManager.getCountry()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countryPickerView.delegate = self
        countryPickerView.dataSource = self
        categoryPickerView .delegate = self
        categoryPickerView.dataSource = self
        countryPickerView.selectRow(countrys.firstIndex(of: newsSettingManager.getCountry()) ?? 0, inComponent: 0, animated: false)
        categoryPickerView.selectRow(category.firstIndex(of: newsSettingManager.getCategory()) ?? 0, inComponent: 0, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
//        let viewHeight = categoryPickerView.frame.origin.y + categoryPickerView.frame.size.height
        let viewHeight = countryPickerView.frame.origin.y + countryPickerView.frame.size.height
        if isFirstHeightSetting && self.view.frame.height != viewHeight {
            self.view.frame.origin.y += self.view.frame.height - viewHeight
            self.view.frame.size.height = viewHeight
            self.view.layer.cornerRadius = 10 // 設定圓角
            self.view.layer.masksToBounds = true // 設定超出圓角範圍的部分不要顯示
            isFirstHeightSetting = false
        }
    }
    
    @IBAction func finishedButtonClick(_ sender: Any) {
        self.dismiss(animated: true)
        postNotification(name: NotificationName.reload(displayMode: .headline).name)
        reloadNotificationPost = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // MARK: - FCM 重新訂閱地區
        Messaging.messaging().unsubscribe(fromTopic: unsubscribeCountry.rawValue)
        Messaging.messaging().subscribe(toTopic: newsSettingManager.getCountry().rawValue)
        print("sub", unsubscribeCountry.rawValue, "unsub", newsSettingManager.getCountry().rawValue)
        
        if !reloadNotificationPost {
            postNotification(name: NotificationName.reload(displayMode: .headline).name)
        }
    }
}

extension HeadlinesSettingViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == countryPickerView {
            return countrys.count
        } else if pickerView == categoryPickerView {
            return category.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == countryPickerView {
            return countrys[row].chineseName
        } else if pickerView == categoryPickerView {
            return category[row].chineseName
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("Row: \(row)")

        if pickerView == countryPickerView {
            newsSettingManager.updateSettingStorage(data: countrys[row])
        } else if pickerView == categoryPickerView {
            newsSettingManager.updateSettingStorage(data: category[row])
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    
}
