//
//  HeadlinesTableViewController.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/6.
//

import UIKit

protocol HeadlinesTableViewDelegate {
    func reloadData()
}

class HeadlinesTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    private let displayMode: DisplayMode = newsSettingManager.getDisplayMode()
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

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkYPosition()
        reloadNews()

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
        freshControl.addTarget(self, action: #selector(reloadDataAct), for: .valueChanged)
        tableView.refreshControl = freshControl
        let keyboardTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(keyboardTap)
    }
}

//MARK: TableView Data
extension HeadlinesTableViewController {


    func reloadNews() {
        newsCountry = newsSettingManager.getCountry()
        if needFresh {
            reloadNews()
        } else {
            loadNewsData()
        }
    }

    @objc func reloadDataAct() {
        switch displayMode {
        case .headline:
            reloadNews()
        case .search:
            let searchString = newsSettingManager.getSearchQuery()
            reloadData(searchString: searchString)
        }
    }

    func reloadData(searchString: String = "") {
        switch displayMode {
        case .headline:
            if newsCountry != newsSettingManager.getCountry() {
                newsCountry = newsSettingManager.getCountry()
                reloadNews()
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
    
    func loadNewsData() {
        if isLoading {
            print("Loading啦")
            return
        } else {
            if articles.count < articlesNumber || articles.count == 0 {
                isLoading = true
                switch displayMode {
                case .headline:
                    guard let page, let category = Category.fromOrder(page)?.rawValue else { return }
                    APIManager.topHeadlines(country: newsCountry.rawValue, category: category, page: dataPage) { result in
                        self.resultCompletion(result: result)
                    }
                    break
                case .search:
                    let language = newsSettingManager.getSearchLanguage().rawValue
                    APIManager.searchNews(query: searchQuery, language: language, page: dataPage) { result in
                        self.resultCompletion(result: result)
                    }
                    break
                }
            }
        }
    }

    func resultCompletion(result: (Result<NewsAPIResponse, Error>)) -> Void {
        switch result {
        case .success(let success):
            if success.status == "ok" {
                self.articlesNumber = success.totalResults
                success.articles.forEach { article in
                    self.articles.append(article)
                }
                if self.articles.count < success.totalResults {
                    self.dataPage += 1
                }
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            } else {
                print(success.status)
                self.tableView.refreshControl?.endRefreshing()
            }
            self.isLoading = false
        case .failure(let failure):
            print(failure)
            self.tableView.refreshControl?.endRefreshing()
            self.isLoading = false
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
            cell.updateArticleInfo(activeVC: self, newsUrl: newsData.url, author: newsData.author ?? "News啦", title: newsData.title, newsDate: newsDate, newsImageUrl: newsData.urlToImage ?? "")
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

    func scrollToTop() {
        if !articles.isEmpty {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
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
            loadNewsData()
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

// MARK: Keyboard
extension HeadlinesTableViewController {
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
