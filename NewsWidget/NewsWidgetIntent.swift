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
        var newsCount = userDefaultGroup?.integer(forKey: UserdefaultKey.widgetNewsCount.rawValue) {
            if 0 < newsCount {
                newsCount -= 1
                print(newsCount)
                userDefaultGroup?.set(newsCount, forKey: UserdefaultKey.widgetNewsCount.rawValue)
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
        var newsCount = userDefaultGroup?.integer(forKey: UserdefaultKey.widgetNewsCount.rawValue) {
            if newsCount < newsTotal {
                newsCount += 1
                print(newsCount)
                userDefaultGroup?.set(newsCount, forKey: UserdefaultKey.widgetNewsCount.rawValue)
            }
        }
        return .result()
    }
}
