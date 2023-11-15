//
//  MarkListViewController.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/16.
//

import UIKit
import SafariServices

class MarkListViewController: UIViewController, SFSafariViewControllerDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var leftButtonItem: UIBarButtonItem!
    let freshControl = UIRefreshControl()
    var newsList = newsSettingManager.getNewsMarkList()
    var selectNewsUrl = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }

    override func viewWillAppear(_ animated: Bool) {
        reloadDataAct()
        tableView.reloadData()
        checkYPosition()
    }

    override func viewWillDisappear(_ animated: Bool) {

    }
}

//MARK: Init
extension MarkListViewController: UIGestureRecognizerDelegate {
    func initView() {
        leftButtonItem.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 25), .foregroundColor: UIColor.label], for: .disabled)
        leftButtonItem.isEnabled = false
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        tableView.refreshControl = freshControl

        let keyboardTap = UITapGestureRecognizer(target: self, action: #selector(resignKeyboard))
        keyboardTap.delegate = self
        keyboardTap.cancelsTouchesInView = false
        view.addGestureRecognizer(keyboardTap)
    }

    @objc func resignKeyboard() {
        searchBar.resignFirstResponder()
    }
}

//MARK: TableView
extension MarkListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        newsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as? NewsCell{
            let newsData = newsList[indexPath.row]
            cell.updateArticleInfo(activeVC: self, article: newsData)
            tableView.deselectRow(at: indexPath, animated: false)
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        }
        return true
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let news = newsList[indexPath.row]
            newsSettingManager.deleteNewsMarkList(news)
            reloadNewsList()
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
        selectNewsUrl = newsList[indexPath.row].url
//        performSegue(withIdentifier: "toWebView", sender: self)
        if let url = URL(string: selectNewsUrl) {
            let vc = getSafariVC(url: url, delegateVC: self)
            self.present(vc, animated: true)
            self.modalPresentationStyle = .fullScreen
        }
        searchBar.resignFirstResponder()
    }
}

// MARK: - TableView Cell Preview
extension MarkListViewController: NewsTableViewProtocal {
    var newsTableView: UITableView {
        self.tableView
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { _ in
            self.makePreviewMenu(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration, isShow: true)
    }

    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration, isShow: false)
    }
}

//MARK: News Cell Delegate
extension MarkListViewController: NewsCellDelegate {
    func reloadCell() {
        reloadNewsList()
        tableView.reloadData()
    }
}

//MARK: SearchBar
extension MarkListViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchClick")
        reloadNewsList()
        tableView.reloadData()
        searchBar.showsCancelButton = false
        view.endEditing(true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        reloadNewsList()
        tableView.reloadData()
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBar.resignFirstResponder()
    }
}

extension MarkListViewController {
    @objc func reloadDataAct() {
        reloadNewsList()
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
}

//MARK: ScrollView
extension MarkListViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        checkYPosition()
    }

    func checkYPosition() {
        if tableView.contentOffset.y > 0 {
            navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            navigationController?.setNavigationBarHidden(false, animated: true)
            navigationController?.navigationBar.sizeToFit()
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if freshControl.isRefreshing {
            reloadDataAct()
        }
    }
}

//MARK: Model
extension MarkListViewController {
    func reloadNewsList() {
        if let searchString = searchBar.searchTextField.text, !searchString.isEmpty {
            newsList = newsSettingManager.getNewsMarkList().filter({$0.author?.contains(searchString) ?? false || $0.content?.contains(searchString) ?? false || $0.description?.contains(searchString) ?? false || $0.title.contains(searchString)})
        } else {
            newsList = newsSettingManager.getNewsMarkList()
        }
    }
}

//MARK: Segue
extension MarkListViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toWebView", let webView = segue.destination as? WebViewViewController {
            webView.urlString = selectNewsUrl
        }
    }
}
