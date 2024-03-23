//
//  CustomVIew.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/8.
//

import UIKit

class CustomVIew: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let touchSuperView = super.hitTest(point, with: event)
        guard let touchSuperView else {
            if let vc = self.next as? UIViewController {
                vc.dismiss(animated: true)
            }
            return nil
        }
        return touchSuperView
    }
}
