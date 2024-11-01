//
//  FileManager+Extensions.swift
//  Rswift
//
//  Created by Fatih Doğan on 2024-11-01.
//

import Foundation

extension FileManager {
    func recursiveResourcesOfDirectory(at url: URL) throws ->  [URL] {
        let children = try self.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
        var urls: [URL] = []
        for child in children {
            var isDirectory: ObjCBool = false
            self.fileExists(atPath: child.path, isDirectory: &isDirectory)
            if isDirectory.boolValue {
                if (child.lastPathComponent.hasSuffix(".xcassets")) {
                    urls.append(child)
                } else {
                    urls.append(contentsOf: try recursiveResourcesOfDirectory(at: child))
                }
            } else {
                if child.lastPathComponent.hasSuffix(".swift") {
                    //Ignore
                } else {
                    urls.append(child)
                }
            }
        }
        return urls
    }
}
