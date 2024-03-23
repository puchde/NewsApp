//
//  UrlExtention.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2022/11/21.
//

import Foundation

extension URL {
    var urlType: FileType {
        let imageFormats = ["jpg", "jpeg", "png", "gif"]
        let modelFormats = ["mlmodel"]
        if imageFormats.contains(self.pathExtension) {
            return .Image
        }else if modelFormats.contains(self.pathExtension) {
            return .Model
        }
        return .none
    }
}
