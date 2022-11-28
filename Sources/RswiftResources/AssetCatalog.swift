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
        public var colors: [ColorResource] = []
        public var images: [ImageResource] = []
        public var dataAssets: [DataResource] = []

        public init() {
        }

        public init(
            subnamespaces: [String: Namespace],
            colors: [ColorResource],
            images: [ImageResource],
            dataAssets: [DataResource]
        ) {
            self.subnamespaces = subnamespaces
            self.colors = colors
            self.images = images
            self.dataAssets = dataAssets
        }

        public mutating func merge(_ other: Namespace) {
            self.subnamespaces = self.subnamespaces.merging(other.subnamespaces) { $0.merging($1) }
            self.colors += other.colors
            self.images += other.images
            self.dataAssets += other.dataAssets
        }

        public func merging(_ other: Namespace) -> Namespace {
            var new = self
            new.merge(other)
            return new
        }
    }
}
