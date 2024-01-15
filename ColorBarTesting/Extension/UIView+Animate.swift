//
//  UIView+Animate.swift
//  ColorBarTesting
//
//  Created by Willy on 2024/1/15.
//

import UIKit

extension UIView {
    func startRotationAnimate() {
        let rotationAnimatioin = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimatioin.toValue = Double.pi * 2.0
        rotationAnimatioin.duration = 1.5
        rotationAnimatioin.repeatCount = .infinity
        self.layer.add(rotationAnimatioin, forKey: "rotationAnimatioin")
    }
    
    func removeAnimate() {
        self.layer.removeAllAnimations()
    }
}
