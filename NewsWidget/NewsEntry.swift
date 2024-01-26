//
//  NewsEntry.swift
//  NewsWidgetExtension
//
//  Created by Willy on 2024/1/26.
//

import Foundation
import WidgetKit

//MARK: Entry - Model
struct NewsEntry: TimelineEntry {
    let date: Date
    let news: [Article]
    var newsNum = 0
    
    static func defaultEntry() -> NewsEntry {
        return NewsEntry(date: Date(), news: [Article(source: Source(id: "", name: ""), author: "", title: "No News", description: "", url: "", urlToImage: "", publishedAt: "", content: "")])
    }
    
    static func testEntry() -> NewsEntry {
        return NewsEntry(date: Date(), news: [Article(source: Source(id: "", name: ""), author: "カンテレNEWS", title: "捕虜搭乗とウクライナ側に事前通告、輸送機墜落巡りロ議員が主張 - ロイター (Reuters Japan)", description: "", url: "https://news.google.com/rss/articles/CBMiPmh0dHBzOi8vd3d3My5uaGsub3IuanAvbmV3cy9odG1sLzIwMjQwMTI1L2sxMDAxNDMzNDU4MTAwMC5odG1s0gFCaHR0cHM6Ly93d3czLm5oay5vci5qcC9uZXdzL2h0bWwvMjAyNDAxMjUvYW1wL2sxMDAxNDMzNDU4MTAwMC5odG1s?oc=5", urlToImage: "", publishedAt: "５時間前", content: "")])
    }
}
