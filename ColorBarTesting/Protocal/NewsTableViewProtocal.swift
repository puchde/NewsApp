//
//  NewsTableViewProtocal.swift
//  ColorBarTesting
//
//  Created by Willy on 2023/11/14.
//

import Foundation
import UIKit

protocol NewsTableViewProtocal {
    var newsTableView: UITableView { get }
}

extension NewsTableViewProtocal {
    func makeTargetedPreview(for configuration: UIContextMenuConfiguration, isShow: Bool) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath else { return nil }
        guard let cell = newsTableView.cellForRow(at: indexPath) as? NewsCell else { return nil }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        if isShow {
            cell.previewImage.alpha = 1
        } else {
            cell.previewImage.alpha = 0.1
        }
        return UITargetedPreview(view: cell.previewImage, parameters: parameters)
    }
    
    func makePreviewMenu(indexPath: IndexPath) -> UIMenu {
        if let newsCell = newsTableView.cellForRow(at: indexPath) as? NewsCell {
            let markIcon = UIImage(systemName: "bookmark.fill")
            markIcon?.withTintColor(.orange, renderingMode: .alwaysOriginal)
            
            return UIMenu(title: "選單", children: [
                UIAction(title: "分享", image: UIImage(systemName: "square.and.arrow.up")) { action in
                    newsCell.shareNews(self)
                },
                UIAction(title: newsCell.isMark ? "刪除標記" : "加標記", image: newsCell.isMark ? UIImage(systemName: "minus.circle") : markIcon, attributes: newsCell.isMark ? .destructive : .keepsMenuPresented) { action in
                    newsCell.saveNews(self)
                    return
                }
            ])
        } else {
            return UIMenu()
        }
    }
}
