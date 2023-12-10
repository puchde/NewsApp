//
//  ClassifyHeadlineViewController.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/3.
//

import UIKit

#if DEBUG
#if ColorBarTesting
import FLEX
#endif
#endif

class ClassifyHeadlineViewController: UIViewController {

    @IBOutlet weak var classifyCollectionView: UICollectionView!
    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var leftButtonItem: UIBarButtonItem!

    var selectNewsUrl = ""
    var classifyLabelWidths = [CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        setupClassifyWidths()
        
#if DEBUG
#if ColorBarTesting
        FLEXManager.shared.showExplorer()
#endif
#endif
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
        
        self.navigationItem.largeTitleDisplayMode = .always

        /// - Container Layout
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: classifyCollectionView.bottomAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    func setupClassifyWidths() {
        var labelTotalWidth = CGFloat(0)
        for category in Category.allCases {
            let size = getSizeFromString(string: category.chineseName, withFont: UIFont.systemFont(ofSize: 15))
            labelTotalWidth += (size.width + 5)
            classifyLabelWidths.append((size.width + 5))
        }
        
        if labelTotalWidth < self.view.frame.width {
            let padding = (self.view.frame.width - labelTotalWidth) / CGFloat(classifyLabelWidths.count)
            var widths = [CGFloat]()
            classifyLabelWidths.forEach { w in
                widths.append(w + padding)
            }
            classifyLabelWidths = widths
        }
    }
}

//MARK: CollectionView
extension ClassifyHeadlineViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Category.getTotal()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = classifyCollectionView.dequeueReusableCell(withReuseIdentifier: "classifyCell", for: indexPath) as? ClassifyCollectionViewCell, let category = Category.fromOrder(indexPath.row) {
            cell.category = category
            cell.updateCell()
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        
        if let pageVC = children.first as? HeadlinesPageViewController, let contentVC = pageVC.getContentViewController(page: row) {
            let page = newsSettingManager.getNowCategoryPage()
            pageVC.setViewControllers([contentVC], direction: page < row ? .forward : .reverse, animated: true)
            pageVC.updatePage(row)
        }
        
        newsSettingManager.updateSettingStorage(data: Category.fromOrder(row))
        
        collectionView.visibleCells.forEach { cell in
            if let classifyCell = cell as? ClassifyCollectionViewCell {
                classifyCell.updateCell()
            }
        }
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: classifyLabelWidths[indexPath.row], height: 45)
    }
    
    func getSizeFromString(string:String, withFont font:UIFont)->CGSize{
        let textSize = string.size(withAttributes: [ NSAttributedString.Key.font:font ])
        return textSize
    }
}

//MARK: 實作HeadlinesDelegate
extension ClassifyHeadlineViewController: HeadlinesDelegate {
    func updateClassify(page: Int) {
        guard page < Category.getTotal() else { return }
        let indexPath = IndexPath(row: page, section: 0)
        classifyCollectionView.reloadData()
        classifyCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}
