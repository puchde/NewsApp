//
//  UIViewController+Icloud.swift
//  ColorBarTesting
//
//  Created by Willy on 2023/12/11.
//

import Foundation
import CloudKit
import UserNotifications

func checkAuthorizationState() {
    // MARK: - iCloud
    if FileManager.default.ubiquityIdentityToken != nil {
        print("iCloud Available")
    } else {
        print("iCloud Unavailable")
    }
    
    CKContainer.default().accountStatus { (accountStatus, error) in
        switch accountStatus {
        case .available:
            print("iCloud Available")
            newsSettingManager.icloudState = true
        case .noAccount:
            print("No iCloud account")
        case .restricted:
            print("iCloud restricted")
        case .couldNotDetermine:
            break
        case .temporarilyUnavailable:
            break
        @unknown default:
            break
        }
    }
    
    // MARK: - Notification
    UNUserNotificationCenter.current().getNotificationSettings { (settings) in
        if(settings.authorizationStatus == .authorized) {
            print("Push notification is enabled")
            newsSettingManager.notificationState = true
        } else {
            print("Push notification is not enabled")
            newsSettingManager.notificationState = false
        }
    }
}
