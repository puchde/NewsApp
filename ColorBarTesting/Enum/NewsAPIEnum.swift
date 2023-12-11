//
//  NewsAPIEnum.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/4.
//

import Foundation
import UIKit

enum Category: String, CaseIterable, Codable {
    case general
    case business
    case health
    case science
    case technology
    case sports
    case entertainment
    
    var chineseName: String {
        switch self {
        case .business:
            return R.string.localizable.classifyBusiness()
        case .entertainment:
            return R.string.localizable.classifyEntertainment()
        case .general:
            return R.string.localizable.classifyGeneral()
        case .health:
            return R.string.localizable.classifyHealth()
        case .sports:
            return R.string.localizable.classifySports()
        case .technology:
            return R.string.localizable.classifyTechnology()
        case .science:
            return R.string.localizable.classifyScience()
        }
    }
    
    var order: Int {
        switch self {
        case .general:
            return 0
        case .business:
            return 1
        case .health:
            return 2
        case .science:
            return 3
        case .technology:
            return 4
        case .sports:
            return 5
        case .entertainment:
            return 6
        }
    }
    
    static func getTotal() -> Int {
        return Category.allCases.count
    }
    
    static func fromOrder(_ order: Int) -> Category? {
        return Category.allCases.first(where: { $0.order == order })
    }
}

enum CountryCode: String, CaseIterable, Codable {
    case BR // 巴西
    case CN // 中國
    case DE // 德國
    case FR // 法國
    case GB // 英國
    case IN // 印度
    case TW // 意大利
    case JP // 日本
    case MX // 墨西哥
    case US // 美國
    
    var chineseName: String {
        switch self {
        case .BR:
            return R.string.localizable.countryBr()
        case .CN:
            return R.string.localizable.countryCn()
        case .DE:
            return R.string.localizable.countryDe()
        case .FR:
            return R.string.localizable.countryFr()
        case .GB:
            return R.string.localizable.countryGb()
        case .IN:
            return R.string.localizable.countryIn()
        case .TW:
            return R.string.localizable.countryTw()
        case .JP:
            return R.string.localizable.countryJp()
        case .MX:
            return R.string.localizable.countryMx()
        case .US:
            return R.string.localizable.countryUs()
        }
    }
}

enum SearchIn: String, Codable {
    case title
    case description
    case content
    case all = "title,content,description"
    
    var chineseName: String {
        switch self {
        case .title:
            return R.string.localizable.title()
        case .description:
            return R.string.localizable.description()
        case .content:
            return R.string.localizable.content()
        case .all:
            return R.string.localizable.allContent()
        }
    }
}

enum SearchSortBy: String, Codable {
    case relevancy
    case popularity
    case publishedAt
    
    var chineseName: String {
        switch self {
        case .relevancy:
            return R.string.localizable.relevancy()
        case .popularity:
            return R.string.localizable.popularity()
        case .publishedAt:
            return R.string.localizable.publishedAt()
        }
    }
}

enum DisplayMode: String {
    case headline
    case search
}

enum SearchLanguage: String, CaseIterable, Codable {
    case BR // 巴西
    case CN // 中國
    case DE // 德國
    case FR // 法國
    case GB // 英國
    case IN // 印度
    case TW // 意大利
    case JP // 日本
    case MX // 墨西哥
    case US // 美國
    
    var chineseName: String {
        switch self {
        case .BR:
            return R.string.localizable.countryBr()
        case .CN:
            return R.string.localizable.countryCn()
        case .DE:
            return R.string.localizable.countryDe()
        case .FR:
            return R.string.localizable.countryFr()
        case .GB:
            return R.string.localizable.countryGb()
        case .IN:
            return R.string.localizable.countryIn()
        case .TW:
            return R.string.localizable.countryTw()
        case .JP:
            return R.string.localizable.countryJp()
        case .MX:
            return R.string.localizable.countryMx()
        case .US:
            return R.string.localizable.countryUs()
        }
    }
}

enum Mark: Codable, CaseIterable {
    case critical
    case criticality
    case significantCriticality

    var color: UIColor {
        switch self {
        case .critical:
            return UIColor(red: 1.0, green: 0.8, blue: 0.1, alpha: 1)
        case .criticality:
            return UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1)
        case .significantCriticality:
            return UIColor(red: 0.863, green: 0.078, blue: 0.235, alpha: 1)
        }
    }

    var point: Int {
        switch self {
        case .critical:
            return 3
        case .criticality:
            return 2
        case .significantCriticality:
            return 1
        }
    }
}
