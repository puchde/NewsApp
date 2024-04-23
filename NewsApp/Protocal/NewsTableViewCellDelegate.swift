//
//  NewsTableViewProtocal.swift
//  ColorBarTesting
//
//  Created by Willy on 2023/11/14.
//

import Foundation
import UIKit

protocol NewsTableViewCellDelegate {
    var newsTableView: UITableView { get }
}

extension NewsTableViewCellDelegate {
    func makeTargetedPreview(for configuration: UIContextMenuConfiguration, isShow: Bool) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath else { return nil }
        guard let cell = newsTableView.cellForRow(at: indexPath) as? NewsMarkListCell else { return nil }
        guard let image = cell.previewImage.image else { return nil }

        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        return UITargetedPreview(view: cell.previewImage, parameters: parameters)
    }

    func makePreviewMenu(indexPath: IndexPath) -> UIMenu {
        if let markCell = newsTableView.cellForRow(at: indexPath) as? NewsMarkListCell {
            let markIcon = UIImage(systemName: "bookmark.fill")?.withTintColor(NewsMark.critical.color, renderingMode: .alwaysOriginal)

            var menuActions = [UIMenuElement]()
            var criticalMenuItem = UIAction(title: R.string.localizable.normal(), image: UIImage(systemName: "bookmark.fill")?.withTintColor(NewsMark.critical.color, renderingMode: .alwaysOriginal)) { _ in
                markCell.changeMark(mark: .critical)
            }

            var criticalityMenuItem = UIAction(title: R.string.localizable.attention(), image: UIImage(systemName: "bookmark.fill")?.withTintColor(NewsMark.criticality.color, renderingMode: .alwaysOriginal)) { _ in
                markCell.changeMark(mark: .criticality)
            }

            var significantCriticalityMenuItem = UIAction(title: R.string.localizable.important(), image: UIImage(systemName: "bookmark.fill")?.withTintColor(NewsMark.significantCriticality.color, renderingMode: .alwaysOriginal)) { _ in
                markCell.changeMark(mark: .significantCriticality)
            }

            menuActions.append(UIAction(title: R.string.localizable.share(), image: UIImage(systemName: "square.and.arrow.up")) { action in
                markCell.shareNews(self)
            })


            if markCell.isMark {

                var changeMarkButton: [UIMenuElement] { 
                    switch markCell.mark {
                    case .critical:
                        return [criticalityMenuItem, significantCriticalityMenuItem]
                    case .criticality:
                        return [criticalMenuItem, significantCriticalityMenuItem]
                    case .significantCriticality:
                        return [criticalMenuItem, criticalityMenuItem]
                    case .none:
                        return []
                    }
                }

                menuActions.append(UIMenu(title: R.string.localizable.changeMark(), image: UIImage(systemName: "bookmark"), children: changeMarkButton))

                menuActions.append(UIAction(title: R.string.localizable.deleteMark(), image: UIImage(systemName: "minus.circle"), attributes: .destructive) { action in
                    markCell.saveNews(self)
                    return
                })
            } else {
                menuActions.append(UIMenu(title: R.string.localizable.addMark(), image: UIImage(systemName: "bookmark"), children: [
                    criticalMenuItem,
                    criticalityMenuItem,
                    significantCriticalityMenuItem
                ]))
            }

            menuActions.append(UIMenu(title: R.string.localizable.more(), image: UIImage(systemName: "ellipsis.circle"), children: [
                UIAction(title: R.string.localizable.blockPublisherSources(), image: UIImage(systemName: "slash.circle"), attributes: .destructive, handler: { action in
                    markCell.blockSource()
                })
            ]))

            return UIMenu(title: R.string.localizable.list(), children: menuActions)
        } else {
            return UIMenu()
        }
    }
}

// MARK: - CollectionViewCell
protocol NewsCollectionViewCellDelegate {
    var newsCollectionView: UICollectionView { get }
}

extension NewsCollectionViewCellDelegate {
    func makePreviewMenu(indexPath: IndexPath) -> UIMenu {
        if let newsCell = newsCollectionView.cellForItem(at: indexPath) as? NewsHeadlinesCell {
            let markIcon = UIImage(systemName: "bookmark.fill")?.withTintColor(NewsMark.critical.color, renderingMode: .alwaysOriginal)

            var menuActions = [UIMenuElement]()
            var criticalMenuItem = UIAction(title: R.string.localizable.normal(), image: UIImage(systemName: "bookmark.fill")?.withTintColor(NewsMark.critical.color, renderingMode: .alwaysOriginal)) { _ in
                newsCell.changeMark(mark: .critical)
            }

            var criticalityMenuItem = UIAction(title: R.string.localizable.attention(), image: UIImage(systemName: "bookmark.fill")?.withTintColor(NewsMark.criticality.color, renderingMode: .alwaysOriginal)) { _ in
                newsCell.changeMark(mark: .criticality)
            }

            var significantCriticalityMenuItem = UIAction(title: R.string.localizable.important(), image: UIImage(systemName: "bookmark.fill")?.withTintColor(NewsMark.significantCriticality.color, renderingMode: .alwaysOriginal)) { _ in
                newsCell.changeMark(mark: .significantCriticality)
            }

            menuActions.append(UIAction(title: R.string.localizable.share(), image: UIImage(systemName: "square.and.arrow.up")) { action in
                newsCell.shareNews(self)
            })


            if newsCell.isMark {

                var changeMarkButton: [UIMenuElement] {
                    switch newsCell.mark {
                    case .critical:
                        return [criticalityMenuItem, significantCriticalityMenuItem]
                    case .criticality:
                        return [criticalMenuItem, significantCriticalityMenuItem]
                    case .significantCriticality:
                        return [criticalMenuItem, criticalityMenuItem]
                    case .none:
                        return []
                    }
                }

                menuActions.append(UIMenu(title: R.string.localizable.changeMark(), image: UIImage(systemName: "bookmark"), children: changeMarkButton))

                menuActions.append(UIAction(title: R.string.localizable.deleteMark(), image: UIImage(systemName: "minus.circle"), attributes: .destructive) { action in
                    newsCell.saveNews(self)
                    return
                })
            } else {
                menuActions.append(UIMenu(title: R.string.localizable.addMark(), image: UIImage(systemName: "bookmark"), children: [
                    criticalMenuItem,
                    criticalityMenuItem,
                    significantCriticalityMenuItem
                ]))
            }

            menuActions.append(UIMenu(title: R.string.localizable.more(), image: UIImage(systemName: "ellipsis.circle"), children: [
                UIAction(title: R.string.localizable.blockPublisherSources(), image: UIImage(systemName: "slash.circle"), attributes: .destructive, handler: { action in
                    newsCell.blockSource()
                })
            ]))

            return UIMenu(title: R.string.localizable.list(), children: menuActions)
        } else {
            return UIMenu()
        }
    }
}
