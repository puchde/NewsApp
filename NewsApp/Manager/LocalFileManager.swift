//
//  LocalFileManager.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2022/11/18.
//

import Foundation

class LocalFileManager {
    static let shared = LocalFileManager()
    private let fileManager = FileManager.default
    private let folderArr = ["TestData", "Models"]
    let subFolder = (total: "Total", ss: "ss")
    var cachesPath: URL {
        return fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    var testDataPath: URL {
        return cachesPath.appendingPathComponent("TestData", isDirectory: true)
    }

    var testDataTotalPath: URL {
        return testDataPath.appendingPathComponent("Total", isDirectory: true)
    }

    var modelPath: URL {
        return cachesPath.appendingPathComponent("Models", isDirectory: true)
    }
    
    init() {
        folderArr.forEach { name in
            creatFolder(folderName: name)
        }
    }
    
    func urlForUbiquityContainerIdentifier() -> URL? {
        return fileManager.url(forUbiquityContainerIdentifier: nil)
    }
    
    func fileExist(docPath: String) -> Bool {
        return fileManager.fileExists(atPath: docPath)
    }
    
    func creatFolder(rootFolderUrl: URL? = nil, folderName: String) {
        let folderUrl = rootFolderUrl?.appendingPathComponent(folderName) ?? self.cachesPath.appendingPathComponent(folderName)
        let folderExists = (try? folderUrl.checkResourceIsReachable()) ?? false
        do {
            if !folderExists {
                try fileManager.createDirectory(atPath: folderUrl.path, withIntermediateDirectories: true)
            }
        } catch {
            print("DirCreatError: \(error)")
        }
    }
    
    func getDirectoryContents(path: URL) -> [URL]? {
        do {
            return try fileManager.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
        }catch{
            print("getDirError: \(error)")
        }
        return nil
    }
    
    func deleteTestFile() {
        let folderExists = (try? testDataTotalPath.checkResourceIsReachable()) ?? false
        do {
            if folderExists {
                try fileManager.removeItem(at: testDataTotalPath)
            }
        } catch {
            print("DirDeleteError: \(error)")
        }
    }
}
