//
//  SearchContentViewController.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/9.
//

import UIKit

class SearchContentViewController: ClassifyHeadlineViewController {
    @IBOutlet weak var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.searchTextField.text = newsSettingManager.getSearchQuery()
        searchBar.delegate = self
        
        let popSwipe = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(backButtonClick))
        popSwipe.edges = .left
        self.view.addGestureRecognizer(popSwipe)
    }
    @IBAction func backButtonClick(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: SearchBar
extension SearchContentViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchString = searchBar.searchTextField.text, searchString != newsSettingManager.getSearchQuery(), !searchString.isEmpty else { return }
        newsSettingManager.updateSearchQuery(searchString)
        var query = userDefaults.stringArray(forKey: UserdefaultKey.searchQuery.rawValue) ?? []
        if query.contains(searchString) {
            let index = query.firstIndex(of: searchString) ?? 0
            query.swapAt(index, query.count - 1)
        } else {
            query.append(searchString)
        }
        if query.count > 5 {
            query.removeFirst()
        }
        userDefaults.setValue(query, forKey: UserdefaultKey.searchQuery.rawValue)
        if let pageVC = children.first as? HeadlinesPageViewController, let contentVC = pageVC.getContentViewController(page: 0) {
            contentVC.updateReloadSetting(searchString: searchString)
        }
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
