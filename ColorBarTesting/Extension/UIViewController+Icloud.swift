//
//  UIViewController+Icloud.swift
//  ColorBarTesting
//
//  Created by Willy on 2023/12/11.
//

import Foundation
import CloudKit

func checkIcloudState() {
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
}
