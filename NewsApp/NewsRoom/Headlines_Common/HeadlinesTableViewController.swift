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
    
    // MARK: - Cell Data
    var articles = [Article]()
    var tableViewArticles = [[Article]]()
    
    var page: Int?
    var isLoading = false {
        willSet {
            if newValue {
                tableView.refreshControl?.beginRefreshing()
            } else {
                tableView.refreshControl?.endRefreshing()
            }
        }
    }
    var newsCountry: CountryCode = newsSettingManager.getCountry()
    var searchQuery: String {
        get {
            newsSettingManager.getSearchQuery()
        }
    }
    var dataReloadTime: Date = Date()
    
    // MARK: - Cell
    let baseCellHeight = CGFloat(142)
    lazy var width = self.view.bounds.size.width
    let lineSpacing = 8.0
    lazy var maxHeight = utils.getLineSizeFromString(string: "", withFont: .boldSystemFont(ofSize: 20)).height * 4.0 + lineSpacing * 3

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadNewsData()
        tableView.reloadData()
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
        tableView.register(UINib(nibName: NewsCell.ClassID, bundle: nil), forCellReuseIdentifier: NewsCell.ClassID)
        tableView.register(UINib(nibName: NewsContentImageCell.ClassID, bundle: nil), forCellReuseIdentifier: NewsContentImageCell.ClassID)
        tableView.sectionHeaderTopPadding = 0
        tableView.refreshControl = freshControl
        defaultCoverView.isUserInteractionEnabled = false
        
        addNotification(selector: #selector(scrollToTop), name: NotificationName.scrollToTop(displayMode: displayMode).name)
        addNotification(selector: #selector(reloadDataAct), name: NotificationName.reload(displayMode: displayMode).name)
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
            // MARK: - Change Region
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
                dataReloadTime = Date(timeIntervalSince1970: 0)
                updateReloadSetting()
            }
            break
        case .search:
            break
        }
        articles.removeAll()
        tableViewArticles.removeAll()
        tableView.reloadData()
        loadNewsData()
    }
    
    func loadNewsData() {
        if isLoading {
            print("Loading啦")
            return
        } else {
            if articles.isEmpty {
                isLoading = true
                
                self.defaultCoverView.isHidden = true
                
                switch displayMode {
                case .headline:
                    guard let page, let category = Category.fromOrder(page)?.rawValue else {
                        return
                    }
                    APIManager.topHeadlines(country: newsCountry.rawValue, category: category) { result in
                        self.resultCompletion(result: result)
                    }
                    break
                case .search:
                    let language = newsSettingManager.getSearchLanguage().rawValue
                    APIManager.searchNews(query: searchQuery, language: language) { result in
                        self.resultCompletion(result: result)
                    }
                    break
                }
            } else {
                isLoading = false
                setupTableViewArticles()
            }
        }
    }

    func resultCompletion(result: (Result<NewsAPIProtobufResponse, Error>)) -> Void {
        switch result {
        case .success(let success):
            if success.status == "OK" {
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
                self.view.makeToast("Data Error")
            }
        case .failure(let failure):
            print(failure)
            self.view.makeToast("Data Failure")
        }
        self.isLoading = false
        self.tableView.reloadData()
    }
    
    func setupTableViewArticles() {
        let source = newsSettingManager.getBlockedSource()
        let filterArticles = articles.filter{!source.contains($0.author ?? "")}
        tableViewArticles.removeAll()
        let maxGroup = articles.last?.group ?? 1
        for i in 0 ... maxGroup {
            let a = filterArticles.filter({$0.group == i})
            if !a.isEmpty {
                tableViewArticles.append(a)
            }
        }
    }
}

//MARK: TableView Cell
extension HeadlinesTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewArticles[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !tableViewArticles.isEmpty else { return UITableViewCell() }
        let newsData = tableViewArticles[indexPath.section][indexPath.row]
        if let imageUrl = newsData.urlToImage, !imageUrl.isEmpty {
            if let cell = tableView.dequeueReusableCell(withIdentifier: NewsContentImageCell.ClassID, for: indexPath) as? NewsContentImageCell, !articles.isEmpty {
                cell.updateImageArticleInfo(activeVC: self, article: newsData)
                tableView.deselectRow(at: indexPath, animated: false)
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: NewsCell.ClassID, for: indexPath) as? NewsCell, !articles.isEmpty {
                cell.updateArticleInfo(activeVC: self, article: newsData)
                tableView.deselectRow(at: indexPath, animated: false)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
        let selectNewsUrl = tableViewArticles[indexPath.section][indexPath.row].url
        if let url = URL(string: selectNewsUrl) {
            let vc = getSafariVC(url: url, delegateVC: self)
            self.present(vc, animated: true)
            self.modalPresentationStyle = .fullScreen
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !tableViewArticles.isEmpty,
           let imageUrl = tableViewArticles[indexPath.section][indexPath.row].urlToImage,
           !imageUrl.isEmpty {
            let title = tableViewArticles[indexPath.section][indexPath.row].title
            let h = utils.getHeightForView(text: title, font: .boldSystemFont(ofSize: 20), width: width)
            let height = h > maxHeight ? maxHeight : h
            return baseCellHeight + width * 0.5 + (height - 60)
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
            return .leastNormalMagnitude + 8
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
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if freshControl.isRefreshing {
            reloadDataAct()
        }
    }
}

extension HeadlinesTableViewController: SFSafariViewControllerDelegate {
    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
        return []
    }
}
