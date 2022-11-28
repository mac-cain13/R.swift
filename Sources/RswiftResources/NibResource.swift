//
//  NibResource.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

public struct NibResource {
    public let name: String
    public var locale: LocaleReference
    public let deploymentTarget: DeploymentTarget?
    public let rootViews: [TypeReference]
    public var reusables: [Reusable]
    public let generatedIds: [String]
    public var usedImageIdentifiers: [NameCatalog]
    public var usedColorResources: [NameCatalog]
    public var usedAccessibilityIdentifiers: [String]

    public init(
        name: String,
        locale: LocaleReference,
        deploymentTarget: DeploymentTarget?,
        rootViews: [TypeReference],
        reusables: [Reusable],
        generatedIds: [String],
        usedImageIdentifiers: [NameCatalog],
        usedColorResources: [NameCatalog],
        usedAccessibilityIdentifiers: [String]
    ) {
        self.name = name
        self.locale = locale
        self.deploymentTarget = deploymentTarget
        self.rootViews = rootViews
        self.reusables = reusables
        self.generatedIds = generatedIds
        self.usedImageIdentifiers = usedImageIdentifiers
        self.usedColorResources = usedColorResources
        self.usedAccessibilityIdentifiers = usedAccessibilityIdentifiers
    }
}

extension NibResource {
    public struct UnifyResult {
        public let resource: NibResource
        public let differentNames: Bool
        public let differentRootViews: Bool
        public let differentReusables: Set<Reusable>
        public let differentInitialReusables: Bool
        public let differentDeploymentTargets: Bool

        public func flatMap(_ transform: (NibResource) -> UnifyResult) -> UnifyResult {
            let r = transform(resource)

            return UnifyResult(
                resource: r.resource,
                differentNames: r.differentNames || self.differentNames,
                differentRootViews: r.differentRootViews || self.differentRootViews,
                differentReusables: r.differentReusables.union(self.differentReusables),
                differentInitialReusables: r.differentInitialReusables || self.differentInitialReusables,
                differentDeploymentTargets: r.differentDeploymentTargets || self.differentDeploymentTargets
            )
        }
    }

    public func unify(localizations: [NibResource]) -> UnifyResult {
        var result = UnifyResult(
            resource: self,
            differentNames: false,
            differentRootViews: false,
            differentReusables: [],
            differentInitialReusables: false,
            differentDeploymentTargets: false
        )

        for nib in localizations {
            result = result.flatMap { $0.unify(nib) }
        }

        return result
    }

    public func unify(_ other: NibResource) -> UnifyResult {

        // Merged used images/colors from both localizations, they all need to be validated
        var result = self
        result.usedImageIdentifiers = Array(Set(self.usedImageIdentifiers).union(other.usedImageIdentifiers))
        result.usedColorResources = Array(Set(self.usedColorResources).union(other.usedColorResources))

        // Only keep reusables that exist in both localizations
        result.reusables = self.reusables.filter { other.reusables.contains($0) }

        // Keep other fields from self only, if they are different, that is recorded in UnifyResult

        // Remove locale, this is a merger of both
        result.locale = .none

        return UnifyResult(
            resource: result,
            differentNames: name != other.name,
            differentRootViews: rootViews.first != other.rootViews.first,
            differentReusables: Set(reusables).symmetricDifference(other.reusables),
            differentInitialReusables: reusables.first != other.reusables.first,
            differentDeploymentTargets: deploymentTarget != other.deploymentTarget
        )
    }
}
