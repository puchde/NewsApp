//
//  ClassifyCollectionViewCell.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/5.
//

import UIKit

class ClassifyCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var lineImageView: UIImageView!
    var category: Category = .general
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
        
    func updateCell() {
        self.textLabel.text = self.category.chineseName
        if self.category == newsSettingManager.getCategory() {
            self.textLabel.textColor = UIColor.label
            self.lineImageView.backgroundColor = UIColor.label
        } else {
            self.textLabel.textColor = UIColor.secondaryLabel
            self.lineImageView.backgroundColor = UIColor.secondaryLabel
        }
    }
}
