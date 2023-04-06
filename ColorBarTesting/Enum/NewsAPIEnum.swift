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
