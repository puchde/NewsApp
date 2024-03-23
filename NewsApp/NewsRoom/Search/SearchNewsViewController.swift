//
//  SearchNewsViewController.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/3.
//

import UIKit

class SearchNewsViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchSettingTableView: UITableView!
    @IBOutlet weak var searchRecordTableView: UITableView!
    @IBOutlet weak var leftButtonItem: UIBarButtonItem!
    
    var searchSettingHeader = [R.string.localizable.searchTime(),
                               R.string.localizable.searchLocation(),
                               R.string.localizable.searchOrder()]
    var searchIn = ""
    var searchRecord: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewInit()
    }


    override func viewWillAppear(_ animated: Bool) {
        if let querys = userDefaults.stringArray(forKey: UserdefaultKey.searchQuery.rawValue) {
            searchRecord = querys
        }
        searchBar.text = newsSettingManager.getSearchQuery()
        searchSettingTableView.reloadData()
        searchRecordTableView.reloadData()
    }
}

//MARK: Init
extension SearchNewsViewController: UIGestureRecognizerDelegate {
    func viewInit() {
        leftButtonItem.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 25), .foregroundColor: UIColor.label], for: .disabled)
        leftButtonItem.isEnabled = false
        searchBar.delegate = self
        searchSettingTableView.clipsToBounds = true
        searchSettingTableView.layer.cornerRadius = 20
        searchSettingTableView.isScrollEnabled = false
        searchSettingTableView.delegate = self
        searchSettingTableView.dataSource = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(showSearchSettingVC))
        searchSettingTableView.addGestureRecognizer(tap)
        searchRecordTableView.delegate = self
        searchRecordTableView.dataSource = self

        let keyboardTap = UITapGestureRecognizer(target: self, action: #selector(resignKeyboard))
        keyboardTap.delegate = self
        keyboardTap.cancelsTouchesInView = false
        view.addGestureRecognizer(keyboardTap)
    }

    @objc func resignKeyboard() {
        searchBar.resignFirstResponder()
    }
}

//MARK: SearchBar
extension SearchNewsViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchClick")
        guard let searchString = searchBar.searchTextField.text, !searchString.isEmpty else {
            return
        }
        showNewsTableVC(searchString: searchString)
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        view.endEditing(true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBar.resignFirstResponder()
    }
}

//MARK: TableView Setting
extension SearchNewsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == searchSettingTableView {
            return 30
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == searchSettingTableView {
            return searchSettingHeader[section]
        } else if tableView == searchRecordTableView {
            return "搜尋紀錄"
        }
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == searchSettingTableView {
            return 3
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchSettingTableView {
            return 1
        } else if tableView == searchRecordTableView {
            return searchRecord.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var cellConfig = UIListContentConfiguration.cell()
        if tableView == searchSettingTableView {
            switch indexPath.section {
            case 0:
                cellConfig.text = newsSettingManager.getSearchTime().name
            case 1:
                cellConfig.text = newsSettingManager.getSearchLanguage().chineseName
            case 2:
                cellConfig.text = newsSettingManager.getSearchSortBy().chineseName
            default:
                break
            }
        } else if tableView == searchRecordTableView {
            cellConfig.text = searchRecord.reversed()[indexPath.row]
        }
        cell.contentConfiguration = cellConfig
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        if tableView == searchSettingTableView {
            showSearchSettingVC()
        } else if tableView == searchRecordTableView {
            let searchString = searchRecord.reversed()[indexPath.row]
            showNewsTableVC(searchString: searchString)
            searchBar.resignFirstResponder()
        }
    }
}

extension SearchNewsViewController: searchSettingDelegate {
    func reloadView() {
        searchSettingTableView.reloadData()
    }
}
//MARK: Prepare to next view
extension SearchNewsViewController {
    @IBAction func searchOptionsButtonClick(_ sender: Any) {
        showSearchSettingVC()
    }
    
    @objc func showSearchSettingVC() {
        guard let SearchSettingVC = storyboard?.instantiateViewController(withIdentifier: "SearchSettingViewController") as? SearchSettingViewController else {
            return
        }
        SearchSettingVC.delegate = self
        DispatchQueue.main.async {
            self.present(SearchSettingVC, animated: true)
        }
    }

    func showNewsTableVC(searchString: String) {
        guard let SearchContentVC = storyboard?.instantiateViewController(withIdentifier: "SearchContentViewController") as? SearchContentViewController else {
            return
        }
        var query = userDefaults.stringArray(forKey: UserdefaultKey.searchQuery.rawValue) ?? []
        if query.contains(searchString) {
            let index = query.firstIndex(of: searchString) ?? 0
            query.remove(at: index)
        }
        query.append(searchString)
        if query.count > 5 {
            query.removeFirst()
        }
        userDefaults.setValue(query, forKey: UserdefaultKey.searchQuery.rawValue)

        newsSettingManager.updateSearchQuery(searchString)
        self.navigationController?.pushViewController(SearchContentVC, animated: true)
    }
}
