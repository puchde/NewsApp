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
    var newsList = newsSettingManager.getNewsMarkList() {
        didSet {
            newsList.sort {
                return $0.mark.point < $1.mark.point
            }
            normalList = newsList.filter({$0.mark.point == NewsMark.critical.point})
            attentionList = newsList.filter({$0.mark.point == NewsMark.criticality.point})
            importantList = newsList.filter({$0.mark.point == NewsMark.significantCriticality.point})
        }
    }
    var normalList = [MarkedArticle]()
    var attentionList = [MarkedArticle]()
    var importantList = [MarkedArticle]()
    var normalListHide = false
    var attentionListHide = false
    var importantListHide = false

    var selectNewsUrl = ""

    let headerHeight = CGFloat(35)

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }

    override func viewWillAppear(_ animated: Bool) {
        reloadDataAct()
        tableView.reloadData()
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
        tableView.sectionHeaderTopPadding = 8

        let keyboardTap = UITapGestureRecognizer(target: self, action: #selector(resignKeyboard))
        keyboardTap.delegate = self
        keyboardTap.cancelsTouchesInView = false
        view.addGestureRecognizer(keyboardTap)
    }

    @objc func resignKeyboard() {
        searchBar.resignFirstResponder()
    }
}

//MARK: TableView Header
extension MarkListViewController {
    @objc
    func toggleImportantListHide(section: Int) {
        importantListHide.toggle()
        self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
    }

    @objc
    func toggleAttentionListHide(section: Int) {
        attentionListHide.toggle()
        self.tableView.reloadSections(IndexSet(integer: 1), with: .fade)
    }

    @objc
    func togglenormalListHide(section: Int) {
        normalListHide.toggle()
        self.tableView.reloadSections(IndexSet(integer: 2), with: .fade)
    }

    func setupHeader(section: Int) -> UIView? {
        let backView = UIView()
        let headerView = UILabel(frame: CGRect(x: 10, y: 0, width: self.view.frame.width - (2 * 10), height: headerHeight))
        let filterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: headerHeight))
        let label = UILabel(frame: CGRect(x: 30, y: 0, width: self.view.frame.width, height: headerHeight))

        backView.addSubview(headerView)
        headerView.addSubview(filterView)
        headerView.clipsToBounds = true
        headerView.layer.cornerRadius = headerHeight * 0.25
        filterView.backgroundColor = .white.withAlphaComponent(0.75)
        filterView.addSubview(label)
        label.textColor = .secondaryLabel
        switch section {
        case 0:
            label.text = R.string.localizable.important()
            headerView.backgroundColor = NewsMark.significantCriticality.color
            let tap = UITapGestureRecognizer(target: self, action: #selector(toggleImportantListHide))
            tap.delegate = self
            backView.addGestureRecognizer(tap)
            return importantList.isEmpty ? nil : backView
        case 1:
            label.text = R.string.localizable.attention()
            headerView.backgroundColor = NewsMark.criticality.color
            let tap = UITapGestureRecognizer(target: self, action: #selector(toggleAttentionListHide))
            tap.delegate = self
            backView.addGestureRecognizer(tap)
            return attentionList.isEmpty ? nil : backView
        case 2:
            label.text = R.string.localizable.normal()
            headerView.backgroundColor = NewsMark.critical.color
            let tap = UITapGestureRecognizer(target: self, action: #selector(togglenormalListHide))
            tap.delegate = self
            backView.addGestureRecognizer(tap)
            return normalList.isEmpty ? nil : backView
        default:
            return nil
        }
    }
}

//MARK: TableView
extension MarkListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return NewsMark.allCases.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return importantList.isEmpty ? 0 : headerHeight
        case 1:
            return attentionList.isEmpty ? 0 : headerHeight
        case 2:
            return normalList.isEmpty ? 0 : headerHeight
        default:
            return 0
        }        
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        setupHeader(section: section)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return importantListHide ? 0 : importantList.count
        case 1:
            return attentionListHide ? 0 : attentionList.count
        case 2:
            return normalListHide ? 0 : normalList.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as? NewsCell{
            let newsData: MarkedArticle = {
                switch indexPath.section {
                case 0:
                    return importantList[indexPath.row]
                case 1:
                    return attentionList[indexPath.row]
                case 2:
                    return normalList[indexPath.row]
                default:
                    return newsList[indexPath.row]
                }
            }()
            cell.updateArticleInfo(activeVC: self, article: newsData.article)
            tableView.deselectRow(at: indexPath, animated: false)
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var dataList = {
                switch indexPath.section {
                case 0:
                    return importantList
                case 1:
                    return attentionList
                case 2:
                    return normalList
                default:
                    return []
                }
            }()
            let news = dataList[indexPath.row]
            newsSettingManager.deleteNewsMarkList(news)
            reloadNewsList()
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
        if let cell = tableView.cellForRow(at: indexPath) as? NewsCell,
           let article = cell.article {
            selectNewsUrl = article.url
        }
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
            newsList = newsSettingManager.getNewsMarkList().filter({
                $0.article.author?.contains(searchString) ?? false || $0.article.content?.contains(searchString) ?? false || $0.article.description?.contains(searchString) ?? false || $0.article.title.contains(searchString) || $0.article.publishedAt.contains(searchString)
            })
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
