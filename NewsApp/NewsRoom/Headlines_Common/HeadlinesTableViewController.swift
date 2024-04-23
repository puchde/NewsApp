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
    @IBOutlet weak var collectionView: UICollectionView!
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
                collectionView.refreshControl?.beginRefreshing()
            } else {
                collectionView.refreshControl?.endRefreshing()
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
        collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        configureCellSize()
    }
    
    deinit {
        print("\(String(describing: page)) is deinit")
    }
}

//MARK: Init
extension HeadlinesTableViewController {
    func initView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: NewsHeadlinesCell.ClassID, bundle: nil), forCellWithReuseIdentifier: NewsHeadlinesCell.ClassID)
        collectionView.register(UINib(nibName: NewsHeadlinesImageCell.ClassID, bundle: nil), forCellWithReuseIdentifier: NewsHeadlinesImageCell.ClassID)
        collectionView.refreshControl = freshControl
        collectionView.backgroundColor = .systemGroupedBackground
        defaultCoverView.isUserInteractionEnabled = false
        
        addNotification(selector: #selector(scrollToTop), name: NotificationName.scrollToTop(displayMode: displayMode).name)
        addNotification(selector: #selector(reloadDataAct), name: NotificationName.reload(displayMode: displayMode).name)
    }
}

//MARK: CollectionView Data
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
                    self.collectionView.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.collectionView.refreshControl?.endRefreshing()
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
        collectionView.reloadData()
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
        self.collectionView.reloadData()
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

//MARK: CollectionView Cell
extension HeadlinesTableViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tableViewArticles.isEmpty ? 0 : tableViewArticles[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard !tableViewArticles.isEmpty else { return UICollectionViewCell() }
        let sectionNewsData = tableViewArticles[indexPath.section]
        let newsData = sectionNewsData[indexPath.row]
        let cornerSetting = CellCornerSetting(indexPath.row == 0 ? true : false,
                                              indexPath.row == sectionNewsData.count - 1 ? true : false)
        if let imageUrl = newsData.urlToImage, !imageUrl.isEmpty {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsHeadlinesImageCell.ClassID, for: indexPath) as? NewsHeadlinesImageCell, !articles.isEmpty {
                cell.updateImageArticleInfo(activeVC: self, article: newsData, cornerSetting: cornerSetting)
                return cell
            }
        } else {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsHeadlinesCell.ClassID, for: indexPath) as? NewsHeadlinesCell, !articles.isEmpty {
                cell.updateArticleInfo(activeVC: self, article: newsData, cornerSetting: cornerSetting)
                return cell
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.isSelected = false
        let selectNewsUrl = tableViewArticles[indexPath.section][indexPath.row].url
        if let url = URL(string: selectNewsUrl) {
            let vc = getSafariVC(url: url, delegateVC: self)
            self.present(vc, animated: true)
            self.modalPresentationStyle = .fullScreen
        }
    }
    
    @objc func scrollToTop() {
        if !articles.isEmpty {
            collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
}

//MARK: Collection View
extension HeadlinesTableViewController {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        tableViewArticles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // MARK: - CollectionView Padding
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .init(top: 8, left: 0, bottom: 8, right: 0)
    }
    
    // MARK: - CollectionView layout
    func configureCellSize() {
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.estimatedItemSize = .zero
        layout?.minimumInteritemSpacing = 0
        layout?.scrollDirection = .vertical
    }
    
    // MARK: - Cell Size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = floor(collectionView.bounds.width - 36)
        if !tableViewArticles.isEmpty,
           let imageUrl = tableViewArticles[indexPath.section][indexPath.row].urlToImage,
           !imageUrl.isEmpty {
            let title = tableViewArticles[indexPath.section][indexPath.row].title
            let h = utils.getHeightForView(text: title, font: .boldSystemFont(ofSize: 20), width: width)
            let height = h > maxHeight ? maxHeight : h
            let cellHeight = baseCellHeight + width * 0.5 + (height - 60)
            return CGSize(width: cellWidth, height: cellHeight)
        }
        return CGSize(width: cellWidth, height: baseCellHeight)
    }
}

// MARK: - TableView Cell Preview
extension HeadlinesTableViewController: NewsCollectionViewCellDelegate {
    var newsCollectionView: UICollectionView {
        self.collectionView
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let preview: UIContextMenuContentPreviewProvider = {
            collectionView.cellForItem(at: indexPath)?.isSelected = false
            let selectNewsUrl = self.tableViewArticles[indexPath.section][indexPath.row].url
            if let url = URL(string: selectNewsUrl) {
                return self.getSafariVC(url: url, delegateVC: self)
            }
            return nil
        }
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: preview) { _ in
            self.makePreviewMenu(indexPath: indexPath)
        }
    }
}

//MARK: News Cell Delegate
extension HeadlinesTableViewController: NewsCellDelegate {
    func reloadCell() {
        let oldValue = tableViewArticles
        setupTableViewArticles()
        if oldValue == tableViewArticles,
           let min = collectionView.indexPathsForVisibleItems.min()?.section,
           let max = collectionView.indexPathsForVisibleItems.max()?.section {
            collectionView.reloadSections(IndexSet(min...max))
        } else {
            collectionView.reloadData()
        }
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
