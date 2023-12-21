//
//  NewsCell.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/4.
//

import UIKit
import Kingfisher

protocol NewsCellDelegate {
    func reloadCell()
}

class NewsCell: UITableViewCell {

    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var NewsDateLabel: UILabel!
    @IBOutlet weak var markButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var cellImage: UIImageView!

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var previewImage: UIImageView!
    
    @IBOutlet weak var bottomInfoHeightConstraint: NSLayoutConstraint!
    
    let paragraphStyle = NSMutableParagraphStyle()
    
    var article: Article? {
        didSet {
            newsUrl = article!.url
            author = article?.author ?? ""
            title = article?.title ?? ""
            newsDate = String(article?.publishedAt ?? "")
            newsImageUrl = article?.urlToImage ?? ""
            updateMarkIcon()
        }
    }
    var isMark = false
    var mark: Mark?
    var markedArticle: MarkedArticle? {
        get {
            guard let mark = mark, let article = article else { return nil }
            return MarkedArticle(mark: mark, article: article)
        }
    }
    var activeVC: UIViewController?
    var newsUrl: String = ""
    var author: String = "" {
        didSet {
            authorLabel.text = author
        }
    }
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    var newsDate: String = "" {
        didSet {
            NewsDateLabel.attributedText = NSAttributedString(string: utils.getNewsCellDate(dateStr: newsDate, isForMark: false), attributes: [.paragraphStyle: paragraphStyle])
            bottomInfoHeightConstraint.constant = newsDate.contains("\n") ? 50 : 20
        }
    }
    
    var newsImageUrl: String = "" {
        didSet {
            updateImage()
        }
    }

    var delegate: NewsCellDelegate?

    lazy var criticalMenuItem = UIAction(title: R.string.localizable.normal(), image: UIImage(systemName: "bookmark.fill")?.withTintColor(Mark.critical.color, renderingMode: .alwaysOriginal)) { _ in
        self.changeMark(mark: .critical)
    }

    lazy var criticalityMenuItem = UIAction(title: R.string.localizable.attention(), image: UIImage(systemName: "bookmark.fill")?.withTintColor(Mark.criticality.color, renderingMode: .alwaysOriginal)) { _ in
        self.changeMark(mark: .criticality)
    }

    lazy var significantCriticalityMenuItem = UIAction(title: R.string.localizable.important(), image: UIImage(systemName: "bookmark.fill")?.withTintColor(Mark.significantCriticality.color, renderingMode: .alwaysOriginal)) { _ in
        self.changeMark(mark: .significantCriticality)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.alignment = .left
        updateMarkMenu()
    }
  
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // code init
    //    required init(author: String, title: String, newsDate: String) {
    //        self.author = author
    //        self.title = title
    //        self.newsDate = newsDate
    //        super.init(style: .default, reuseIdentifier: "NewsCell")
    //    }
    
    func updateArticleInfo(activeVC: UIViewController, article: Article) {
        self.activeVC = activeVC
        self.delegate = activeVC as? any NewsCellDelegate
        self.article = article
    }
    
    func updateImage() {
        let placeholderImage = UIImage(named: "noPhoto")
        let placeholderColorImage = placeholderImage
        guard let url = URL(string: newsImageUrl) else {
            cellImage.image = placeholderColorImage
            backgroundImageView.image = nil
            previewImage.image = nil
            return
        }
        
        cellImage.kf.indicatorType = .activity
        cellImage.kf.setImage(with: url, placeholder: placeholderColorImage) { result in
            switch result {
            case .success(_):
                self.backgroundImageView.kf.setImage(with: url, placeholder: placeholderColorImage)
                self.previewImage.kf.setImage(with: url, placeholder: placeholderColorImage)
            case .failure(let error):
                print("News Image Download error: \(error)")
            }
        }
    }

    @IBAction func saveNews(_ sender: Any) {
        if isMark {
            let cancelAct = UIAlertAction(title: R.string.localizable.cancel(), style: .cancel) { _ in
                self.activeVC?.presentAlertDismiss()
            }
            let comfirm = UIAlertAction(title: R.string.localizable.delete(), style: .destructive) { _ in
                guard let markedArticle = self.markedArticle else { return }
                newsSettingManager.deleteNewsMarkList(markedArticle)
                self.mark = nil
                self.updateMarkIcon()
                self.delegate?.reloadCell()
            }
            activeVC?.presentAlert(title: R.string.localizable.deleteMark(), message: "", action: [cancelAct, comfirm])
        } else {
            changeMark(mark: .critical)
            if (activeVC?.presentedViewController) != nil {
                activeVC?.dismiss(animated: true)
            }
        }
    }

    @IBAction func shareNews(_ sender: Any) {
        let textToShare = title
        let urlToShare = URL(string: newsUrl)
        let objectsToShare = [textToShare, urlToShare!] as [Any]
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop]
        guard let activeVC else { return }
        activityViewController.popoverPresentationController?.sourceView = activeVC.view
        activeVC.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func blockSource() {
        guard let author = article?.author else { return }
        newsSettingManager.updateInsertBlockedSource(source: author)
        delegate?.reloadCell()
    }

    func updateMarkIcon() {
        let article = newsSettingManager.isMarkedArticleTuple(news: self.article!)
        self.isMark = article.isMark
        self.mark = article.mark
        if isMark {
            markButton.setImage(UIImage(systemName: "bookmark.fill")?.withTintColor(mark!.color, renderingMode: .alwaysOriginal), for: .normal)
        } else {
            markButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
        }
        updateMarkMenu()
    }

    //MARK: Change Mark
    func updateMarkMenu() {
        var menuActions: [UIAction] = []
        switch mark {
        case .critical:
            menuActions.append(criticalityMenuItem)
            menuActions.append(significantCriticalityMenuItem)
        case .criticality:
            menuActions.append(criticalMenuItem)
            menuActions.append(significantCriticalityMenuItem)
        case .significantCriticality:
            menuActions.append(criticalMenuItem)
            menuActions.append(criticalityMenuItem)
        case nil:
            menuActions.append(criticalMenuItem)
            menuActions.append(criticalityMenuItem)
            menuActions.append(significantCriticalityMenuItem)
        }
        markButton.menu = UIMenu(children: menuActions)
    }

    func changeMark(mark: Mark) {
        self.mark = mark
        guard let markedArticle = self.markedArticle else { return }
        newsSettingManager.updateNewsMarkList(markedArticle)
        delegate?.reloadCell()
    }
}

extension UIViewController {
    func presentAlert(title: String = "", message: String = "", action: [UIAlertAction] = []) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        action.forEach { act in
            alert.addAction(act)
        }
        
        self.present(alert, animated: true, completion: {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.presentAlertDismiss)))
        })
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
