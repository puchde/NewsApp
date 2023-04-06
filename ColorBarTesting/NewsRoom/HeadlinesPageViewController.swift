//
//  HeadlinesPageViewController.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/6.
//

import UIKit

protocol HeadlinesDelegate {
    func updateClassify(page: Int)
}

class HeadlinesPageViewController: UIPageViewController {
    
    private var page = 0
    private var maxPage = Category.allCases.count
    var headlinesDelegate: HeadlinesDelegate?
    var isPageAnimating = false

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
}

extension HeadlinesPageViewController {
    func initView() {
        self.dataSource = self
        self.delegate = self
        guard let tableVC = getContentViewController(page: page) else { return }
        self.setViewControllers([tableVC], direction: .forward, animated: false)
    }
}

extension HeadlinesPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func getContentViewController(page: Int) -> HeadlinesTableViewController? {
        if page < 0 || page > maxPage || isPageAnimating {
            return nil
        }
        
        guard let tableVC = storyboard?.instantiateViewController(withIdentifier: "headlinesTableViewController") as? HeadlinesTableViewController else {
            return nil
        }
//        isPageAnimating = true
        tableVC.page = page
        return tableVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return getContentViewController(page: page - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return getContentViewController(page: page + 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished {
            isPageAnimating = false
            guard let tableVC = viewControllers?.first as? HeadlinesTableViewController, let nowPage = tableVC.page else {
                return
            }
            self.page = nowPage
            Category.allCases.forEach { category in
                if category.order == nowPage {
                    newsSettingManager.updateSetting(setting: category)
                }
            }
            headlinesDelegate?.updateClassify(page: page)
            print("didFinishAnimating, self.page:\(self.page)")
        }
    }
}
