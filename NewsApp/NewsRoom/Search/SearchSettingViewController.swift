//
//  SearchSettingViewController.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/9.
//

import UIKit

protocol searchSettingDelegate: AnyObject {
    func reloadView()
}

class SearchSettingViewController: UIViewController {

    @IBOutlet weak var searchTimeSelectButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var searchSortSelectButton: UIButton!

    var searchInValue = [SearchIn]()
    let searchLanguage = SearchLanguage.allCases
    var searchSortBy = newsSettingManager.getSearchSortBy()
    weak var delegate: searchSettingDelegate?
    var isFirstHeightSetting = true
    var reloadNotificationPost = false
    
    lazy var searchTimeMenu: UIMenu? = UIMenu(options: .singleSelection, children: [
        UIAction(title: R.string.localizable.settingDefault(), handler: { [weak self] _ in
            newsSettingManager.updateSearchTime(searchTime: .none)
            self?.updateButtonTitle(searchTime: SearchTime.none)
        }),
        UIMenu(title: R.string.localizable.hour(), options: [.displayInline, .singleSelection], children: [
            UIAction(title: R.string.localizable.hour1(), handler: { [weak self] _ in
                newsSettingManager.updateSearchTime(searchTime: .hour1)
                self?.updateButtonTitle(searchTime: .hour1)
            }),
            UIAction(title: R.string.localizable.hour6(), handler: { [weak self] _ in
                newsSettingManager.updateSearchTime(searchTime: .hour6)
                self?.updateButtonTitle(searchTime: .hour6)
            }),
            UIAction(title: R.string.localizable.hour12(), handler: { [weak self] _ in
                newsSettingManager.updateSearchTime(searchTime: .hour12)
                self?.updateButtonTitle(searchTime: .hour12)
            })
        ]),
        UIMenu(title: R.string.localizable.day(), options: [.displayInline, .singleSelection], children: [
            UIAction(title: R.string.localizable.day1(), handler: { [weak self] _ in
                newsSettingManager.updateSearchTime(searchTime: .day1)
                self?.updateButtonTitle(searchTime: .day1)
            }),
            UIAction(title: R.string.localizable.day7(), handler: { [weak self] _ in
                newsSettingManager.updateSearchTime(searchTime: .day7)
                self?.updateButtonTitle(searchTime: .day7)
            })
        ]),
        UIMenu(title: R.string.localizable.month(), options: [.displayInline, .singleSelection], children: [
            UIAction(title: R.string.localizable.month1(), handler: { [weak self] _ in
                newsSettingManager.updateSearchTime(searchTime: .month1)
                self?.updateButtonTitle(searchTime: .month1)
            }),
            UIAction(title: R.string.localizable.month3(), handler: { [weak self] _ in
                newsSettingManager.updateSearchTime(searchTime: .month3)
                self?.updateButtonTitle(searchTime: .month3)
            })
        ])
    ])
    
    lazy var sortMenu: UIMenu? = UIMenu(title: R.string.localizable.sortBy(), options: [.singleSelection], children: [
        UIAction(title: R.string.localizable.settingDefault(), handler: { [weak self] _ in
            newsSettingManager.updateSettingStorage(data: SearchSortBy.none)
            self?.updateButtonTitle(searchSortBy: SearchSortBy.none)
        }),
        UIAction(title: R.string.localizable.publishedAt(), handler: { [weak self] _ in
            newsSettingManager.updateSettingStorage(data: SearchSortBy.publishedAt)
            self?.updateButtonTitle(searchSortBy: SearchSortBy.publishedAt)
        })
    ])

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        if let delegate {
            delegate.reloadView()
        }
        if !reloadNotificationPost {
            NotificationCenter.default.post(name: Notification.Name("\(DisplayMode.search) - ReloadNewsData"), object: nil)
        }
    }

    @IBAction func finishedButtonClick(_ sender: Any) {
        self.dismiss(animated: true)
        NotificationCenter.default.post(name: Notification.Name("\(DisplayMode.search) - ReloadNewsData"), object: nil)
        reloadNotificationPost = true
    }

    override func viewDidLayoutSubviews() {
        let viewHeight = searchSortSelectButton.convert(CGPoint(x: 0, y: searchSortSelectButton.frame.size.height), to: self.parent?.view).y
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
        searchSortSelectButton.getBorderAndRadius()
        searchSortSelectButton.setSelectedStatus()
        
        searchTimeSelectButton.showsMenuAsPrimaryAction = true
        searchSortSelectButton.showsMenuAsPrimaryAction = true
        updateButtonTitle(searchTime: newsSettingManager.getSearchTime(), searchSortBy: newsSettingManager.getSearchSortBy())
        searchTimeSelectButton.menu = searchTimeMenu
        searchSortSelectButton.menu = sortMenu
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
    func updateButtonTitle(searchTime: SearchTime? = nil, searchSortBy: SearchSortBy? = nil) {
        if let searchTime {
            searchTimeSelectButton.setTitle(searchTime.name, for: .normal)
        }
        
        if let searchSortBy {
            searchSortSelectButton.setTitle(searchSortBy.chineseName, for: .normal)
        }
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
}
