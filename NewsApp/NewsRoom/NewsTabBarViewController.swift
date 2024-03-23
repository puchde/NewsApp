//
//  NewsTabBarViewController.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/9.
//

import UIKit

class NewsTabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.firstIndex(of: item), let targetVC = self.viewControllers?[index].children.first else {
            return
        }

        switch targetVC {
        case is ClassifyHeadlineViewController:
            newsSettingManager.updateDisplayMode(.headline)
            if self.selectedIndex == 0 {
                NotificationCenter.default.post(name: Notification.Name("\(DisplayMode.headline.rawValue) - ScrollToTop"), object: nil)
            }
            print("Headlines Mode")
        case is SearchNewsViewController:
            newsSettingManager.updateDisplayMode(.search)
            if self.selectedIndex == 1 {
                NotificationCenter.default.post(name: Notification.Name("\(DisplayMode.search.rawValue) - ScrollToTop"), object: nil)
            }
            print("Search Mode")
        default:
            print("N")
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return viewController != tabBarController.selectedViewController
    }
}
