//
//  NotificationNameEnum.swift
//  NewsApp
//
//  Created by Willy on 2024/4/15.
//

enum NotificationName {
    case reload(displayMode: DisplayMode)
    case scrollToTop(displayMode: DisplayMode)
    
    var name: String {
        switch self {
        case .reload(let displayMode):
            "\(displayMode) - ReloadNewsData"
        case .scrollToTop(let displayMode):
            "\(displayMode) - ScrollToTop"
        }
    }
}
