//
//  FontResource+Generator.swift
//  rswift
//
//  Created by Tom Lokhorst on 2021-04-18.
//

import Foundation
import RswiftResources

extension FontResource {
    public static func generateStruct(resources: [FontResource], prefix: SwiftIdentifier) -> Struct {
        let structName = SwiftIdentifier(name: "font")
        let qualifiedName = prefix + structName
        let warning: (String) -> Void = { print("warning:", $0) }

        let groupedResources = resources.grouped(bySwiftIdentifier: { $0.name })
        groupedResources.reportWarningsForDuplicatesAndEmpties(source: "font resource", result: "font", warning: warning)

        let letbindings = groupedResources.uniques.map { $0.generateLetBinding() }

        let comments = ["This `\(qualifiedName.value)` struct is generated, and contains static references to \(letbindings.count) fonts."]

        return Struct(comments: comments, name: structName) {
            letbindings
        }
    }
}

extension FontResource {
    func generateLetBinding() -> LetBinding {
        let code = "FontResource(name: \"\(name)\", filename: \"\(filename)\")"
        return LetBinding(
            comments: ["Font `\(name)`."],
            name: SwiftIdentifier(name: name),
            valueCodeString: code)
    }
}
