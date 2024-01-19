//
//  NewsWidget.swift
//  NewsWidget
//
//  Created by Willy on 2024/1/16.
//

import WidgetKit
import SwiftUI
import rswift
import Kingfisher
import Network


//MARK: Entry - Model
struct NewsEntry: TimelineEntry {
    let date: Date
    let news: [Article]
    
    static func defaultEntry() -> NewsEntry {
        return NewsEntry(date: Date(), news: [Article(source: Source(id: "", name: ""), author: "", title: "No News", description: "", url: "", urlToImage: "", publishedAt: "", content: "")])
    }
}

//MARK: Provider - VM
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> NewsEntry {
        NewsEntry.defaultEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (NewsEntry) -> ()) {
        let entry = NewsEntry.defaultEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NewsEntry>) -> ()) {
        
        // Entry設定各時間所顯示內容
        Task{
            var entries: [NewsEntry] = []
            var entryDate = Calendar.current.date(byAdding: .second, value: 15, to: Date())!
            var news: [Article] = []
//            if let userDefaults = UserDefaults(suiteName: "group.com.widgetSettingData"),
//               let country = userDefaults.string(forKey: UserdefaultKey.widgetCountry.rawValue),
//               let category = userDefaults.string(forKey: UserdefaultKey.widgetCategory.rawValue) {
//                await APIManager.topHeadlines(country: country, category: category) { result in
//                    news = resultCompletion(result: result)
//                }
//            }
            
            // For Test
            let country = CountryCode.JP.rawValue
            let category = Category.health.rawValue
            
            APIManager.topHeadlines(country: country, category: category) { result in
                news = resultCompletion(result: result)
                let entry = NewsEntry(date: entryDate, news: news)
                entries.append(entry)
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
    
    func resultCompletion(result: (Result<NewsAPIProtobufResponse, Error>)) -> [Article] {
        var widgetArticles: [Article] = []
        switch result {
        case .success(let success):
            if success.status == "OK" {
                do {
                    let articles = try ArticlesTotalProtobuf(serializedData: success.articles)
                    articles.articles.forEach { a in
                        let source = Source(id: a.source.id, name: a.source.name)
                        let article = Article(source: source, author: a.author, title: a.title, description: a.description_p, url: a.url, urlToImage: a.urlToImage, publishedAt: a.publishedAt, content: a.content)
                        widgetArticles.append(article)
                    }
                } catch {
                    print(error)
                }
            }
        case .failure(let failure):
            print(failure)
        }
        return widgetArticles
    }
}

//MARK: Widget / View - V
struct NewsWidgetEntryView : View {
    var entry: NewsEntry
    
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            VStack {
                Text("Time:")
                Text(entry.date, style: .time)
                Text("News Count:")
                Text("\(entry.news.count)")
                Text("News:")
                Text(entry.news.first?.title ?? "No title")
            }
        case .systemLarge:
            VStack {
                Text("Time:")
                Text(entry.date, style: .time)
                Text("News Count:")
                Text("\(entry.news.count)")
                Text("News:")
                Text(entry.news.first?.title ?? "No title")
            }
        case .systemExtraLarge:
            VStack {
                Text("EXLarge News:")
//                Text(entry.news.last?.title ?? "No title")
            }
        default:
            VStack {
                Text("")
            }
        }
    }
}

struct NewsWidget: Widget {
    let kind: String = "NewsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                NewsWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                NewsWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("NewsTip")
        .description("zz.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}

//#Preview(as: .systemSmall) {
//    NewsWidget()
//} timeline: {
//    SimpleEntry(date: .now, emoji: "😀")
//    SimpleEntry(date: .now, emoji: "🤩")
//}
