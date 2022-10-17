//
//  StoryboardResource+Generator.swift
//  
//
//  Created by Tom Lokhorst on 2022-06-24.
//

import Foundation
import RswiftResources

extension StoryboardResource {
    public static func generateStruct(storyboards: [StoryboardResource], prefix: SwiftIdentifier) -> Struct {
        let structName = SwiftIdentifier(name: "storyboard")
        let qualifiedName = prefix + structName

        let warning: (String) -> Void = { print("warning: [R.swift]", $0) }

        // Unify different localizations of storyboards
        let unifiedStoryboards = unifyLocalizations(storyboards: storyboards, warning: warning)

        let groupedStoryboards = unifiedStoryboards.grouped(bySwiftIdentifier: { $0.name })
        groupedStoryboards.reportWarningsForDuplicatesAndEmpties(source: "storyboard", result: "file", warning: warning)

        let structs = groupedStoryboards.uniques
            .map { $0.generateStruct(prefix: qualifiedName, warning: warning) }
            .sorted { $0.name < $1.name }

        let comments = ["This `\(qualifiedName.value)` struct is generated, and contains static references to \(structs.count) storyboards."]

        return Struct(comments: comments, name: structName) {
            Init.bundle

            for s in structs {
                s.generateBundleVarGetter(name: s.name.value)
                s.generateBundleFunction(name: s.name.value)
            }

            structs

            if structs.count > 0 {
                generateValidate(structs: structs)
            }
        }
    }

    private static func generateValidate(structs: [Struct]) -> Function {
        let lines = structs
            .map { s -> String in
                let code = "try self.\(s.name.value).validate()"
                return s.deploymentTarget?.codeIf(around: code) ?? code
            }
        return Function(
            comments: [],
            name: .init(name: "validate"),
            params: [],
            returnThrows: true,
            returnType: .void,
            valueCodeString: lines.joined(separator: "\n")
        )
    }

    private static func unifyLocalizations(storyboards: [StoryboardResource], warning: (String) -> Void) -> [StoryboardResource] {
        var result: [StoryboardResource] = []

        for localizations in Dictionary(grouping: storyboards, by: \.name).values {
            guard let storyboard = localizations.first else { continue }
            switch storyboard.unify(localizations: localizations) {
            case .success(let r):
                result.append(r.storyboard)

                let vcs = r.notUnifiedStoryboardIDs
                if vcs.count > 0 {
                    let ns = vcs.map { "'\($0)'" }.joined(separator: ", ")
                    warning("Skipping generation of \(vcs.count) view controllers in storyboard '\(storyboard.name)', because view controllers \(ns) don't exist in all localizations, or have different classes")
                }

            case .differentInitialViewController:
                warning("Skipping generation of storyboard '\(storyboard.name)', it has different initial view controllers in different localizations")

            case .differentDeploymentTargets:
                warning("Skipping generation of storyboard '\(storyboard.name)', it has different deployment targets in different localizations")
            }
        }

        return result
    }
}

private extension StoryboardResource {
    enum UnifyResult {
        case success(Result)
        case differentInitialViewController
        case differentDeploymentTargets

        struct Result {
            let storyboard: StoryboardResource
            let notUnifiedStoryboardIDs: [String]
        }

        func flatMap(_ transform: (StoryboardResource) -> UnifyResult) -> UnifyResult {
            switch self {
            case .success(let lhs):
                switch transform(lhs.storyboard) {
                case .success(let merged):
                    let r = Result(
                        storyboard: merged.storyboard,
                        notUnifiedStoryboardIDs: (lhs.notUnifiedStoryboardIDs + merged.notUnifiedStoryboardIDs).uniqueAndSorted()
                    )
                    return .success(r)

                case .differentInitialViewController:
                    return .differentInitialViewController

                case .differentDeploymentTargets:
                    return .differentDeploymentTargets
                }

            case .differentInitialViewController:
                return .differentInitialViewController

            case .differentDeploymentTargets:
                return .differentDeploymentTargets
            }
        }
    }

    func unify(localizations: [StoryboardResource]) -> UnifyResult {
        var result = UnifyResult.success(.init(storyboard: self, notUnifiedStoryboardIDs: []))

        for storyboard in localizations {
            result = result.flatMap { $0.unify(storyboard) }
        }

        return result
    }

    func unify(_ other: StoryboardResource) -> UnifyResult {
        let lhsVcs = self.viewControllersByIdentifier
        let rhsVcs = other.viewControllersByIdentifier

        let vcs = lhsVcs.compactMap { (id, lhs) -> ViewController? in
            guard let rhs = rhsVcs[id] else { return nil }
            return lhs.canUnify(with: rhs) ? lhs : nil
        }

        var result = self
        result.viewControllers = vcs

        // Merged used images/colors from both localizations, they all need to be validated
        result.usedImageIdentifiers = Array(Set(self.usedImageIdentifiers).union(other.usedImageIdentifiers))
        result.usedColorResources = Array(Set(self.usedColorResources).union(other.usedColorResources))

        // Remove locale, this is a merger of both
        result.locale = .none

        let allVcs = self.viewControllers + other.viewControllers
        let usedIds = Set(vcs.map(\.id))
        let skipped = allVcs.compactMap { vc -> String? in
            usedIds.contains(vc.id) ? nil : vc.storyboardIdentifier
        }

        if self.initialViewControllerIdentifier != other.initialViewControllerIdentifier {
            return .differentInitialViewController
        }

        if self.deploymentTarget != other.deploymentTarget {
            return .differentDeploymentTargets
        }

        return .success(.init(
            storyboard: result,
            notUnifiedStoryboardIDs: skipped.uniqueAndSorted()
        ))
    }

