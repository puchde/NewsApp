//
//  NewsSettingManager.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/4.
//

import Foundation

class NewsSettingManager {
    //MARK: Common Setting
    private var country = {
        if let country = userDefaults.getCodableObject(CountryCode.self, with: UserdefaultKey.settingCountryCode.rawValue) {
            return country
        } else {
            return .TW
        }
    }()
    
    private var category = {
        if let category = userDefaults.getCodableObject(Category.self, with: UserdefaultKey.settingCategory.rawValue) {
            return category
        } else {
            return .general
        }
    }()
    
    private var searchPage = 1
    
    //MARK: Search Setting
    private var searchQuery = ""
    private var searchIn = {
        if let searchIn = userDefaults.getCodableObject([SearchIn].self, with: UserdefaultKey.settingSearchIn.rawValue) {
            return searchIn
        } else {
            return [SearchIn.all]
        }
    }()
    private var searchLanguage = {
        if let language = userDefaults.getCodableObject(SearchLanguage.self, with: UserdefaultKey.settingSearchLanguage.rawValue) {
            return language
        } else {
            return .TW
        }
    }()
    private var searchDateFrom: Date?
//    Calendar.current.date(byAdding: .month, value: -1, to: .now)
    private var searchDateTo: Date = .now
    private var searchSortBy = {
        if let sortBy = userDefaults.getCodableObject(SearchSortBy.self, with: UserdefaultKey.settingSearchSortBy.rawValue) {
            return sortBy
        } else {
            return .none
        }
    }()
    
    private var searchTime: SearchTime = .none

    //MARK: MarkList
    private var newsMarkList: [MarkedArticle] {
        get {
            let list = userDefaults.getCodableObject([MarkedArticle].self, with: UserdefaultKey.articles.rawValue) ?? []
            return list
        }
        set {
            DispatchQueue.global().sync {
                userDefaults.setCodableObject(newValue, forKey: UserdefaultKey.articles.rawValue)
            }
        }
    }
    
    // MARK: - Setting
    private var apiKey = {
        return userDefaults.string(forKey: UserdefaultKey.settingApiKey.rawValue)
    }()
    
    private var isAutoReadMode = {
        return userDefaults.bool(forKey: UserdefaultKey.settingAutoReadMode.rawValue)
    }()
    
    private var blockedSource: Set<String> = {
        let arr = userDefaults.array(forKey: UserdefaultKey.settingBlockedSource.rawValue) as? [String] ?? []
        let set: Set<String> = Set(arr)
        return set
    }()
    
    var icloudState = false

    //MARK: Display Mode
    private var displayMode: DisplayMode = .headline
    
    static let shared = NewsSettingManager()
    
    //MARK: Get Setting
    func getCountry() -> CountryCode {
        return country
    }
    
    func getCategory() -> Category {
        return category
    }
    
    func getNowCategoryPage() -> Int {
        return category.order
    }

    func getSearchQuery() -> String {
        return searchQuery
    }
    
    func getSearchIn(isForApi: Bool = true) -> String {
        if searchIn.count == 1 && searchIn.contains(.all) {
            return isForApi ? SearchIn.all.rawValue : SearchIn.all.chineseName
        } else {
            var searchString = ""
            var searchStringChi = ""
            searchIn.forEach { search in
                searchString += "\(search.rawValue),"
                searchStringChi += "\(search.chineseName),"
            }
            searchString.removeLast()
            searchStringChi.removeLast()
            return isForApi ? searchString : searchStringChi
        }
    }

    func getSearchInArray() -> [SearchIn] {
        return searchIn
    }

    func getSearchSortBy() -> SearchSortBy {
        return searchSortBy
    }
    
    func getSearchDate() -> (String, String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        var fromDate = ""
        if let searchDateFrom {
            fromDate = formatter.string(from: searchDateFrom)
        }
        let toDate = formatter.string(from: searchDateTo)
        return (fromDate, toDate)
    }

    func getSearchLanguage() -> SearchLanguage {
        return searchLanguage
    }
    
    func getSearchTime() -> SearchTime {
        return searchTime
    }

    func getDisplayMode() -> DisplayMode {
        return displayMode
    }

    func getNewsMarkList() -> [MarkedArticle] {
        return newsMarkList
    }

