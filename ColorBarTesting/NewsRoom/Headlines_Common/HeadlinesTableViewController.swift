//
//  HeadlinesTableViewController.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/6.
//

import UIKit
import SafariServices
import NVActivityIndicatorView

protocol HeadlinesTableViewDelegate {
    func reloadData()
}

class HeadlinesTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var defualtCoverView: UIView!
    private let displayMode: DisplayMode = newsSettingManager.getDisplayMode()
    let freshControl = UIRefreshControl()
    var articles = [Article]()
    var page: Int?
    var articlesNumber = 0
    var selectNewsUrl = ""
    var isLoading = false
    var dataPage = 1
    var dataPageCount: Int {
        switch displayMode {
        case .headline:
            return 20
        case .search:
            return 50
        }
    }
    var needFresh = false
    var newsCountry: CountryCode = newsSettingManager.getCountry() {
        willSet {
            if newValue != self.newsCountry {
                needFresh = true
            }
        }
    }
    var searchQuery: String {
        get {
            newsSettingManager.getSearchQuery()
        }
    }
    var apiLoading = false
    
    var backgroundView: UIView?
    var loadingCover: NVActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupLoadingView()
        loadNewsData()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        loadingCoverAction(start: false)
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
        freshControl.tintColor = .clear
        tableView.refreshControl = freshControl
        
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTop), name: Notification.Name("\(displayMode) - ScrollToTop"), object: nil)
    }
    
    func setupLoadingView() {
        loadingCover = NVActivityIndicatorView(frame: CGRect(origin: CGPoint(x: (UIScreen.main.bounds.size.width / 2) - 50, y: (UIScreen.main.bounds.size.height / 2) - 100), size: CGSize(width: 100, height: 100)), type: .ballRotateChase, color: .gray)
        self.view.addSubview(loadingCover!)
        backgroundView = UIView(frame: tableView.frame)
        backgroundView?.backgroundColor = .white
        backgroundView?.addSubview(loadingCover!)
        backgroundView?.isHidden = true
        self.view.addSubview(backgroundView!)
    }
    
    func loadingCoverAction(start: Bool) {
        if start {
            loadingCover?.startAnimating()
        } else {
            loadingCover?.stopAnimating()
        }
        tableView.isScrollEnabled = start ? false : true
        backgroundView?.isHidden = start ? false : true
    }
}

//MARK: TableView Data
extension HeadlinesTableViewController {

    @objc func reloadDataAct() {
        switch displayMode {
        case .headline:
            updateReloadSetting()
        case .search:
            let searchString = newsSettingManager.getSearchQuery()
            updateReloadSetting(searchString: searchString)
        }
    }

    func updateReloadSetting(searchString: String = "") {
        switch displayMode {
        case .headline:
            if newsCountry != newsSettingManager.getCountry() {
                newsCountry = newsSettingManager.getCountry()
                updateReloadSetting()
                return
            }
            break
        case .search:
            newsSettingManager.updateSearchQuery(searchString)
            break
        }
        dataPage = 1
        needFresh = false
        articles.removeAll()
        loadNewsData()
    }
    
    func loadNewsData(scrollingLoading: Bool = false) {
        if isLoading {
            print("Loading啦")
            loadingCoverAction(start: true)
            return
        } else {
            if (scrollingLoading && articles.count < articlesNumber) || articles.count == 0 {
                isLoading = true
                
                self.tableView.refreshControl?.endRefreshing()
                loadingCoverAction(start: true)
                self.defualtCoverView.isHidden = true
                
                switch displayMode {
                case .headline:
                    guard let page, let category = Category.fromOrder(page)?.rawValue else {
                        loadingCoverAction(start: false)
                        return
                    }
                    APIManager.topHeadlines(country: newsCountry.rawValue, category: category) { result in
                        self.resultCompletion(result: result)
                        self.loadingCoverAction(start: false)
                    }
                    break
                case .search:
                    let language = newsSettingManager.getSearchLanguage().rawValue
                    APIManager.searchNews(query: searchQuery, language: language) { result in
                        self.resultCompletion(result: result)
                        self.loadingCoverAction(start: false)
                    }
                    break
                }
            } else {
                loadingCoverAction(start: false)
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }

    func resultCompletion(result: (Result<NewsAPIResponse, Error>)) -> Void {
        switch result {
        case .success(let success):
            if success.status == "OK" {
                self.articlesNumber = success.totalResults
                success.articles.forEach { article in
                    self.articles.append(article)
                }
                if self.articles.count < success.totalResults {
                    self.dataPage += 1
                }
                self.defualtCoverView.isHidden = self.articles.isEmpty ? false : true
            } else {
                print(success.status)
            }
            self.isLoading = false
        case .failure(let failure):
            print(failure)
            self.isLoading = false
        }
        self.tableView.reloadData()
    }
}

//MARK: TableView
extension HeadlinesTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as? NewsCell, !articles.isEmpty {
            let newsData = articles[indexPath.row]
            cell.updateArticleInfo(activeVC: self, article: newsData)
            tableView.deselectRow(at: indexPath, animated: false)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
        selectNewsUrl = articles[indexPath.row].url
//        performSegue(withIdentifier: "toWebView", sender: self)
        if let url = URL(string: selectNewsUrl) {
            let vc = getSafariVC(url: url, delegateVC: self)
            self.present(vc, animated: true)
            self.modalPresentationStyle = .fullScreen
        }
    }
    
    @objc func scrollToTop() {
        if !articles.isEmpty {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
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
        tableView.reloadData()
    }
}

//MARK: ScrollView
extension HeadlinesTableViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let screenHeight = scrollView.frame.size.height
        let contentHeight = scrollView.contentSize.height
        if contentHeight != 0 && offsetY + screenHeight > (contentHeight) {
            print("一半啦")
            loadNewsData(scrollingLoading: true)
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if freshControl.isRefreshing {
            reloadDataAct()
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
