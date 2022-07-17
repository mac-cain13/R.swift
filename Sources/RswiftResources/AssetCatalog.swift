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
        public let name: String
        public var subnamespaces: [Namespace] = []
        public var colors: [Color] = []
        public var images: [ImageResource] = []
        public var dataAssets: [DataAsset] = []

        public init(
            name: String,
            subnamespaces: [Namespace],
            colors: [Color],
            images: [ImageResource],
            dataAssets: [DataAsset]
        ) {
            self.name = name
            self.subnamespaces = subnamespaces
            self.colors = colors
            self.images = images
            self.dataAssets = dataAssets
        }

        public func merging(_ other: Namespace) -> Namespace {
            var new = self
            new.subnamespaces += other.subnamespaces
            new.colors += other.colors
            new.images += other.images
            new.dataAssets += other.dataAssets
            return new
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
