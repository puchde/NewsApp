//
//  HeadlinesTableViewController.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/6.
//

import UIKit
import SafariServices
import NVActivityIndicatorView
import Toast
import SwiftProtobuf


class HeadlinesTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var defaultCoverView: UIView!
    private let displayMode: DisplayMode = newsSettingManager.getDisplayMode()
    let freshControl = UIRefreshControl()
    var customFreshControl: UIView!
    var freshControlAct = false
    var articles = [Article]()
    var filterArticles = [Article]()
    var tableViewArticles = [[Article]]()
    var page: Int?
    var articlesNumber = 0
    var selectNewsUrl = ""
    var isLoading = false
    var newsCountry: CountryCode = newsSettingManager.getCountry()

    var searchQuery: String {
        get {
            newsSettingManager.getSearchQuery()
        }
    }
    var apiLoading = false
    
    var dataReloadTime: Date = Date()
    
    let baseCellHeight = CGFloat(142)
    lazy var width = self.view.bounds.size.width

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setSearchNotification()
        loadNewsData()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        setDisappear()
    }
    
    deinit {
        print("\(String(describing: page)) is deinit")
    }
}

//MARK: Init
extension HeadlinesTableViewController {
    func initView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        tableView.register(UINib(nibName: "NewsContentImageCell", bundle: nil), forCellReuseIdentifier: "NewsContentImageCell")
        tableView.sectionHeaderTopPadding = 0
        tableView.refreshControl = freshControl
        defaultCoverView.isUserInteractionEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTop), name: Notification.Name("\(displayMode) - ScrollToTop"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDataAct), name: Notification.Name("\(displayMode) - ReloadNewsData"), object: nil)
    }
    
    func loadingCoverAction(start: Bool) {
        tableView.isScrollEnabled = start ? false : true
    }
}

//MARK: Disappear
extension HeadlinesTableViewController {
    func setDisappear() {
        if displayMode == .search {
            NotificationCenter.default.removeObserver(self, name: Notification.Name("\(displayMode) - ReloadNewsData"), object: nil)
            print("setDisappear")
        }
        loadingCoverAction(start: false)
    }

    func setSearchNotification() {
        if displayMode == .search {
            NotificationCenter.default.addObserver(self, selector: #selector(reloadDataAct), name: Notification.Name("\(displayMode) - ReloadNewsData"), object: nil)
        }
    }
}

//MARK: TableView Data
extension HeadlinesTableViewController {

    @objc func reloadDataAct() {
        updateReloadSetting()
    }

    func updateReloadSetting() {
        switch displayMode {
        case .headline:
            if newsCountry == newsSettingManager.getCountry() {
                if Date.now < dataReloadTime.addingTimeInterval(3 * 60) {
                    print("reload time return")
                    setupTableViewArticles()
                    self.tableView.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.tableView.refreshControl?.endRefreshing()
                    }
                    return
                }
            } else {
                newsCountry = newsSettingManager.getCountry()
                updateReloadSetting()
            }
            break
        case .search:
            break
        }
        articles.removeAll()
        filterArticles.removeAll()
        tableViewArticles.removeAll()
        loadNewsData()
    }
    
    func loadNewsData() {
        if isLoading {
            print("Loading啦")
            return
        } else {
            if articles.count < articlesNumber || articles.count == 0 {
                isLoading = true
                
                loadingCoverAction(start: true)
                self.defaultCoverView.isHidden = true
                
                switch displayMode {
                case .headline:
                    guard let page, let category = Category.fromOrder(page)?.rawValue else {
                        loadingCoverAction(start: false)
                        self.tableView.refreshControl?.endRefreshing()
                        return
                    }
                    APIManager.topHeadlines(country: newsCountry.rawValue, category: category) { result in
                        self.resultCompletion(result: result)
                        self.loadingCoverAction(start: false)
                        self.tableView.refreshControl?.endRefreshing()
                    }
                    break
                case .search:
                    let language = newsSettingManager.getSearchLanguage().rawValue
                    APIManager.searchNews(query: searchQuery, language: language) { result in
                        self.resultCompletion(result: result)
                        self.loadingCoverAction(start: false)
                        self.tableView.refreshControl?.endRefreshing()
                    }
                    break
                }
            } else {
                loadingCoverAction(start: false)
                self.tableView.refreshControl?.endRefreshing()
                setupTableViewArticles()
            }
        }
    }

