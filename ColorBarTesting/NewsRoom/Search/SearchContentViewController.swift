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
    }
    @IBAction func backButtonClick(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: SearchBar
extension SearchContentViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchString = searchBar.searchTextField.text else { return }
        newsSettingManager.updateSearchQuery(searchString)
        if let pageVC = children.first as? HeadlinesPageViewController, let contentVC = pageVC.getContentViewController(page: 0) {
            contentVC.reloadNewsData(searchString: searchString)
        }
    }
}
