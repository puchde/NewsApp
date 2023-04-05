//
//  WebViewViewController.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/4.
//

import UIKit
import WebKit

class WebViewViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    var urlString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))            
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("網頁載入完成")
    }


}
