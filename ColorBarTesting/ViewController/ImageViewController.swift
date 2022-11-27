//
//  ImageViewController.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2022/11/27.
//

import UIKit

class ImageViewController: UIViewController {


    @IBOutlet weak var zoomView: ZoomImageView!
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        zoomView.image = self.image
    }
}
