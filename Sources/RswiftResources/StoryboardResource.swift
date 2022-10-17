//
//  StoryboardResource.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

public struct StoryboardResource {
    public let name: String
    public var locale: LocaleReference
    public let deploymentTarget: DeploymentTarget?
    public let initialViewControllerIdentifier: String?
    public var viewControllers: [ViewController]
    public let viewControllerPlaceholders: [ViewControllerPlaceholder]
    public let generatedIds: [String]
    public var usedAccessibilityIdentifiers: [String]
    public var usedImageIdentifiers: [NameCatalog]
    public var usedColorResources: [NameCatalog]
    public let reusables: [Reusable]

    public init(
        name: String,
        locale: LocaleReference,
        deploymentTarget: DeploymentTarget?,
        initialViewControllerIdentifier: String?,
        viewControllers: [ViewController],
        viewControllerPlaceholders: [ViewControllerPlaceholder],
        generatedIds: [String],
        usedAccessibilityIdentifiers: [String],
        usedImageIdentifiers: [NameCatalog],
        usedColorResources: [NameCatalog],
        reusables: [Reusable]
    ) {
        self.name = name
        self.locale = locale
        self.deploymentTarget = deploymentTarget
        self.initialViewControllerIdentifier = initialViewControllerIdentifier
        self.viewControllers = viewControllers
        self.viewControllerPlaceholders = viewControllerPlaceholders
        self.generatedIds = generatedIds
        self.usedAccessibilityIdentifiers = usedAccessibilityIdentifiers
        self.usedImageIdentifiers = usedImageIdentifiers
        self.usedColorResources = usedColorResources
        self.reusables = reusables
    }

    public struct ViewController: Equatable {
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

    public struct ViewControllerPlaceholder: Equatable {
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

    public struct Segue: Equatable {
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

    public var initialViewController: ViewController? {
        viewControllers
            .filter { $0.id == self.initialViewControllerIdentifier }
            .first
    }

    public var viewControllersByIdentifier: [String: ViewController] {
        let pairs = self.viewControllers.compactMap { vc -> (String, ViewController)? in
            guard let identifier = vc.storyboardIdentifier else { return nil }
            return (identifier, vc)
        }

        return Dictionary(uniqueKeysWithValues: pairs)
    }
}
