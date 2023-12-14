//
//  SearchSettingViewController.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/9.
//

import UIKit

protocol searchSettingDelegate {
    func reloadView()
}

class SearchSettingViewController: UIViewController {

    @IBOutlet weak var searchTimeSelectButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var relevancyButton: UIButton!
    @IBOutlet weak var popularityButton: UIButton!
    @IBOutlet weak var publishedAtButton: UIButton!

    var searchInValue = [SearchIn]()
    let searchLanguage = SearchLanguage.allCases
    var searchSortBy = newsSettingManager.getSearchSortBy()
    var delegate: searchSettingDelegate?
    var isFirstHeightSetting = true
    var reloadNotificationPost = false
    
    lazy var searchTimeActionH1 = UIAction(title: R.string.localizable.hour1(), handler: { _ in
        newsSettingManager.updateSearchTime(searchTime: .hour1)
        self.updateSearchTimeMenu(searchTime: .hour1)
    })
    lazy var searchTimeActionH6 = UIAction(title: R.string.localizable.hour6(), handler: { _ in
        newsSettingManager.updateSearchTime(searchTime: .hour6)
        self.updateSearchTimeMenu(searchTime: .hour6)
    })
    lazy var searchTimeActionH12 = UIAction(title: R.string.localizable.hour12(), handler: { _ in
        newsSettingManager.updateSearchTime(searchTime: .hour12)
        self.updateSearchTimeMenu(searchTime: .hour12)
    })
    lazy var searchTimeActionD1 = UIAction(title: R.string.localizable.day1(), handler: { _ in
        newsSettingManager.updateSearchTime(searchTime: .day1)
        self.updateSearchTimeMenu(searchTime: .day1)
    })
    lazy var searchTimeActionD7 = UIAction(title: R.string.localizable.day7(), handler: { _ in
        newsSettingManager.updateSearchTime(searchTime: .day7)
        self.updateSearchTimeMenu(searchTime: .day7)
    })
    lazy var searchTimeActionM1 = UIAction(title: R.string.localizable.month1(), handler: { _ in
        newsSettingManager.updateSearchTime(searchTime: .month1)
        self.updateSearchTimeMenu(searchTime: .month1)
    })
    lazy var searchTimeActionM3 = UIAction(title: R.string.localizable.month3(), handler: { _ in
        newsSettingManager.updateSearchTime(searchTime: .month3)
        self.updateSearchTimeMenu(searchTime: .month3)
    })
    lazy var searchTimeActionNone = UIAction(title: R.string.localizable.settingDefault(), handler: { _ in
        newsSettingManager.updateSearchTime(searchTime: .none)
        self.updateSearchTimeMenu(searchTime: .none)
    })

    lazy var searchTimeMenuHour = UIMenu(title: R.string.localizable.hour(), options: [.displayInline, .singleSelection], children: [
        searchTimeActionH1,
        searchTimeActionH6,
        searchTimeActionH12
    ])
    
    lazy var searchTimeMenuDay = UIMenu(title: R.string.localizable.day(), options: [.displayInline, .singleSelection], children: [
        searchTimeActionD1,
        searchTimeActionD7
    ])
    
    lazy var searchTimeMenuMonth = UIMenu(title: R.string.localizable.month(), options: [.displayInline, .singleSelection], children: [
        searchTimeActionM1,
        searchTimeActionM3
    ])

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        guard let delegate else { return }
        delegate.reloadView()
        if !reloadNotificationPost {
            NotificationCenter.default.post(name: Notification.Name("ReloadNewsData"), object: nil)
        }
    }

    @IBAction func finishedButtonClick(_ sender: Any) {
        self.dismiss(animated: true)
        NotificationCenter.default.post(name: Notification.Name("ReloadNewsData"), object: nil)
        reloadNotificationPost = true
    }

    override func viewDidLayoutSubviews() {
        let viewHeight = pickerView.frame.origin.y + pickerView.frame.size.height
        if isFirstHeightSetting && self.view.frame.height != viewHeight {
            self.view.frame.origin.y += self.view.frame.height - viewHeight
            self.view.frame.size.height = viewHeight
            self.view.layer.cornerRadius = 10 // 設定圓角
            self.view.layer.masksToBounds = true // 設定超出圓角範圍的部分不要顯示
            isFirstHeightSetting = false
        }
    }

}

extension SearchSettingViewController {
    func initView() {
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(searchLanguage.firstIndex(of: newsSettingManager.getSearchLanguage()) ?? 0, inComponent: 0, animated: false)
        
        searchTimeSelectButton.getBorderAndRadius()
        searchTimeSelectButton.setSelectedStatus()
        publishedAtButton.getBorderAndRadius()
        publishedAtButton.setSelectedStatus()
        popularityButton.getBorderAndRadius()
        popularityButton.setSelectedStatus()
        relevancyButton.getBorderAndRadius()
        relevancyButton.setSelectedStatus()

        let sortBy = newsSettingManager.getSearchSortBy()
        switch sortBy {
        case .relevancy:
            relevancyButton.isSelected = true
        case .popularity:
            popularityButton.isSelected = true
        case .publishedAt:
            publishedAtButton.isSelected = true
        }
        
        searchTimeSelectButton.setTitle("預設", for: .normal)
        searchTimeSelectButton.showsMenuAsPrimaryAction = true
        updateSearchTimeMenu(searchTime: newsSettingManager.getSearchTime())
        searchTimeSelectButton.menu = UIMenu(options: .singleSelection, children: [
            searchTimeActionNone,
            searchTimeMenuHour,
            searchTimeMenuDay,
            searchTimeMenuMonth
        ])
    }
}

extension SearchSettingViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return searchLanguage.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return searchLanguage[row].chineseName
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        newsSettingManager.updateSettingStorage(data: searchLanguage[row])
    }
}

// MARK: Button Action
extension SearchSettingViewController {
    // 棄用 -> searchTime
    @IBAction func allSelectClick(_ sender: UIButton) {
        if searchTimeSelectButton.isSelected {
            print("allSelect")
            return
        }
        sender.isSelected = !sender.isSelected // 切換選中狀態
        newsSettingManager.updateSettingStorage(data: [SearchIn.all])
    }
    
    func updateSearchTimeMenu(searchTime: SearchTime) {
        searchTimeSelectButton.setTitle(searchTime.name, for: .normal)
    }

    @IBAction func searchInSelectClick(_ sender: UIButton) {
        if searchInValue.contains(.content) && searchInValue.contains(.title) && searchInValue.contains(.description) {
            searchTimeSelectButton.isSelected = true
            newsSettingManager.updateSettingStorage(data: [SearchIn.all])
        } else {
            searchTimeSelectButton.isSelected = false
            newsSettingManager.updateSettingStorage(data: searchInValue)
            sender.isSelected = !sender.isSelected // 切換選中狀態
        }
    }

    @IBAction func sortByButtonClick(_ sender: UIButton) {
        relevancyButton.isSelected = false
        popularityButton.isSelected = false
        publishedAtButton.isSelected = false
        switch sender {
        case relevancyButton:
            searchSortBy = .relevancy
            newsSettingManager.updateSettingStorage(data: SearchSortBy.relevancy)
        case popularityButton:
            searchSortBy = .popularity
            newsSettingManager.updateSettingStorage(data: SearchSortBy.popularity)
        case publishedAtButton:
            searchSortBy = .publishedAt
            newsSettingManager.updateSettingStorage(data: SearchSortBy.publishedAt)
        default:
            break
        }
        sender.isSelected = !sender.isSelected
    }
}
