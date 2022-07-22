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
            structs
        }
    }
}

extension StoryboardResource {

    func generateStruct(prefix: SwiftIdentifier, warning: (String) -> Void) -> Struct {
        // TODO filter lets with name `identifier`

        let letIdentifier = LetBinding(
            isStatic: true,
            name: SwiftIdentifier(name: "identifier"),
            valueCodeString: "\"\(name)\"")

        let identifier = SwiftIdentifier(rawValue: name)
        let storyboardIdentifier = TypeReference(module: .host, rawName: "StoryboardIdentifier")

        return Struct(
            comments: ["Storyboard `\(name)`."],
            name: identifier,
            protocols: [storyboardIdentifier]
        ) {
            letIdentifier
        }
    }

    func generateLetBinding() -> LetBinding {
        let code = "\"\(name)\""
        return LetBinding(
            comments: ["Storyboard `\(name)`."],
            isStatic: true,
            name: SwiftIdentifier(name: name),
            valueCodeString: code)
    }
}
