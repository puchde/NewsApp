//
//  UserDefaultsExtension.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/15.
//

import Foundation

extension UserDefaults {
    /// 遵守Codable协议的set方法
    ///
    /// - Parameters:
    ///   - object: 泛型的对象
    ///   - key: 键
    ///   - encoder: 序列化器
    public func setCodableObject<T: Codable>(_ object: T, forKey key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {
        let data = try? encoder.encode(object)
        set(data, forKey: key)
    }

    /// 遵守Codable协议的get方法
    ///
    /// - Parameters:
    ///   - type: 泛型的类型
    ///   - key: 键
    ///   - decoder: 反序列器
    /// - Returns: 可选类型的泛型的类型对象
    public func getCodableObject<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let data = value(forKey: key) as? Data else { return nil }
        return try? decoder.decode(type.self, from: data)
    }
}
