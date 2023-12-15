//
//  NewsAPIResponse.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/3.
//

import Foundation

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
    let mark: Mark
    var article: Article
}
