//
//  AssetFolder.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

public struct AssetFolder {
    public let url: URL
    public let name: String
    public let path: String
    public var resourcePath: String
    public var imageAssets: [URL]
    public var colorAssets: [URL]
    public var subfolders: [AssetFolder]

    public init(url: URL, name: String, path: String, resourcePath: String, imageAssets: [URL], colorAssets: [URL], subfolders: [AssetFolder]) {
        self.url = url
        self.name = name
        self.path = path
        self.resourcePath = resourcePath
        self.imageAssets = imageAssets
        self.colorAssets = colorAssets
        self.subfolders = subfolders
    }
}
