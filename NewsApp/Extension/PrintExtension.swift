//
//  PrintExtension.swift
//  ColorBarTesting
//
//  Created by Willy on 2023/12/1.
//

import Foundation

public func print(_ object: Any) {
    #if DEBUG
    Swift.print(object)
    #endif
}
