//
//  NewsWidgetBundle.swift
//  NewsWidget
//
//  Created by Willy on 2024/1/16.
//

import WidgetKit
import SwiftUI

let userDefaultGroup = UserDefaults(suiteName: UserdefaultsGroup.widgetShared.rawValue)

@main
struct NewsWidgetBundle: WidgetBundle {
    var body: some Widget {
        NewsWidget()
        NewsWidgetLiveActivity()
    }
}
