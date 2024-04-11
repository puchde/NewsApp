//
//  NewsAPIResponse.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/3.
//

import Foundation
import UIKit

// MARK: everything API, Headlines API
struct NewsAPIResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

struct Article: Codable, Equatable {
    static func == (lhs: Article, rhs: Article) -> Bool {
        lhs.url == rhs.url
    }

    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    var publishedAt: String
    let content: String?
    
    // Headline 分類
    var group: Int = 0
}

struct Source: Codable {
    let id: String?
    let name: String
}

struct NewsAPIProtobufResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: Data
}

//MARK: 
struct MarkedArticle: Codable, Equatable {
    static func == (lhs: MarkedArticle, rhs: MarkedArticle) -> Bool {
        lhs.article == rhs.article
    }
    
    let mark: NewsMark
    var article: Article
}

enum NewsMark: Codable, CaseIterable {
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
