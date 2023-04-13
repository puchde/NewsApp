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

    @IBOutlet weak var allSelectButton: UIButton!
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var contentButton: UIButton!
    @IBOutlet weak var descrbtionButton: UIButton!
    @IBOutlet weak var fromDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var relevancyButton: UIButton!
    @IBOutlet weak var popularityButton: UIButton!
    @IBOutlet weak var publishedAtButton: UIButton!

    var searchInValue = [SearchIn]()
    let searchLanguage = SearchLanguage.allCases
    var searchSortBy = newsSettingManager.getSearchSortBy()
    var delegate: searchSettingDelegate?
    var isFirstHeightSetting = true

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        guard let delegate else { return }
        delegate.reloadView()
    }

    @IBAction func finishedButtonClick(_ sender: Any) {
        self.dismiss(animated: true)
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
        
        allSelectButton.getBorderAndRadius()
        allSelectButton.setSelectedStatus()
        titleButton.getBorderAndRadius()
        titleButton.setSelectedStatus()
        contentButton.setSelectedStatus()
        contentButton.getBorderAndRadius()
        descrbtionButton.getBorderAndRadius()
        descrbtionButton.setSelectedStatus()
        publishedAtButton.getBorderAndRadius()
        publishedAtButton.setSelectedStatus()
        popularityButton.getBorderAndRadius()
        popularityButton.setSelectedStatus()
        relevancyButton.getBorderAndRadius()
        relevancyButton.setSelectedStatus()

        let seachIn = newsSettingManager.getSearchInArray()
        seachIn.forEach { value in
            switch value {
            case .title:
                titleButton.isSelected = true
                searchInValue.append(.title)
            case .description:
                descrbtionButton.isSelected = true
                searchInValue.append(.description)
            case .content:
                contentButton.isSelected = true
                searchInValue.append(.content)
            case .all:
                allSelectButton.isSelected = true
                searchInValue.append(.title)
                searchInValue.append(.description)
                searchInValue.append(.content)
            }
        }

        let sortBy = newsSettingManager.getSearchSortBy()
        switch sortBy {
        case .relevancy:
            relevancyButton.isSelected = true
        case .popularity:
            popularityButton.isSelected = true
        case .publishedAt:
            publishedAtButton.isSelected = true
        }
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
        newsSettingManager.updateSearchLanguage(searchLanguage[row])
    }
}

// MARK: Button Action
extension SearchSettingViewController {
    @IBAction func allSelectClick(_ sender: UIButton) {
        if allSelectButton.isSelected {
            print("allSelect")
            return
        }
        sender.isSelected = !sender.isSelected // 切換選中狀態
        titleButton.isSelected = false
        contentButton.isSelected = false
        descrbtionButton.isSelected = false
        newsSettingManager.updateSearchIn([.all])
    }

    @IBAction func searchInSelectClick(_ sender: UIButton) {
        if searchInValue.count == 1 && sender.isSelected { return }
        if sender.isSelected {
            searchInValue.removeAll { value in
                switch sender {
                case titleButton:
                    return value == .title
                case contentButton:
                    return value == .content
                case descrbtionButton:
                    return value == .description
                default:
                    return false
                }
            }
        } else {
            if newsSettingManager.getSearchIn() == SearchIn.all.rawValue {
                searchInValue.removeAll()
            }
            switch sender {
            case titleButton:
                searchInValue.append(.title)
            case contentButton:
                searchInValue.append(.content)
            case descrbtionButton:
                searchInValue.append(.description)
            default:
                break
            }
        }

        if searchInValue.contains(.content) && searchInValue.contains(.title) && searchInValue.contains(.description) {
            allSelectButton.isSelected = true
            titleButton.isSelected = false
            contentButton.isSelected = false
            descrbtionButton.isSelected = false
            newsSettingManager.updateSearchIn([.all])
        } else {
            allSelectButton.isSelected = false
            newsSettingManager.updateSearchIn(searchInValue)
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
            newsSettingManager.updateSearchSortBy(.relevancy)
        case popularityButton:
            searchSortBy = .popularity
            newsSettingManager.updateSearchSortBy(.popularity)
        case publishedAtButton:
            searchSortBy = .publishedAt
            newsSettingManager.updateSearchSortBy(.publishedAt)
        default:
            break
        }
        sender.isSelected = !sender.isSelected
    }
}
