//
//  Segue+Generator.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-22.
//

import Foundation
import RswiftResources

public struct Segue {
    public static func generateStruct(storyboards: [StoryboardResource], prefix: SwiftIdentifier) -> Struct {
        let structName = SwiftIdentifier(name: "segue")
        let qualifiedName = prefix + structName

        let warning: (String) -> Void = { print("warning: [R.swift]", $0) }

        // Unify different localizations of storyboards
        let unifiedStoryboards = unifyLocalizations(storyboards: storyboards, warning: warning)

        let allSegues = allSegueInfos(storyboards: unifiedStoryboards, warning: warning)
        let viewControllers = viewControllers(segues: allSegues, warning: warning)
        let structs = viewControllers
            .map { generateStruct(sourceType: $0.key, segues: $0.value) }
            .sorted { $0.name < $1.name }

        let comments = ["This `\(qualifiedName.value)` struct is generated, and contains static references to \(structs.count) view controllers."]

        return Struct(comments: comments, name: structName) {
            for s in structs {
                s.generateLetBinding()
            }

            structs
        }
    }

    private static func viewControllers(segues: [SegueWithInfo], warning: (String) -> Void) -> [TypeReference: [SegueWithInfo]] {
        var result: [TypeReference: [SegueWithInfo]] = [:]

        let grouped = Dictionary(grouping: segues, by: \.sourceType)
        for (sourceType, seguesBySourceType) in grouped {
            let segues = seguesBySourceType.grouped(bySwiftIdentifier: { $0.segue.identifier })
            segues.reportWarningsForDuplicatesAndEmpties(source: "segue", container: "for '\(sourceType.name)'", result: "segue", warning: warning)

            result[sourceType] = segues.uniques
        }

        return result
    }

    private static func generateStruct(sourceType: TypeReference, segues: [SegueWithInfo]) -> Struct {
        let comments = ["This struct is generated for `\(sourceType.name)`, and contains static references to \(segues.count) segues."]
        return Struct(comments: comments, name: SwiftIdentifier(name: sourceType.name)) {
            segues.map { $0.generateVarGetter() }
        }
    }

    private static func allSegueInfos(storyboards: [StoryboardResource], warning: (String) -> Void) -> [SegueWithInfo] {
        let allSegues = storyboards.flatMap { storyboard in
            storyboard.viewControllers.flatMap { viewController in
                viewController.segues.compactMap { segue -> SegueWithInfo? in
                    guard let destinationType = resolveDestinationType(
                        for: segue,
                        inViewController: viewController,
                        inStoryboard: storyboard,
                        allStoryboards: storyboards)
                    else
                    {
                        warning("Destination view controller with id \(segue.destination) for segue \(segue.identifier) in \(viewController.type.codeString()) not found in storyboard \(storyboard.name). Is this storyboard corrupt?")
                        return nil
                    }

                    guard !segue.identifier.isEmpty else {
                      return nil
                    }

                    return SegueWithInfo(
                        deploymentTarget: storyboard.deploymentTarget,
                        segue: segue,
                        sourceType: viewController.type,
                        destinationType: destinationType
                    )
                }
            }
        }

        // Deduplicate segues that are identical
        let deduplicatedSeguesWithInfo = Dictionary(grouping: allSegues, by: \.groupKey)
          .values
          .compactMap { $0.first }

        return deduplicatedSeguesWithInfo
    }

    private static func resolveDestinationType(for segue: StoryboardResource.Segue, inViewController: StoryboardResource.ViewController, inStoryboard storyboard: StoryboardResource, allStoryboards storyboards: [StoryboardResource]) -> TypeReference? {
        let uiViewController = TypeReference.uiViewController

        if segue.kind == "unwind" {
            return uiViewController
        }

        let destinationViewControllerType = storyboard.viewControllers
            .filter { $0.id == segue.destination }
            .first?
            .type

        let destinationViewControllerPlaceholderType = storyboard.viewControllerPlaceholders
            .filter { $0.id == segue.destination }
            .first
            .flatMap { storyboard -> TypeReference? in
                switch storyboard.resolveWithStoryboards(storyboards) {
                case .customBundle:
                    return uiViewController // Not supported, fallback to UIViewController
                case let .resolved(vc):
                    return vc?.type
                }
            }

        return destinationViewControllerType ?? destinationViewControllerPlaceholderType
    }

    private static func unifyLocalizations(storyboards: [StoryboardResource], warning: (String) -> Void) -> [StoryboardResource] {
        var result: [StoryboardResource] = []

        for localizations in Dictionary(grouping: storyboards, by: \.name).values {
            guard let storyboard = localizations.first else { continue }
            let ur = storyboard.unify(localizations: localizations)

            for vur in ur.viewControllerResults.values {
                if vur.differentSegueIDs.isEmpty { continue }

                let segues = vur.differentSegueIDs.sorted()
                let ns = segues.map { "'\($0)'" }.joined(separator: ", ")
                warning("Skipping generation of \(segues.count) segues in view controller '\(vur.viewcontroller.storyboardIdentifier ?? vur.viewcontroller.id)' in storyboard '\(storyboard.name)', because segues \(ns) aren't identical in all localizations")
            }

            result.append(ur.storyboard)
        }

        return result
    }
}


private extension StoryboardResource.ViewControllerPlaceholder {
    enum ResolvedResult {
        case customBundle
        case resolved(StoryboardResource.ViewController?)
    }

    func resolveWithStoryboards(_ storyboards: [StoryboardResource]) -> ResolvedResult {
        if nil != bundleIdentifier {
            // Can't resolve storyboard in other bundles
            return .customBundle
        }

        guard let storyboardName = storyboardName else {
            // Storyboard reference without a storyboard defined?!
            return .resolved(nil)
        }

        let storyboard = storyboards
            .filter { $0.name == storyboardName }

        guard let referencedIdentifier = referencedIdentifier else {
            return .resolved(storyboard.first?.initialViewController)
        }

        return .resolved(storyboard
            .flatMap {
                $0.viewControllers.filter { $0.storyboardIdentifier == referencedIdentifier }
            }
            .first
        )
    }
}

struct SegueWithInfo {
    let deploymentTarget: DeploymentTarget?
    let segue: StoryboardResource.Segue
    let sourceType: TypeReference
    let destinationType: TypeReference

    var groupKey: String {
        "\(String(describing: deploymentTarget))|\(segue.identifier)|\(segue.type)|\(sourceType)|\(destinationType)"
    }

    var genericTypeReference: TypeReference {
        TypeReference(
            module: .rswiftResources,
            name: "SegueIdentifier",
            genericArgs: [segue.type, sourceType, destinationType]
        )
    }

    func generateVarGetter() -> VarGetter {
        VarGetter(
            comments: ["Segue identifier `\(segue.identifier)`."],
            deploymentTarget: deploymentTarget,
            name: SwiftIdentifier(name: segue.identifier),
            typeReference: genericTypeReference,
            valueCodeString: ".init(identifier: \"\(segue.identifier)\")"
        )
    }
}
