//
//  UIApplicationExtension.swift
//  NewsApp
//
//  Created by Willy on 2024/4/2.
//

import UIKit
import SafariServices

extension UIApplication {
    func getSafariVC(url: URL, delegateVC: SFSafariViewControllerDelegate?) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = newsSettingManager.isAutoRead()
        let safariViewController = SFSafariViewController(url: url, configuration: config)
        safariViewController.delegate = delegateVC
        return safariViewController
    }
}

extension UIApplication {
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

//MARK: URL Open Handler
extension UIApplication {
    func urlOpenHandle(url: URL) {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController,
           let vc = getCurrentViewController(rootVC) {
            let safariVC = getSafariVC(url: url, delegateVC: nil)
            safariVC.modalPresentationStyle = .fullScreen
            
            if let vc = vc as? SFSafariViewController, let parentVC = vc.presentingViewController {
                vc.dismiss(animated: true)
                parentVC.present(safariVC, animated: true)
            } else {
                rootVC.present(safariVC, animated: true)
            }
        }
    }
}
