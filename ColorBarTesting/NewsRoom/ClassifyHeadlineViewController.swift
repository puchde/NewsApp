//
//  ClassifyHeadlineViewController.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/3.
//

import UIKit

class ClassifyHeadlineViewController: UIViewController {

    @IBOutlet weak var classifyCollectionView: UICollectionView!
    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var leftButtonItem: UIBarButtonItem!

    var selectNewsUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
}

//MARK: Init
extension ClassifyHeadlineViewController {
    func initView() {
        leftButtonItem.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 25), .foregroundColor: UIColor.label], for: .disabled)
        leftButtonItem.isEnabled = false
        classifyCollectionView.delegate = self
        classifyCollectionView.dataSource = self
        classifyCollectionView.contentInsetAdjustmentBehavior = .never
        classifyCollectionView.register(UINib(nibName: "ClassifyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "classifyCell")
        if let pageVC = children.first as? HeadlinesPageViewController {
            pageVC.headlinesDelegate = self
        }
    }
}

//MARK: CollectionView
extension ClassifyHeadlineViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Category.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = classifyCollectionView.dequeueReusableCell(withReuseIdentifier: "classifyCell", for: indexPath) as? ClassifyCollectionViewCell {
            cell.category = Category.allCases[indexPath.row]
            cell.updateCell()
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        newsSettingManager.updateSetting(setting: Category.allCases[indexPath.row])
        collectionView.visibleCells.forEach { cell in
            if let classifyCell = cell as? ClassifyCollectionViewCell {
                classifyCell.updateCell()
            }
        }
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

//MARK: 實作HeadlinesDelegate
extension ClassifyHeadlineViewController: HeadlinesDelegate {
    func updateClassify(page: Int) {
        let indexPath = IndexPath(row: page, section: 0)
        classifyCollectionView.reloadData()
        classifyCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}
