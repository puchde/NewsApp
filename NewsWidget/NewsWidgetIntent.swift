//
//  NewsWidgetIntent.swift
//  NewsWidgetExtension
//
//  Created by Willy on 2024/1/26.
//

import Foundation
import AppIntents

//MARK: Intent - ButtonAction
// Widget按鈕觸發perform()進行資料處理，完成後返回result()重新由Provider getTimeline()進行Widget建立
// 目前使用UserDefaults Group進行參數儲存
struct PreviousNewsIntent: AppIntent {
    static var title: LocalizedStringResource = "PreviousNews"
    
    func perform() async throws -> some IntentResult {
        // Widget顯示上一則(newsCount)
        if let newsTotal = userDefaultGroup?.integer(forKey: UserdefaultKey.widgetNewsTotalCount.rawValue),
        var newsCount = userDefaultGroup?.integer(forKey: UserdefaultKey.widgetNewsPage.rawValue) {
            if 0 < newsCount {
                newsCount -= 1
                print(newsCount)
                userDefaultGroup?.set(newsCount, forKey: UserdefaultKey.widgetNewsPage.rawValue)
            }
        }
        return .result()
    }
}

struct NextNewsIntent: AppIntent {
    static var title: LocalizedStringResource = "NextNews"
    
    func perform() async throws -> some IntentResult {
        // Widget顯示下一則(newsCount)
        if let newsTotal = userDefaultGroup?.integer(forKey: UserdefaultKey.widgetNewsTotalCount.rawValue),
        var newsCount = userDefaultGroup?.integer(forKey: UserdefaultKey.widgetNewsPage.rawValue) {
            if newsCount < newsTotal {
                newsCount += 1
                print(newsCount)
                userDefaultGroup?.set(newsCount, forKey: UserdefaultKey.widgetNewsPage.rawValue)
            }
        }
        return .result()
    }
}

struct PreviousNewsIntentLarge: AppIntent {
    static var title: LocalizedStringResource = "PreviousNews"
    
    func perform() async throws -> some IntentResult {
        // Widget顯示上一則(newsCount)
        if let newsTotal = userDefaultGroup?.integer(forKey: UserdefaultKey.widgetNewsTotalCount.rawValue),
        var newsPage = userDefaultGroup?.integer(forKey: UserdefaultKey.widgetNewsPageLarge.rawValue) {
            if 0 < newsPage {
                newsPage -= 1
                userDefaultGroup?.set(newsPage, forKey: UserdefaultKey.widgetNewsPageLarge.rawValue)
            }
        }
        return .result()
    }
}

struct NextNewsIntentLarge: AppIntent {
    static var title: LocalizedStringResource = "NextNews"
    
    func perform() async throws -> some IntentResult {
        // Widget顯示下一則(newsCount)
        if let newsTotal = userDefaultGroup?.integer(forKey: UserdefaultKey.widgetNewsTotalCount.rawValue),
        var newsPage = userDefaultGroup?.integer(forKey: UserdefaultKey.widgetNewsPageLarge.rawValue) {
            if (newsPage + 1) * 3 < newsTotal {
                newsPage += 1
                userDefaultGroup?.set(newsPage, forKey: UserdefaultKey.widgetNewsPageLarge.rawValue)
            }
        }
        return .result()
    }
}

