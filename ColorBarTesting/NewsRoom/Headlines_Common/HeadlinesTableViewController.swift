//
//  HeadlinesTableViewController.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/6.
//

import UIKit

class HeadlinesTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    private let displayMode: DisplayMode = newsSettingManager.getDisplayMode()
    private let articlesQueue = DispatchQueue(label: "com.example.articlesQueue", attributes: .concurrent)
    private var _articles: [Article] = []
    var articles: [Article] {
        get {
            return articlesQueue.sync {
                return self._articles
            }
        }
        set {
            articlesQueue.async(flags: .barrier) {
                self._articles = newValue
            }
        }
    }

    var page: Int?
    var articlesNumber = 0
    var selectNewsUrl = ""
    var isLoadedData = false
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
    var newsCountry: CountryCode = .TW {
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

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkYPosition()
        newsCountry = newsSettingManager.getCountry()
        if needFresh {
            reloadNewsData()
        } else {
            loadNewsData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        checkYPosition(isShow: true)
        scrollToTop()
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
        let freshControl = UIRefreshControl()
        freshControl.addTarget(self, action: #selector(reloadNewsDataAction), for: .valueChanged)
        tableView.refreshControl = freshControl
    }
}

//MARK: TableView Data
extension HeadlinesTableViewController {
    func scrollToTop() {
        if !articles.isEmpty {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }

    @objc func reloadNewsDataAction() {
        switch displayMode {
        case .headline:
            reloadNewsData()
        case .search:
            let searchString = newsSettingManager.getSearchQuery()
            reloadNewsData(searchString: searchString)
        }
    }

    func reloadNewsData(searchString: String = "") {
        switch displayMode {
        case .headline:
            if newsCountry != newsSettingManager.getCountry() {
                newsCountry = newsSettingManager.getCountry()
                reloadNewsData()
                return
            }
            break
        case .search:
            newsSettingManager.updateSearchQuery(searchString)
            break
        }
        needFresh = false
        dataPage = 1
        isLoadedData = false
        articles.removeAll()
        loadNewsData()
    }
    
    func loadNewsData(loadMorePage: Bool = false) {
        if loadMorePage {
            if articles.count == dataPage * dataPageCount {
                dataPage += 1
                isLoadedData = false
            }
        }
        if !isLoadedData {
            switch displayMode {
            case .headline:
                guard let page, let category = Category.fromOrder(page)?.rawValue else { return }
                APIManager.topHeadlines(country: newsCountry.rawValue, category: category, page: dataPage) { result in
                    switch result {
                    case .success(let success):
                        if success.status == "ok" {
                            self.articlesNumber = success.totalResults
                            success.articles.forEach { article in
                                self.articles.append(article)
                            }
                            self.tableView.reloadData()
                            self.isLoadedData = true
                            self.tableView.refreshControl?.endRefreshing()
                        } else {
                            print(success.status)
                            self.tableView.refreshControl?.endRefreshing()
                        }
                    case .failure(let failure):
                        print(failure)
                        self.tableView.refreshControl?.endRefreshing()
                    }
                }
                break
            case .search:
                APIManager.searchNews(query: searchQuery, language: "zh", page: dataPage) { result in
                    switch result {
                    case .success(let success):
                        if success.status == "ok" {
                            self.articlesNumber = success.totalResults
                            success.articles.forEach { article in
                                self.articles.append(article)
                            }
                            self.tableView.reloadData()
                            self.isLoadedData = true
                            self.tableView.refreshControl?.endRefreshing()
                        } else {
                            print(success.status)
                            self.tableView.refreshControl?.endRefreshing()
                        }
                    case .failure(let failure):
                        print(failure)
                        self.tableView.refreshControl?.endRefreshing()
                    }
                }
                break
            }
        }
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
            let newsDate = String(newsData.publishedAt.prefix(10))
            cell.updateArticleInfo(author: newsData.author ?? "News啦", title: newsData.title, newsDate: newsDate, newsImageUrl: newsData.urlToImage ?? "")
            tableView.deselectRow(at: indexPath, animated: false)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
        selectNewsUrl = articles[indexPath.row].url
        performSegue(withIdentifier: "toWebView", sender: self)
    }
}

//MARK: ScrollView
extension HeadlinesTableViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        checkYPosition()
        let offsetY = scrollView.contentOffset.y
        let screenHeight = scrollView.frame.size.height
        let contentHeight = scrollView.contentSize.height
        if contentHeight != 0 && offsetY + screenHeight > (contentHeight) {
            print("一半啦")
            loadNewsData(loadMorePage: true)
        }
    }
    
    func checkYPosition(isShow: Bool = false) {
        if isShow {
            navigationController?.setNavigationBarHidden(false, animated: true)
            navigationController?.navigationBar.sizeToFit()
            return
        } else {
            if tableView.contentOffset.y > 0 {
                navigationController?.setNavigationBarHidden(true, animated: true)
            } else {
                navigationController?.setNavigationBarHidden(false, animated: true)
                navigationController?.navigationBar.sizeToFit()
            }
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
