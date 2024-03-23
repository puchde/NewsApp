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

//MARK: URL Open Handler
extension SceneDelegate {
    func urlOpenHandle(url: URL) {
        guard let host = url.host(),
              let query = url.query(),
        let openType = UrlHandleTypeEnum(rawValue: host) else {
            return
        }
        
        switch openType {
        case .openNews:
            if let urlStr = query.split(separator: "url=").first,
               let newsUrl = URL(string: String(urlStr)),
               let rootVC = window?.rootViewController,
               let vc = getCurrentViewController(rootVC) {
                let safariVC = getSafariVC(url: newsUrl, delegateVC: nil)
                safariVC.modalPresentationStyle = .fullScreen
                
                if let vc = vc as? SFSafariViewController, let parentVC = vc.presentingViewController {
                    vc.dismiss(animated: true)
                    parentVC.present(safariVC, animated: true)
                } else {
                    rootVC.present(safariVC, animated: true)
                }
            }
        default:
            break
        }

    }
}