    func isMarkedArticleTuple(news: Article) -> (isMark: Bool, mark: Mark?) {
        if let markedArticle = newsMarkList.first(where: { article in
            article.article == news
        }) {
            return (true, markedArticle.mark)
        }

        return (false, nil)
    }
    
    func isAutoRead() -> Bool {
        return isAutoReadMode
    }
    
    func getApiKey() -> String? {
        return apiKey
    }
    
    func getBlockedSource() -> Set<String> {
        return blockedSource
    }
    
    
    //MARK: Update Setting
    func updateSettingStorage<T>(data: T) {
        switch data {
        case let newCountryCode as CountryCode:
            country = newCountryCode
            userDefaults.setCodableObject(newCountryCode, forKey: UserdefaultKey.settingCountryCode.rawValue)
            print("country Didset: \(country)")
        case let newCategory as Category:
            category = newCategory
            userDefaults.setCodableObject(newCategory, forKey: UserdefaultKey.settingCategory.rawValue)
            print("category Didset: \(category)")
        case let newLanguage as SearchLanguage:
            searchLanguage = newLanguage
            userDefaults.setCodableObject(newLanguage, forKey: UserdefaultKey.settingSearchLanguage.rawValue)
        case let newSearchIn as [SearchIn]:
            searchIn = newSearchIn
            userDefaults.setCodableObject(newSearchIn, forKey: UserdefaultKey.settingSearchIn.rawValue)
        case let newSearchSortBy as SearchSortBy:
            searchSortBy = newSearchSortBy
            userDefaults.setCodableObject(newSearchSortBy, forKey: UserdefaultKey.settingSearchSortBy.rawValue)
        default:
            break
        }
    }
        
    func changeSearchPage(page: Int) {
        searchPage = page
    }

    func updateSearchQuery(_ query: String) {
        searchQuery = query
    }

    /// MARK - 部分搜尋設置 -> updateSettingStorage
//    func updateSearchIn(_ newSearchIn: [SearchIn]) {
//        print("old: \(searchIn), new: \(newSearchIn)")
//        searchIn = newSearchIn
//    }
    
//    func updateSearchSortBy(_ newSearchSortBy: SearchSortBy) {
//        print("old: \(searchSortBy), new: \(newSearchSortBy)")
//        searchSortBy = newSearchSortBy
//    }

//    func updateSearchLanguage(_ newSearchLanguage: SearchLanguage) {
//        print("old: \(searchLanguage), new: \(newSearchLanguage)")
//        searchLanguage = newSearchLanguage
//    }

    func updateSearchDate(DateTuple: (Date, Date)) {
        searchDateFrom = DateTuple.0
        searchDateTo = DateTuple.1
    }
    
    func updateSearchTime(searchTime: SearchTime) {
        self.searchTime = searchTime
    }

    func updateDisplayMode(_ mode: DisplayMode) {
        displayMode = mode
    }

    func updateNewsMarkList(_ news: MarkedArticle) {
        if !newsMarkList.filter({ mArticle in
            mArticle.article == news.article
        }).isEmpty {
            if let index = newsMarkList.firstIndex(where: {$0.article == news.article}) {
                newsMarkList.remove(at: index)
            }
        }
        var news = news
        let formatter = DateFormatter()
        formatter.dateFormat = "yy-MM-dd HH:mm"
        news.article.publishedAt = "🏷️ \(formatter.string(from: Date.now))"
        newsMarkList.append(news)
    }
    
    func overwriteNewsMarkList(_ articles: [MarkedArticle]) {
        newsMarkList = articles
    }

    func deleteNewsMarkList(_ article: MarkedArticle) {
        guard let index = newsMarkList.firstIndex(of: article) else { return }
        newsMarkList.remove(at: index)
    }
    
    func deleteNewsMarkLists() {
        newsMarkList = []
    }
    
    func updateAutoReadMode(isAuto: Bool) {
        isAutoReadMode = isAuto
        userDefaults.setValue(isAuto, forKey: UserdefaultKey.settingAutoReadMode.rawValue)
    }
    
    func updateInsertBlockedSource(source: String) {
        blockedSource.insert(source)
        userDefaults.setValue(Array(blockedSource), forKey: UserdefaultKey.settingBlockedSource.rawValue)
    }
    
    func updateReplaceBlockedSource(source: [String]) {
        blockedSource = Set(source)
        userDefaults.setValue(Array(blockedSource), forKey: UserdefaultKey.settingBlockedSource.rawValue)
    }
}
