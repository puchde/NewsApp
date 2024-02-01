//
//  NewsWidgetProvider.swift
//  NewsWidgetExtension
//
//  Created by Willy on 2024/1/26.
//

import Foundation
import WidgetKit

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
        let entryDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        
        // Widget Timeline Reload時清空Defaults資料
        if let reloadTimeStr = userDefaultGroup?.string(forKey: UserdefaultKey.widgetReloadTime.rawValue),
           let reloadTime = getReloadDate(dateString: reloadTimeStr),
           reloadTime.addingTimeInterval(50 * 60) < Date() {
            cleanDefaultsData()
        }
                
        // Entry設定各時間所顯示內容
        var widgetPageKey = UserdefaultKey.widgetNewsPage.rawValue
        switch context.family {
        case .systemLarge:
            widgetPageKey = UserdefaultKey.widgetNewsPageLarge.rawValue
        default:
            break
        }
        
        if let news = userDefaultGroup?.getCodableObject([Article].self, with: UserdefaultKey.widgetNews.rawValue),
           let newsCount = userDefaultGroup?.integer(forKey: widgetPageKey) {
            print("Get UserDefaults News")
            let entry = NewsEntry(date: entryDate, news: news, newsNum: newsCount)
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        } else {
            print("Get API News")
            Task{
                if let userDefaults = userDefaultGroup,
                   let country = userDefaults.getCodableObject(CountryCode.self, with: UserdefaultKey.widgetCountry.rawValue)?.rawValue,
                   let category = userDefaults.getCodableObject(Category.self, with: UserdefaultKey.widgetCategory.rawValue)?.rawValue {
                    APIManager.topHeadlines(country: country, category: category) { result in
                        var news = resultCompletion(result: result)
                        
                        userDefaultGroup?.setCodableObject(news, forKey: UserdefaultKey.widgetNews.rawValue)
                        userDefaultGroup?.setValue(news.count, forKey: UserdefaultKey.widgetNewsTotalCount.rawValue)
                        userDefaultGroup?.setValue(0, forKey: UserdefaultKey.widgetNewsPage.rawValue)
                        userDefaultGroup?.setValue(0, forKey: UserdefaultKey.widgetNewsPageLarge.rawValue)
                        
                        userDefaultGroup?.setValue(getReloadDateString(date: Date()), forKey: UserdefaultKey.widgetReloadTime.rawValue)
                        
                        let entry = NewsEntry(date: entryDate, news: news)
                        let timeline = Timeline(entries: [entry], policy: .atEnd)
                        completion(timeline)
                    }
                }
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

extension Provider {
    func getReloadDate(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        return dateFormatter.date(from: dateString)
    }
    
    func getReloadDateString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        return dateFormatter.string(from: date)
    }
}

extension Provider {
    func cleanDefaultsData() {
        if let userDefaultGroup = userDefaultGroup {
            userDefaultGroup.removeObject(forKey: UserdefaultKey.widgetNews.rawValue)
            userDefaultGroup.removeObject(forKey: UserdefaultKey.widgetNewsTotalCount.rawValue)
            userDefaultGroup.removeObject(forKey: UserdefaultKey.widgetNewsPage.rawValue)
            userDefaultGroup.removeObject(forKey: UserdefaultKey.widgetNewsPageLarge.rawValue)
        }
    }
}
