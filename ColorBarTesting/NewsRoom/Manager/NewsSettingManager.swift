//
//  NewsSettingManager.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/4.
//

import Foundation

class NewsSettingManager {
    var country: CountryCode = .TW
    var category: Category = .general
    var headlinesPage = 1
    var searchPage = 1
    
    static let shared = NewsSettingManager()
    
    func updateSetting<T>(setting: T) {
        if let newCountry = setting as? CountryCode {
            country = newCountry
            print("country Didset: \(country)")
        } else if let newCategory = setting as? Category {
            category = newCategory
            print("category Didset: \(category)")
        }
    }
    
    func changeHeadlinesPage(page: Int) {
        headlinesPage = page
    }
    
    func changeSearchPage(page: Int) {
        searchPage = page
    }
    
    func getNowCategoryPage() -> Int {
        return category.order
    }
}
