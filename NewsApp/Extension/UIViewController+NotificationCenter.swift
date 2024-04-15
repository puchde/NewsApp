//
//  UIViewController+NotificationCenter.swift
//  NewsApp
//
//  Created by Willy on 2024/4/15.
//

import UIKit

extension UIViewController {
    func addNotification(selector: Selector, name: String) {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: selector, name: Notification.Name(name), object: nil)
    }
    
    func removeNotification(name: String) {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: Notification.Name(name), object: nil)
    }
    
    func postNotification(name: String) {
        let notificationCenter = NotificationCenter.default
        notificationCenter.post(name: Notification.Name(name), object: nil)
    }
}
