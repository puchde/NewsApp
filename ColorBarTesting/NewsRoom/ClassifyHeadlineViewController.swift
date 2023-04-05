//
//  ClassifyHeadlineViewController.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/3.
//

import UIKit

class ClassifyHeadlineViewController: UIViewController {

    @IBOutlet weak var classifyCollectionView: UICollectionView!
    @IBOutlet weak var leftButtonItem: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var articlesNumber = 0
    var articles: [Article] = []
    var selectNewsUrl = ""
    var isLoadedData = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadNewsData()
        checkYPosition()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        checkYPosition(isShow: true)
    }
}

//MARK: Init
extension ClassifyHeadlineViewController {
    func initView() {
        leftButtonItem.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 25), .foregroundColor: UIColor.label], for: .disabled)
        leftButtonItem.isEnabled = false
        classifyCollectionView.delegate = self
        classifyCollectionView.dataSource = self
        classifyCollectionView.contentInsetAdjustmentBehavior = .never
        classifyCollectionView.register(UINib(nibName: "ClassifyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "classifyCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
        tableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
    }
}

//MARK: CollectionView
extension ClassifyHeadlineViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Category.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = classifyCollectionView.dequeueReusableCell(withReuseIdentifier: "classifyCell", for: indexPath) as? ClassifyCollectionViewCell {
            cell.category = Category.allCases[indexPath.row]
            cell.updateCell()
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        newsSettingManager.updateSetting(setting: Category.allCases[indexPath.row])
        collectionView.visibleCells.forEach { cell in
            if let classifyCell = cell as? ClassifyCollectionViewCell {
                classifyCell.updateCell()
            }
        }
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

//MARK: TableView Data
extension ClassifyHeadlineViewController {
    func loadNewsData(loadMorePage: Bool = false) {
        var page = newsSettingManager.headlinesPage
        if loadMorePage && articles.count == page * 20 {
            page += 1
            newsSettingManager.changeHeadlinesPage(page: page)
            isLoadedData = false
        }
        if !isLoadedData {
            let country = newsSettingManager.country.rawValue
            let category = newsSettingManager.category.rawValue
            APIManager.topHeadlines(country: country, category: category, page: page) { result in
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
extension ClassifyHeadlineViewController: UITableViewDelegate, UITableViewDataSource {
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
extension ClassifyHeadlineViewController {
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
extension ClassifyHeadlineViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toWebView", let webView = segue.destination as? WebViewViewController {
            webView.urlString = selectNewsUrl
        }
    }
}
