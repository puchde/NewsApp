//
//  NewsTabBarViewController.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/9.
//

import UIKit

class NewsTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.firstIndex(of: item), let targetVC = self.viewControllers?[index].children.first else {
            return
        }

        switch targetVC {
        case is ClassifyHeadlineViewController:
            newsSettingManager.updateDisplayMode(.headline)
            print("Headlines Mode")
        case is SearchNewsViewController:
            newsSettingManager.updateDisplayMode(.search)
            print("Search Mode")
        default:
            print("N")
        }
    }
}
