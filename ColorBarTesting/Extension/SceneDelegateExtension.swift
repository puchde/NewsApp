//
//  SceneDelegateExtension.swift
//  ColorBarTesting
//
//  Created by Willy on 2024/1/29.
//

import Foundation
import SafariServices

extension SceneDelegate {
    func getSafariVC(url: URL, delegateVC: SFSafariViewControllerDelegate?) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = newsSettingManager.isAutoRead()
        let safariViewController = SFSafariViewController(url: url, configuration: config)
        safariViewController.delegate = delegateVC
        return safariViewController
    }
}

extension SceneDelegate {
    func getCurrentViewController(_ viewController: UIViewController) -> UIViewController? {
        if let presentedViewController = viewController.presentedViewController {
            return getCurrentViewController(presentedViewController)
        }
        else if let navigationController = viewController as? UINavigationController {
            return navigationController.visibleViewController
        }
        else if let tabBarController = viewController as? UITabBarController {
            return tabBarController.selectedViewController
        }
        else {
            return viewController
        }
    }
}
