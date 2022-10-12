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

        let groupedStoryboards = storyboards.grouped(bySwiftIdentifier: { $0.name })
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

            generateValidate(names: structs.map(\.name))
        }
    }

    private static func generateValidate(names: [SwiftIdentifier]) -> Function {
        let lines = names
            .map { name -> String in
                "try self.\(name.value).validate()"
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

            generateValidate(viewControllers: grouped.uniques.map(\.vc))
        }
    }

    func generateValidate(viewControllers: some Collection<StoryboardResource.ViewController>) -> Function {
        let validateImagesLines = self.usedImageIdentifiers.uniqueAndSorted()
            .map { nameCatalog -> String in
                if nameCatalog.isSystemCatalog {
                    return "if #available(iOS 13.0, *) { if UIKit.UIImage(systemName: \"\(nameCatalog.name)\") == nil { throw RswiftResources.ValidationError(\"[R.swift] System image named '\(nameCatalog.name)' is used in storyboard '\(self.name)', but couldn't be loaded.\") } }"
                } else {
                    return "if UIKit.UIImage(named: \"\(nameCatalog.name)\", in: _bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError(\"[R.swift] Image named '\(nameCatalog.name)' is used in storyboard '\(self.name)', but couldn't be loaded.\") }"
                }
            }
        let validateColorLines = self.usedColorResources.uniqueAndSorted()
            .filter { !$0.isSystemCatalog }
            .map { nameCatalog in
                "if UIKit.UIColor(named: \"\(nameCatalog.name)\", in: _bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError(\"[R.swift] Color named '\(nameCatalog.name)' is used in storyboard '\(self.name)', but couldn't be loaded.\") }"
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
