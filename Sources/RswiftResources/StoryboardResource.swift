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
    public var reusables: [Reusable]

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

extension StoryboardResource {
    public struct UnifyResult {
        public let storyboard: StoryboardResource
        public let viewControllerResults: [String: StoryboardResource.ViewController.UnifyResult]
        public let differentInitialViewController: Bool
        public let differentDeploymentTargets: Bool
        public let differentViewControllerIDs: Set<String>
        public let differentReusables: Set<Reusable>

        public func flatMap(_ transform: (StoryboardResource) -> UnifyResult) -> UnifyResult {
            let r = transform(storyboard)


            return UnifyResult(
                storyboard: r.storyboard,
                viewControllerResults: viewControllerResults.merging(r.viewControllerResults) { $0.unify($1) },
                differentInitialViewController: differentInitialViewController || r.differentInitialViewController,
                differentDeploymentTargets: differentDeploymentTargets || r.differentDeploymentTargets,
                differentViewControllerIDs: differentViewControllerIDs.union(r.differentViewControllerIDs),
                differentReusables: differentReusables.union(r.differentReusables)
            )
        }
    }

    public func unify(localizations: [StoryboardResource]) -> UnifyResult {
        var result = UnifyResult(
            storyboard: self,
            viewControllerResults: [:],
            differentInitialViewController: false,
            differentDeploymentTargets: false,
            differentViewControllerIDs: [],
            differentReusables: []
        )

        for storyboard in localizations {
            result = result.flatMap { $0.unify(storyboard) }
        }

        return result
    }

    public func unify(_ other: StoryboardResource) -> UnifyResult {
        let lhsVcs = self.viewControllersByIdentifier
        let rhsVcs = other.viewControllersByIdentifier

        let unifiedViewControllers = lhsVcs.compactMap { (id, lhs) -> StoryboardResource.ViewController.UnifyResult? in
            guard let rhs = rhsVcs[id] else { return nil }
            return lhs.unify(rhs)
        }

        let vcs = unifiedViewControllers.compactMap { ur -> StoryboardResource.ViewController? in
            if ur.differentTypes || ur.differentStoryboardIdentifiers { return nil }
            return ur.viewcontroller
        }

        var result = self
        result.viewControllers = vcs

        // Merged used images/colors from both localizations, they all need to be validated
        result.usedImageIdentifiers = Array(Set(self.usedImageIdentifiers).union(other.usedImageIdentifiers))
        result.usedColorResources = Array(Set(self.usedColorResources).union(other.usedColorResources))

        // Only keep reusables that exist in both localizations
        result.reusables = self.reusables.filter { other.reusables.contains($0) }

        // Keep other fields from self only, if they are different, that is recorded in UnifyResult

        // Remove locale, this is a merger of both
        result.locale = .none

        let allVcs = self.viewControllers + other.viewControllers
        let usedIds = Set(vcs.map(\.id))
        let skipped = allVcs.compactMap { vc -> String? in
            usedIds.contains(vc.id) ? nil : vc.storyboardIdentifier
        }

        return UnifyResult(
            storyboard: result,
            viewControllerResults: Dictionary(uniqueKeysWithValues: unifiedViewControllers.map { ($0.viewcontroller.id, $0) }),
            differentInitialViewController: initialViewControllerIdentifier != other.initialViewControllerIdentifier,
            differentDeploymentTargets: deploymentTarget != other.deploymentTarget,
            differentViewControllerIDs: Set(skipped),
            differentReusables: Set(reusables).symmetricDifference(other.reusables)
        )
    }
}

extension StoryboardResource.ViewController {
    public struct UnifyResult {
        public let viewcontroller: StoryboardResource.ViewController
        public let differentStoryboardIdentifiers: Bool
        public let differentTypes: Bool
        public let differentSegueIDs: Set<String>

        func unify(_ other: Self) -> Self {
            .init(
                viewcontroller: viewcontroller,
                differentStoryboardIdentifiers: differentStoryboardIdentifiers || other.differentStoryboardIdentifiers,
                differentTypes: differentTypes || other.differentTypes,
                differentSegueIDs: differentSegueIDs.union(other.differentSegueIDs)
            )
        }
    }

    public func unify(_ other: Self) -> UnifyResult {
        let rhsSegues = Dictionary(grouping: other.segues, by: \.identifier)

        var result = self
        result.segues = result.segues.filter { l in
            guard let ss = rhsSegues[l.identifier], let r = ss.first else { return false }
            return l.canUnify(r)
        }

        let usedIDs = Set(result.segues.map(\.identifier))
        let different = (self.segues + other.segues).filter { s in
            !usedIDs.contains(s.identifier)
        }

        return UnifyResult(
            viewcontroller: result,
            differentStoryboardIdentifiers: storyboardIdentifier != other.storyboardIdentifier,
            differentTypes: type != other.type,
            differentSegueIDs: Set(different.map(\.identifier))
        )
    }
}

private extension StoryboardResource.Segue {
    func canUnify(_ other: Self) -> Bool {
        self == other
    }
}
