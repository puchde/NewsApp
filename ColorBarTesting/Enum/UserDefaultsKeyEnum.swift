//
//  UserDefaultsKeyEnum.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/15.
//

import Foundation

enum UserdefaultsGroup: String {
    case widgetShared = "group.com.widgetSettingData"
}

enum UserdefaultKey: String {
    case settingCountryCode = "settingCountryCode"
    case settingCategory = "settingCategory"
    case settingSearchLanguage = "settingSearchLanguage"
    case settingSearchIn = "settingSearchIn"
    case settingSearchSortBy = "settingSearchSortBy"
    case settingAutoReadMode = "settingAutoReadMode"
    case settingApiKey = "settingApiKey"
    case articles = "articles"
    case searchQuery = "searchQuery"
    case settingBlockedSource = "settingBlockedSource"
    
    //MARK: iCloud use
    case icloudMarkList = "icloudMarkList"
    case icloudMarkListDate = "icloudMarkListDate"
    
    //MARK: Widget use
    case widgetCountry = "widgetCountry"
    case widgetCategory = "widgetCategory"
}
