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

        let warning: (String) -> Void = { print("warning:", $0) }

        // TODO: Generate warnings for mismatched identifier/root view in different locales
//        let firstLocales = Dictionary(grouping: nibs, by: \.name)
//            .values.map(\.first!)
        let groupedNibs = nibs.grouped(bySwiftIdentifier: \.name)
        groupedNibs.reportWarningsForDuplicatesAndEmpties(source: "nib", result: "nib", warning: warning)

        let vargetters = groupedNibs.uniques
            .map { $0.generateVarGetter() }
            .sorted { $0.name < $1.name }

        let comments = ["This `\(qualifiedName.value)` struct is generated, and contains static references to \(vargetters.count) nibs."]

        return Struct(comments: comments, name: structName) {
            Init.bundle

            vargetters
        }
    }

}

extension NibResource {
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
                name: SwiftIdentifier(name: name),
                typeReference: typeReference,
                valueCodeString: ".init(name: \"\(name.escapedStringLiteral)\", bundle: _bundle, identifier: \"\(reusable.identifier.escapedStringLiteral)\")"
            )
        } else {
            let typeReference = TypeReference(
                module: .rswiftResources,
                name: "NibReference",
                genericArgs: [rootViews.first ?? TypeReference.uiView]
            )
            return VarGetter(
                comments: ["Nib `\(name)`."],
                name: SwiftIdentifier(name: name),
                typeReference: typeReference,
                valueCodeString: ".init(name: \"\(name.escapedStringLiteral)\", bundle: _bundle)"
            )
        }
    }
}
