//
//  ReuseIdentifier+Generator.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-24.
//

import Foundation
import RswiftResources

extension Reusable {
    public static func generateStruct(nibs: [NibResource], storyboards: [StoryboardResource], prefix: SwiftIdentifier) -> Struct {
        let structName = SwiftIdentifier(name: "reuseIdentifier")
        let qualifiedName = prefix + structName

        let warning: (String) -> Void = { print("warning: [R.swift]", $0) }

        let reusables = nibs.flatMap(\.reusables) + storyboards.flatMap(\.reusables)
        let deduplicatedReusables = Dictionary(grouping: reusables, by: \.hashValue)
            .values.compactMap(\.first)

        let groupedReusables = deduplicatedReusables.grouped(bySwiftIdentifier: \.identifier)
        groupedReusables.reportWarningsForDuplicatesAndEmpties(source: "reuseIdentifier", result: "reuse identifier", warning: warning)

        let letbindings = groupedReusables.uniques
            .map { $0.generateLetBinding() }
            .sorted { $0.name < $1.name }

        let comments = ["This `\(qualifiedName.value)` struct is generated, and contains static references to \(letbindings.count) reuse identifiers."]

        return Struct(comments: comments, name: structName) {
            letbindings
        }
    }

}

extension Reusable {
    var genericTypeReference: TypeReference {
        TypeReference(
            module: .rswiftResources,
            name: "ReuseIdentifier",
            genericArgs: [type]
        )
    }

    func generateLetBinding() -> LetBinding {
        LetBinding(
            comments: ["Reuse identifier `\(identifier)`."],
            name: SwiftIdentifier(name: identifier),
            typeReference: genericTypeReference,
            valueCodeString: ".init(identifier: \"\(identifier)\")"
        )
    }
}
