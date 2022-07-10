//
//  Nib.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

public struct Nib {
    public let name: String
    public let deploymentTarget: DeploymentTarget?
    public let rootViews: [TypeReference]
    public let reusables: [Reusable]
    public let usedImageIdentifiers: [NameCatalog]
    public let usedColorResources: [NameCatalog]
    public let usedAccessibilityIdentifiers: [String]

    public init(
        name: String,
        deploymentTarget: DeploymentTarget?,
        rootViews: [TypeReference],
        reusables: [Reusable],
        usedImageIdentifiers: [NameCatalog],
        usedColorResources: [NameCatalog],
        usedAccessibilityIdentifiers: [String]
    ) {
        self.name = name
        self.deploymentTarget = deploymentTarget
        self.rootViews = rootViews
        self.reusables = reusables
        self.usedImageIdentifiers = usedImageIdentifiers
        self.usedColorResources = usedColorResources
        self.usedAccessibilityIdentifiers = usedAccessibilityIdentifiers
    }
}

public struct DeploymentTarget {
    public typealias Version = (major: Int, minor: Int)

    public let version: Version?
    public let platform: String

    public init(version: Version?, platform: String) {
        self.version = version
        self.platform = platform
    }
}
