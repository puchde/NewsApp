//
//  UIButtonExtension.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/12.
//

import Foundation
import UIKit

public extension UIButton {
    func getBorderAndRadius() {
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.borderColor = UIColor.secondaryLabel.cgColor
        self.layer.borderWidth = 1.0
        self.clipsToBounds = true
    }

    func setSelectedStatus() {
        let originalImage = UIImage()
        let tintedImage = originalImage.withTintColor(UIColor.secondaryLabel)

        let renderer = UIGraphicsImageRenderer(size: tintedImage.size ?? .zero)
        let imageWithColor = renderer.image { (context) in
            tintedImage.draw(in: CGRect(origin: .zero, size: tintedImage.size ?? .zero))
        }
        self.setBackgroundImage(imageWithColor, for: .selected)
        self.setTitleColor(.red, for: .selected)
    }
}
