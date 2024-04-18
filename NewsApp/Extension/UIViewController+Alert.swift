//
//  UIViewController+Alert.swift
//  NewsApp
//
//  Created by Willy on 2024/4/15.
//

import UIKit

extension UIViewController {
    func presentAlert(title: String = "", message: String = "", action: [UIAlertAction] = [], preferredStyle: UIAlertController.Style = .alert) {
        /// Pad預設為Alert樣式
        var preferredStyle = UIDevice.current.userInterfaceIdiom == .pad ? .alert : preferredStyle
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        action.forEach { act in
            alert.addAction(act)
        }
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: {
                alert.view.superview?.isUserInteractionEnabled = true
                alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.presentAlertDismiss)))
            })
        }
    }
    
    @objc func presentAlertDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func presentConfirmAlert(title: String = "", message: String = "") {
        let confirm = UIAlertAction(title: R.string.localizable.confirm(), style: .default) { _ in
            self.dismiss(animated: true)
        }
        presentAlert(title: title, message: message, action: [confirm])
    }
    
    func presentNoActionAlert(title: String = "", message: String = "") {
        presentAlert(title: title, message: message, action: [])
    }
}
