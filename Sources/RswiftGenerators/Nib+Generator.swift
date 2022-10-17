//
//  NibResource+Generator.swift
//  
//
//  Created by Tom Lokhorst on 2022-06-24.
//

import Foundation
import RswiftResources

extension NibResource {
    public static func generateStruct(nibs: [NibResource], prefix: SwiftIdentifier) -> Struct {
        let structName = SwiftIdentifier(name: "nib")
        let qualifiedName = prefix + structName

        let warning: (String) -> Void = { print("warning: [R.swift]", $0) }

        // Unify different localizations of nibs
        let unifiedNibs = unifyLocalizations(nibs: nibs, warning: warning)

        let groupedNibs = unifiedNibs.grouped(bySwiftIdentifier: \.name)
        groupedNibs.reportWarningsForDuplicatesAndEmpties(source: "xib", result: "file", warning: warning)

        let vargetters = groupedNibs.uniques
            .map { $0.generateVarGetter() }
            .sorted { $0.name < $1.name }

        let comments = ["This `\(qualifiedName.value)` struct is generated, and contains static references to \(vargetters.count) nibs."]

        return Struct(comments: comments, name: structName) {
            Init.bundle

            vargetters

            if groupedNibs.uniques.count > 0 {
                generateValidate(nibs: groupedNibs.uniques)
            }
        }
    }

    private static func generateValidate(nibs: some Collection<NibResource>) -> Function {
        Function(
            comments: [],
            name: .init(name: "validate"),
            params: [],
            returnThrows: true,
            returnType: .void,
            valueCodeString: nibs.flatMap { $0.generateValidateLines() }.joined(separator: "\n")
        )
    }

    private static func unifyLocalizations(nibs: [NibResource], warning: (String) -> Void) -> [NibResource] {
        var result: [NibResource] = []

        for localizations in Dictionary(grouping: nibs, by: \.name).values {
            guard let first = localizations.first else { continue }
            switch first.unify(localizations: localizations) {
            case .differentFields(let message):
                warning(message)
            case .success(let merged):
                result.append(merged)
            }
        }

        return result
    }
}

extension NibResource {
    enum UnifyResult {
        case success(NibResource)
        case differentFields(String)
    }

    private func unify(localizations: [NibResource]) -> UnifyResult {
        var result = self

        for nib in localizations {
            switch result.unify(nib) {
            case let .differentFields(fields):
                let locales = "\(result.locale.localeDescription ?? "-") and \(nib.locale.localeDescription ?? "-")"
                return .differentFields("Skipping generation of nib '\(nib.name)', because \(fields) don't match in localizations \(locales)")

            case let .success(merged):
                result = merged
            }
        }

        return .success(result)
    }

    func unify(_ other: NibResource) -> UnifyResult {
        if rootViews.first != other.rootViews.first { return .differentFields("root views") }
//        if reusables.first != other.reusables.first { return .differentFields("reuseIdentifiers") }
        if deploymentTarget != other.deploymentTarget { return .differentFields("deployment targets") }
        if name != other.name { return .differentFields("names") }

        // Merged used images/colors from both localizations, they all need to be validated
        var result = self
        result.usedImageIdentifiers = Array(Set(self.usedImageIdentifiers).union(other.usedImageIdentifiers))
        result.usedColorResources = Array(Set(self.usedColorResources).union(other.usedColorResources))

        // Remove locale, this is a merger of both
        result.locale = .none

        return .success(result)
    }

    var genericTypeReference: TypeReference {
        TypeReference(
            module: .rswiftResources,
            name: "NibReference",
            genericArgs: [rootViews.first ?? TypeReference.uiView]
        )
    }

    func generateVarGetter() -> VarGetter {
        if let reusable = reusables.first {
            let typeReference = TypeReference(
                module: .rswiftResources,
                name: "NibReferenceReuseIdentifier",
                genericArgs: [rootViews.first ?? TypeReference.uiView, reusable.type]
            )
            return VarGetter(
                comments: ["Nib `\(name)`."],
                deploymentTarget: deploymentTarget,
                name: SwiftIdentifier(name: name),
                typeReference: typeReference,
                valueCodeString: ".init(name: \"\(name.escapedStringLiteral)\", bundle: bundle, identifier: \"\(reusable.identifier.escapedStringLiteral)\")"
            )
        } else {
            let typeReference = TypeReference(
                module: .rswiftResources,
                name: "NibReference",
                genericArgs: [rootViews.first ?? TypeReference.uiView]
            )
            return VarGetter(
                comments: ["Nib `\(name)`."],
                deploymentTarget: deploymentTarget,
                name: SwiftIdentifier(name: name),
                typeReference: typeReference,
                valueCodeString: ".init(name: \"\(name.escapedStringLiteral)\", bundle: bundle)"
            )
        }
    }

    func generateValidateLines() -> [String] {
        let validateImagesLines = self.usedImageIdentifiers.uniqueAndSorted()
            .map { nameCatalog -> String in
                if nameCatalog.isSystemCatalog {
                    return "if #available(iOS 13.0, *) { if UIKit.UIImage(systemName: \"\(nameCatalog.name)\") == nil { throw RswiftResources.ValidationError(\"[R.swift] System image named '\(nameCatalog.name)' is used in nib '\(self.name)', but couldn't be loaded.\") } }"
                } else {
                    return "if UIKit.UIImage(named: \"\(nameCatalog.name)\", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError(\"[R.swift] Image named '\(nameCatalog.name)' is used in nib '\(self.name)', but couldn't be loaded.\") }"
                }
            }

        let validateColorLines = self.usedColorResources.uniqueAndSorted()
            .filter { !$0.isSystemCatalog }
            .map { nameCatalog in
                "if UIKit.UIColor(named: \"\(nameCatalog.name)\", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError(\"[R.swift] Color named '\(nameCatalog.name)' is used in nib '\(self.name)', but couldn't be loaded.\") }"
            }


        return (validateImagesLines + validateColorLines)
    }
}
