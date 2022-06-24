//
//  Storyboard.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

public struct Storyboard {
    public let name: String
    private let initialViewControllerIdentifier: String?
    public let viewControllers: [ViewController]
    public let viewControllerPlaceholders: [ViewControllerPlaceholder]
    public let usedAccessibilityIdentifiers: [String]
    public let usedImageIdentifiers: [NameCatalog]
    public let usedColorResources: [NameCatalog]
    public let reusables: [Reusable]

    public var initialViewController: ViewController? {
        viewControllers
            .filter { $0.id == self.initialViewControllerIdentifier }
            .first
    }

    public init(name: String, initialViewControllerIdentifier: String?, viewControllers: [ViewController], viewControllerPlaceholders: [ViewControllerPlaceholder], usedAccessibilityIdentifiers: [String], usedImageIdentifiers: [NameCatalog], usedColorResources: [NameCatalog], reusables: [Reusable]) {
        self.name = name
        self.initialViewControllerIdentifier = initialViewControllerIdentifier
        self.viewControllers = viewControllers
        self.viewControllerPlaceholders = viewControllerPlaceholders
        self.usedAccessibilityIdentifiers = usedAccessibilityIdentifiers
        self.usedImageIdentifiers = usedImageIdentifiers
        self.usedColorResources = usedColorResources
        self.reusables = reusables
    }

    public struct ViewController {
        public let id: String
        public let storyboardIdentifier: String?
        public let type: TypeReference
        public var segues: [Segue]

        public init(id: String, storyboardIdentifier: String?, type: TypeReference, segues: [Segue]) {
            self.id = id
            self.storyboardIdentifier = storyboardIdentifier
            self.type = type
            self.segues = segues
        }
    }

    public struct ViewControllerPlaceholder {
        public let id: String
        public let storyboardName: String?
        public let referencedIdentifier: String?
        public let bundleIdentifier: String?

        public init(id: String, storyboardName: String?, referencedIdentifier: String?, bundleIdentifier: String?) {
            self.id = id
            self.storyboardName = storyboardName
            self.referencedIdentifier = referencedIdentifier
            self.bundleIdentifier = bundleIdentifier
        }
    }

    public struct Segue {
        public let identifier: String
        public let type: TypeReference
        public let destination: String
        public let kind: String

        public init(identifier: String, type: TypeReference, destination: String, kind: String) {
            self.identifier = identifier
            self.type = type
            self.destination = destination
            self.kind = kind
        }
    }
}
