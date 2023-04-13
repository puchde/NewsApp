//
//  NewsSettingManager.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/4.
//

import Foundation

class NewsSettingManager {
    //MARK: Common Setting
    private var country: CountryCode = .TW
    private var category: Category = .general
    private var searchPage = 1
    
    //MARK: Search Setting
    private var searchQuery = ""
    private var searchIn: [SearchIn] = [.all]
    private var searchLanguage: SearchLanguage = .zh
    private var searchDateFrom: Date?
//    Calendar.current.date(byAdding: .month, value: -1, to: .now)
    private var searchDateTo: Date = .now
    private var searchSortBy: SearchSortBy = .publishedAt

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

    func getDisplayMode() -> DisplayMode {
        return displayMode
    }
    
    //MARK: Update Setting
    func updateSetting<T>(setting: T) {
        if let newCountry = setting as? CountryCode {
            country = newCountry
            print("country Didset: \(country)")
        } else if let newCategory = setting as? Category {
            category = newCategory
            print("category Didset: \(category)")
        }
    }
        
    func changeSearchPage(page: Int) {
        searchPage = page
    }

    func updateSearchQuery(_ query: String) {
        searchQuery = query
    }

    func updateSearchIn(_ newSearchIn: [SearchIn]) {
        print("old: \(searchIn), new: \(newSearchIn)")
        searchIn = newSearchIn
    }
    
    func updateSearchSortBy(_ newSearchSortBy: SearchSortBy) {
        print("old: \(searchSortBy), new: \(newSearchSortBy)")
        searchSortBy = newSearchSortBy
    }

    func updateSearchLanguage(_ newSearchLanguage: SearchLanguage) {
        print("old: \(searchLanguage), new: \(newSearchLanguage)")
        searchLanguage = newSearchLanguage
    }

    func updateSearchDate(DateTuple: (Date, Date)) {
        searchDateFrom = DateTuple.0
        searchDateTo = DateTuple.1
    }

    func updateDisplayMode(_ mode: DisplayMode) {
        displayMode = mode
    }
}
