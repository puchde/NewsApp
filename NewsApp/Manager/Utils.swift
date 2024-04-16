//
//  Utils.swift
//  ColorBarTesting
//
//  Created by Willy on 2023/12/21.
//

import Foundation
import UIKit

struct Utils {
    
    static let shared = Utils()
    
    let publishedAtFormatter = DateFormatter()
    let publishedAtTransformFormatter = DateFormatter()
    let tagFormatter = DateFormatter()
    
    init() {
        publishedAtFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        publishedAtFormatter.locale = Locale(identifier: "en_US_POSIX")
        publishedAtTransformFormatter.dateFormat = "yy-MM-dd"
        publishedAtTransformFormatter.timeZone = TimeZone.current
        publishedAtTransformFormatter.locale = Locale(identifier: "en_US_POSIX")
        tagFormatter.dateFormat = "MM-dd HH:mm"
        tagFormatter.timeZone = TimeZone.current
        tagFormatter.locale = Locale(identifier: "en_US_POSIX")
    }
}

// MARK: - Cell DateFormatter
extension Utils {
    func getNewsCellDate(dateStr: String, isForMark: Bool) -> String {
        // Input
        // 1. Search Cell: "yyyy-MM-dd HH:mm" (GMT)
        // 2. MarkList Cell: "✏️ yy-MM-dd\n🏷️ MM-dd HH:mm" (current, current)
        // 3. Headline Cell: String
        //
        // Output
        // 1. isMark (MarkList Cell)
        //      -> "✏️ yy-MM-dd\n🏷️ MM-dd HH:mm" (current, current)
        // 2. !isMark (Headline/Search Cell)
        //      -> String
        //      -> "yyyy-MM-dd HH:mm" (current)
        
        var dateStr = dateStr
        if isForMark {
            // Mark
            if let publishedStr = dateStr.split(separator: "\n").first,
               let publishedStr = publishedStr.components(separatedBy: "✏️ ").first,
               let publishedDate = publishedAtTransformFormatter.date(from: String(publishedStr)) {
                // MarkList Cell進行變更Tag
                dateStr = "✏️ \(publishedAtTransformFormatter.string(from: publishedDate))\n🏷️ \(tagFormatter.string(from: Date.now))"
            } else {
                // Search Cell進行變更Tag
                publishedAtFormatter.timeZone = TimeZone(identifier: "GMT")
                let date = publishedAtFormatter.date(from: dateStr)
                dateStr = "✏️ \(publishedAtTransformFormatter.string(from: date ?? Date.now))\n🏷️ \(tagFormatter.string(from: Date.now))"
            }
        } else {
            // Search
            publishedAtFormatter.timeZone = TimeZone(identifier: "GMT")
            if let publishedDate = publishedAtFormatter.date(from: dateStr) {
                publishedAtFormatter.timeZone = .current
                dateStr = publishedAtFormatter.string(from: publishedDate)
            }
        }
        return dateStr
    }
}

// MARK: - Text Size
extension Utils {
    func getLineSizeFromString(string:String, withFont font:UIFont)->CGSize{
        let textSize = string.size(withAttributes: [ NSAttributedString.Key.font:font ])
        return textSize
    }
    
    func getHeightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
       let label = UILabel(frame: CGRectMake(0, 0, width, CGFloat.greatestFiniteMagnitude))
       label.numberOfLines = 0
       label.lineBreakMode = NSLineBreakMode.byWordWrapping
       label.font = font
       label.text = text

       label.sizeToFit()
       return label.frame.height
   }
}
