//
//  NewsAPIEnum.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/4.
//

import Foundation

enum Category: String, CaseIterable {
    case general
    case business
    case health
    case technology
    case science
    case sports
    case entertainment
    
    var chineseName: String {
        switch self {
        case .business:
            return "商業"
        case .entertainment:
            return "娛樂"
        case .general:
            return "一般"
        case .health:
            return "健康"
        case .science:
            return "科學"
        case .sports:
            return "體育"
        case .technology:
            return "科技"
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
        case .technology:
            return 3
        case .science:
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

enum CountryCode: String, CaseIterable {
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
    case none = ""
    
    var chineseName: String {
        switch self {
        case .BR:
            return "巴西"
        case .CN:
            return "中國"
        case .DE:
            return "德國"
        case .FR:
            return "法國"
        case .GB:
            return "英國"
        case .IN:
            return "印度"
        case .TW:
            return "台灣"
        case .JP:
            return "日本"
        case .MX:
            return "墨西哥"
        case .US:
            return "美國"
        case .none:
            return "未選擇"
        }
    }
}

enum SearchIn: String {
    case title
    case description
    case content
    case all = "title,content,description"
    
    var chineseName: String {
        switch self {
        case .title:
            return "標題"
        case .description:
            return "簡述"
        case .content:
            return "內容"
        case .all:
            return "全部內容"
        }
    }
}

enum SearchSortBy: String {
    case relevancy
    case popularity
    case publishedAt
    
    var chineseName: String {
        switch self {
        case .relevancy:
            return "相關度最高"
        case .popularity:
            return "最熱門排序"
        case .publishedAt:
            return "最新排序"
        }
    }
}

enum DisplayMode: String {
    case headline
    case search
}

enum SearchLanguage: CaseIterable {
    case zh
    case ar
    case de
    case en
    case es
    case fr
    case hi
    case it
    case nl
    case no
    case pt
    case ru
    case sv
    case ur

    var chineseName: String {
        switch self {
        case .zh:
            return "中文"
        case .ar:
            return "阿拉伯語"
        case .de:
            return "德語"
        case .en:
            return "英語"
        case .es:
            return "西班牙語"
        case .fr:
            return "法語"
        case .hi:
            return "印地語"
        case .it:
            return "意大利語"
        case .nl:
            return "荷蘭語"
        case .no:
            return "挪威語"
        case .pt:
            return "葡萄牙語"
        case .ru:
            return "俄語"
        case .sv:
            return "瑞典語"
        case .ur:
            return "烏爾都語"
        }
    }
}
