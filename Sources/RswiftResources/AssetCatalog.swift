//
//  AssetCatalog.swift
//  RswiftResources
//
//  Created by Tom Lokhorst on 2021-06-13.
//

import Foundation

public struct AssetCatalog {
    public let filename: String
    public let root: Namespace

    public init(filename: String, root: Namespace) {
        self.filename = filename
        self.root = root
    }
}

extension AssetCatalog {
    public struct Namespace {
        public var subnamespaces: [String: Namespace] = [:]
        public var colors: [String] = []
        public var images: [String] = []
        public var files: [String] = []

        public init(
            subnamespaces: [String: Namespace],
            colors: [String],
            images: [String],
            files: [String]
        ) {
            self.subnamespaces = subnamespaces
            self.colors = colors
            self.images = images
            self.files = files
        }
    }
}
