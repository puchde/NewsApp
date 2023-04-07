//
//  HeadlinesTableViewController.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/6.
//

import UIKit

class HeadlinesTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    var page: Int?
    var articlesNumber = 0
    var articles: [Article] = []
    var selectNewsUrl = ""
    var isLoadedData = false

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkYPosition()
        loadNewsData()
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
        tableView.bounces = false
        tableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
    }
}

//MARK: TableView Data
extension HeadlinesTableViewController {
    func scrollToTop() {
        if !articles.isEmpty {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }
    
    func loadNewsData(loadMorePage: Bool = false) {
        var headlinesPage = newsSettingManager.headlinesPage
        if loadMorePage && articles.count == headlinesPage * 20 {
            headlinesPage += 1
            newsSettingManager.changeHeadlinesPage(page: headlinesPage)
            isLoadedData = false
        }
        if !isLoadedData {
            let country = newsSettingManager.country.rawValue
//            let category = newsSettingManager.category.rawValue
            guard let page, let category = Category.fromOrder(page)?.rawValue else { return }
            APIManager.topHeadlines(country: country, category: category, page: headlinesPage) { result in
                switch result {
                case .success(let success):
                    if success.status == "ok" {
                        self.articlesNumber = success.totalResults
                        success.articles.forEach { article in
                            self.articles.append(article)
                        }
                        self.tableView.reloadData()
                        self.isLoadedData = true
                    } else {
                        print(success.status)
                    }
                case .failure(let failure):
                    print(failure)
                }
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
        let newsData = articles[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as? NewsCell {
            let newsDate = String(newsData.publishedAt.prefix(10))
            cell.updateArticleInfo(author: newsData.author ?? "News啦", title: newsData.title, newsDate: newsDate, newsUrl: newsData.url)
            cell.updateImage()
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
