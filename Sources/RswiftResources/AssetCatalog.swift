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
        public var colors: [Color] = []
        public var images: [Image] = []
        public var dataAssets: [DataAsset] = []

        public init(
            subnamespaces: [String: Namespace],
            colors: [Color],
            images: [Image],
            dataAssets: [DataAsset]
        ) {
            self.subnamespaces = subnamespaces
            self.colors = colors
            self.images = images
            self.dataAssets = dataAssets
        }
    }

    public struct Color {
        public let name: String

        public init(name: String) {
            self.name = name
        }
    }

    public struct DataAsset {
        public let name: String
        public let onDemandResourceTags: [String]?

        public init(name: String, onDemandResourceTags: [String]?) {
            self.name = name
            self.onDemandResourceTags = onDemandResourceTags
        }
    }
}
