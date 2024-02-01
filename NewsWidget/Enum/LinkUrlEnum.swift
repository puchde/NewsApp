//
//  LinkUrlEnum.swift
//  NewsWidgetExtension
//
//  Created by Willy on 2024/2/1.
//

import Foundation

enum LinkUrlSchemaEnum: String {
    case cbtesting
}

enum LinkUrlHostEnum: String {
    case openNews = "open-news"
}

enum LinkUrlEnum {
    case testOpenNews(url: String)
    
    var urlStr: String {
        switch self {
        case .testOpenNews(let url):
            return "\(LinkUrlSchemaEnum.cbtesting.rawValue)://\(LinkUrlHostEnum.openNews.rawValue)?url=\(url)"
        }
    }
}