    func generateStruct(prefix: SwiftIdentifier, warning: (String) -> Void) -> Struct {
        let nameIdentifier = SwiftIdentifier(rawValue: "name")
        let bundleIdentifier = SwiftIdentifier(name: "bundle")
        let reservedIdentifiers: Set<SwiftIdentifier> = [nameIdentifier, bundleIdentifier]

        // View controllers with identifiers
        let grouped = viewControllers
          .compactMap { (vc) -> (identifier: String, vc: StoryboardResource.ViewController)? in
            guard let storyboardIdentifier = vc.storyboardIdentifier else { return nil }
            return (storyboardIdentifier, vc)
          }
          .grouped(bySwiftIdentifier: { $0.identifier })

        grouped.reportWarningsForDuplicatesAndEmpties(source: "view controller", result: "view controller identifier", warning: warning)

        // Warning about conflicts with reserved identifiers
        (grouped.uniques.map(\.identifier) + reservedIdentifiers.map(\.value))
            .grouped(bySwiftIdentifier: { $0 })
            .reportWarningsForReservedNames(source: "view controller", container: "in storyboard '\(name)'", result: "view controller", warning: warning)

        let vargetters = grouped.uniques
            .filter { !reservedIdentifiers.contains(SwiftIdentifier(rawValue: $0.identifier)) }
            .map { (id, vc) in vc.generateVarGetter(identifier: id) }
            .sorted { $0.name < $1.name }

        let letName = LetBinding(
            name: nameIdentifier,
            valueCodeString: "\"\(name)\"")

        let identifier = SwiftIdentifier(name: name)
        let storyboardReference = TypeReference(module: .rswiftResources, rawName: "StoryboardReference")
        let initialContainer = initialViewController == nil ? nil : TypeReference(module: .rswiftResources, rawName: "InitialControllerContainer")

        return Struct(
            comments: ["Storyboard `\(name)`."],
            deploymentTarget: deploymentTarget,
            name: identifier,
            protocols: [storyboardReference, initialContainer].compactMap { $0 }
        ) {
            if let initialViewController = initialViewController {
                TypeAlias(name: "InitialController", value: initialViewController.type)
            }
            Init.bundle

            letName

            vargetters

            generateValidate(viewControllers: grouped.uniques.map(\.vc))
        }
    }

    func generateValidate(viewControllers: some Collection<StoryboardResource.ViewController>) -> Function {
        let validateImagesLines = self.usedImageIdentifiers.uniqueAndSorted()
            .map { nameCatalog -> String in
                if nameCatalog.isSystemCatalog {
                    return "if #available(iOS 13.0, *) { if UIKit.UIImage(systemName: \"\(nameCatalog.name)\") == nil { throw RswiftResources.ValidationError(\"[R.swift] System image named '\(nameCatalog.name)' is used in storyboard '\(self.name)', but couldn't be loaded.\") } }"
                } else {
                    return "if UIKit.UIImage(named: \"\(nameCatalog.name)\", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError(\"[R.swift] Image named '\(nameCatalog.name)' is used in storyboard '\(self.name)', but couldn't be loaded.\") }"
                }
            }
        let validateColorLines = self.usedColorResources.uniqueAndSorted()
            .filter { !$0.isSystemCatalog }
            .map { nameCatalog in
                "if UIKit.UIColor(named: \"\(nameCatalog.name)\", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError(\"[R.swift] Color named '\(nameCatalog.name)' is used in storyboard '\(self.name)', but couldn't be loaded.\") }"
            }
        let validateViewControllersLines = viewControllers
            .compactMap { vc -> String? in
                guard let storyboardName = vc.storyboardIdentifier else { return nil }
                let storyboardIdentifier = SwiftIdentifier(name: storyboardName)
                return "if \(storyboardIdentifier.value)() == nil { throw RswiftResources.ValidationError(\"[R.swift] ViewController with identifier '\(storyboardIdentifier.value)' could not be loaded from storyboard '\(self.name)' as '\(vc.type.codeString())'.\") }"
            }

        let validateLines = validateImagesLines + validateColorLines + validateViewControllersLines

        return Function(
            comments: [],
            name: .init(name: "validate"),
            params: [],
            returnThrows: true,
            returnType: .void,
            valueCodeString: validateLines.joined(separator: "\n")
        )
    }
}

private extension StoryboardResource.ViewController {

    func canUnify(with other: Self) -> Bool {
        self.id == other.id
        && self.storyboardIdentifier == other.storyboardIdentifier
        && self.type == other.type
    }

    var genericTypeReference: TypeReference {
        TypeReference(
            module: .rswiftResources,
            name: "StoryboardViewControllerIdentifier",
            genericArgs: [self.type]
        )
    }

    func generateVarGetter(identifier: String) -> VarGetter {
        VarGetter(
            name: SwiftIdentifier(name: identifier),
            typeReference: genericTypeReference,
            valueCodeString: #"StoryboardViewControllerIdentifier(identifier: "\#(identifier.escapedStringLiteral)", storyboard: name, bundle: bundle)"#
        )
    }
}
