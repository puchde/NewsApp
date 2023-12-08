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
        guard let image = cell.previewImage.image else { return nil }

        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        return UITargetedPreview(view: cell.previewImage, parameters: parameters)
    }
    
    func makePreviewMenu(indexPath: IndexPath) -> UIMenu {
        if let newsCell = newsTableView.cellForRow(at: indexPath) as? NewsCell {
            let markIcon = UIImage(systemName: "bookmark.fill")?.withTintColor(.orange, renderingMode: .alwaysOriginal)
            
            return UIMenu(title: R.string.localizable.list(), children: [
                UIAction(title: R.string.localizable.share(), image: UIImage(systemName: "square.and.arrow.up")) { action in
                    newsCell.shareNews(self)
                },
                UIAction(title: newsCell.isMark ? R.string.localizable.deleteMark() : R.string.localizable.addMark(), image: newsCell.isMark ? UIImage(systemName: "minus.circle") : markIcon, attributes: newsCell.isMark ? .destructive : .keepsMenuPresented) { action in
                    newsCell.saveNews(self)
                    return
                },
                UIMenu(title: R.string.localizable.more(), image: UIImage(systemName: "ellipsis.circle"), children: [
                    UIAction(title: R.string.localizable.blockPublisherSources(), image: UIImage(systemName: "slash.circle"), attributes: .destructive, handler: { action in
                        newsCell.blockSource()
                    })
                ])
            ])
        } else {
            return UIMenu()
        }
    }
}