    func resultCompletion(result: (Result<NewsAPIProtobufResponse, Error>)) -> Void {
        switch result {
        case .success(let success):
            if success.status == "OK" {
                self.articlesNumber = success.totalResults
                do {
                    let articlesData = try ArticlesTotalProtobuf(serializedData: success.articles)
                    let isFirstImage: Bool = {
                        if let f = articlesData.articles.first, !f.urlToImage.isEmpty {
                            return true
                        }
                        return false
                    }()
                    var groupID = isFirstImage ? -1 : 0
                    articlesData.articles.forEach { a in
                        if !a.urlToImage.isEmpty {
                            groupID += 1
                        }
                        let source = Source(id: a.source.id, name: a.source.name)
                        let article = Article(source: source, author: a.author, title: a.title, description: a.description_p, url: a.url, urlToImage: a.urlToImage, publishedAt: a.publishedAt, content: a.content, group: groupID)
                        self.articles.append(article)
                    }
                    setupTableViewArticles()
                } catch {
                    print(error)
                }
                self.defaultCoverView.isHidden = self.articles.isEmpty ? false : true
                dataReloadTime = Date.now
            } else {
                self.view.makeToast("取得資料錯誤")
            }
        case .failure(let failure):
            print(failure)
            self.view.makeToast("取得資料失敗")
        }
        self.isLoading = false
        self.tableView.reloadData()
    }
    
    func setupTableViewArticles() {
        filterBlockedSource()
        tableViewArticles.removeAll()
        let maxGroup = articles.last?.group ?? 1
        for i in 0 ... maxGroup {
            let a = filterArticles.filter({$0.group == i})
            tableViewArticles.append(a)
        }
    }
    
    func filterBlockedSource() {
        let source = newsSettingManager.getBlockedSource()
        filterArticles = articles.filter{!source.contains($0.author ?? "")}
    }
}

//MARK: TableView Cell
extension HeadlinesTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewArticles[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newsData = tableViewArticles[indexPath.section][indexPath.row]
        if let imageUrl = newsData.urlToImage, !imageUrl.isEmpty {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "NewsContentImageCell", for: indexPath) as? NewsCell, !articles.isEmpty {
                cell.updateArticleInfo(activeVC: self, article: newsData)
                tableView.deselectRow(at: indexPath, animated: false)
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as? NewsCell, !articles.isEmpty {
                cell.updateArticleInfo(activeVC: self, article: newsData)
                tableView.deselectRow(at: indexPath, animated: false)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
        selectNewsUrl = tableViewArticles[indexPath.section][indexPath.row].url
        if let url = URL(string: selectNewsUrl) {
            let vc = getSafariVC(url: url, delegateVC: self)
            self.present(vc, animated: true)
            self.modalPresentationStyle = .fullScreen
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let newsData = tableViewArticles[indexPath.section][indexPath.row]
        if let imageUrl = newsData.urlToImage, !imageUrl.isEmpty {
            return baseCellHeight + width * 0.6
        }
            return baseCellHeight
    }
    
    @objc func scrollToTop() {
        if !articles.isEmpty {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
}

//MARK: TableView Section
extension HeadlinesTableViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        tableViewArticles.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || tableViewArticles[section].isEmpty {
            return 0
        }
        return 15
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }
}

// MARK: - TableView Cell Preview
extension HeadlinesTableViewController: NewsTableViewProtocal {
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
extension HeadlinesTableViewController: NewsCellDelegate {
    func reloadCell() {
        setupTableViewArticles()
        tableView.reloadData()
    }
}

//MARK: ScrollView
extension HeadlinesTableViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let screenHeight = scrollView.frame.size.height
        let contentHeight = scrollView.contentSize.height
        
        if -1 <= offsetY && freshControlAct {
            // MARK: - 動畫結束重設參數
            freshControlAct = false
        } else {
            if contentHeight != 0 && offsetY + screenHeight > (contentHeight) {
                loadNewsData()
            }
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if freshControl.isRefreshing {
            reloadDataAct()
            freshControlAct = true
        }
    }
}

//MARK: Segue
extension HeadlinesTableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toWebView", let webView = segue.destination as? WebViewViewController {
            webView.urlString = selectNewsUrl
        }
    }
}

extension HeadlinesTableViewController: SFSafariViewControllerDelegate {
    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
        return []
    }
}
