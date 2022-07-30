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

        let warning: (String) -> Void = { print("warning:", $0) }

        let allSegues = allSegueInfos(storyboards: storyboards, warning: warning)
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

    private static func generateStruct(sourceType: TypeReference, segues: [SegueWithInfo]) -> Struct {
        let comments = ["This struct is generated for `\(sourceType.rawName)`, and contains static references to \(segues.count) segues."]
        return Struct(comments: comments, name: SwiftIdentifier(name: sourceType.rawName)) {
            segues.map { $0.generateLetBinding() }
        }
    }

    private static func viewControllers(segues: [SegueWithInfo], warning: (String) -> Void) -> [TypeReference: [SegueWithInfo]] {
        var result: [TypeReference: [SegueWithInfo]] = [:]

        let grouped = Dictionary(grouping: segues, by: \.sourceType)
        for (sourceType, seguesBySourceType) in grouped {
            let segues = seguesBySourceType.grouped(bySwiftIdentifier: { $0.segue.identifier })
            segues.reportWarningsForDuplicatesAndEmpties(source: "segue", container: "for '\(sourceType.rawName)'", result: "segue", warning: warning)

            result[sourceType] = segues.uniques
        }

        return result
    }

    private static func allSegueInfos(storyboards: [StoryboardResource], warning: (String) -> Void) -> [SegueWithInfo] {
        let allSegues = storyboards.flatMap { storyboard in
            storyboard.viewControllers.flatMap { viewController in
                viewController.segues.compactMap { segue -> SegueWithInfo? in
                    guard let destinationType = resolveDestinationType(
                        for:segue,
                        inViewController: viewController,
                        inStoryboard: storyboard,
                        allStoryboards: storyboards)
                    else
                    {
                        warning("Destination view controller with id \(segue.destination) for segue \(segue.identifier) in \(viewController.type.rawName) not found in storyboard \(storyboard.name). Is this storyboard corrupt?")
                        return nil
                    }

                    guard !segue.identifier.isEmpty else {
                      return nil
                    }

                    return SegueWithInfo(
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
    let segue: StoryboardResource.Segue
    let sourceType: TypeReference
    let destinationType: TypeReference

    var groupKey: String {
        "\(segue.identifier)|\(segue.type)|\(sourceType)|\(destinationType)"
    }

    var genericTypeReference: TypeReference {
        TypeReference(
            module: .rswiftResources,
            name: "SegueIdentifier",
            genericArgs: [segue.type, sourceType, destinationType]
        )
    }

    func generateLetBinding() -> LetBinding {
        LetBinding(
            comments: ["Segue identifier `\(segue.identifier)`."],
            name: SwiftIdentifier(name: segue.identifier),
            typeReference: genericTypeReference,
            valueCodeString: "SegueIdentifier(identifier: \"\(segue.identifier)\")"
        )
    }
}
