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

        let letbindings = groupedNibs.uniques
            .map { $0.generateLetBinding() }
            .sorted { $0.name < $1.name }

        let comments = ["This `\(qualifiedName.value)` struct is generated, and contains static references to \(letbindings.count) nibs."]

        return Struct(comments: comments, name: structName) {
            letbindings
        }
    }

}

extension NibResource {
    var genericTypeReference: TypeReference {
        TypeReference(
            module: .rswift,
            name: "NibReference",
            genericArgs: [rootViews.first ?? TypeReference.uiView]
        )
    }

    func generateLetBinding() -> LetBinding {
        LetBinding(
            comments: ["Nib `\(name)`."],
            isStatic: true,
            name: SwiftIdentifier(name: name),
            typeReference: genericTypeReference,
            valueCodeString: "NibReference(name: \"\(name)\")"
        )
    }
}
