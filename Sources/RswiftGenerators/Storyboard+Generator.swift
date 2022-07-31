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

        let warning: (String) -> Void = { print("warning:", $0) }

        let groupedStoryboards = storyboards.grouped(bySwiftIdentifier: { $0.name })
        groupedStoryboards.reportWarningsForDuplicatesAndEmpties(source: "storyboard", result: "storyboard", warning: warning)

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
        }
    }
}

extension StoryboardResource {

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
        let varBundle = VarGetter(
            name: bundleIdentifier,
            typeReference: TypeReference.bundle,
            valueCodeString: "_bundle")

        let identifier = SwiftIdentifier(name: name)
        let storyboardReference = TypeReference(module: .rswiftResources, rawName: "StoryboardReference")
        let initialContainer = initialViewController == nil ? nil : TypeReference(module: .rswiftResources, rawName: "InitialControllerContainer")

        return Struct(
            comments: ["Storyboard `\(name)`."],
            name: identifier,
            protocols: [storyboardReference, initialContainer].compactMap { $0 }
        ) {
            if let initialViewController = initialViewController {
                TypeAlias(name: "InitialController", value: initialViewController.type)
            }
            Init.bundle
            varBundle
            letName

            vargetters
        }
    }
}

extension StoryboardResource.ViewController {

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
