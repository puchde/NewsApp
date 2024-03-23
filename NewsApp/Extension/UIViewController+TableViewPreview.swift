//
//  UIViewController+TableViewPreview.swift
//  ColorBarTesting
//
//  Created by Willy on 2023/11/14.
//

import Foundation
import UIKit
import SafariServices

extension UIViewController {
    func getSafariVC(url: URL, delegateVC: SFSafariViewControllerDelegate?) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = newsSettingManager.isAutoRead()
        let safariViewController = SFSafariViewController(url: url, configuration: config)
        safariViewController.delegate = delegateVC
        return safariViewController
    }
}

