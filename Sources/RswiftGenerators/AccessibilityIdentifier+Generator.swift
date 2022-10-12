//
//  AccessibilityIdentifier+Generator.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-23.
//

import Foundation
import RswiftResources

private protocol AccessibilityIdentifierContainer {
  var name: String { get }
  var usedAccessibilityIdentifiers: [String] { get }
}

extension NibResource: AccessibilityIdentifierContainer {}
extension StoryboardResource: AccessibilityIdentifierContainer {}

public struct AccessibilityIdentifier {
    public static func generateStruct(nibs: [NibResource], storyboards: [StoryboardResource], prefix: SwiftIdentifier) -> Struct {
        let structName = SwiftIdentifier(name: "id")
        let qualifiedName = prefix + structName

        let warning: (String) -> Void = { print("warning: [R.swift]", $0) }

        let containers: [AccessibilityIdentifierContainer] = nibs + storyboards
        let mergedContainers = Dictionary(grouping: containers, by: \.name)
            .mapValues { $0.flatMap(\.usedAccessibilityIdentifiers) }
            .filter { $0.value.count > 0 }

        let structs = mergedContainers
            .map { (name, ids) in
                generateStruct(
                    viewControllerName: name,
                    usedAccessibilityIdentifiers: ids,
                    prefix: qualifiedName,
                    warning: warning
                )
            }
            .sorted { $0.name < $1.name }

        let comments = ["This `\(qualifiedName.value)` struct is generated, and contains static references to \(structs.count) accessibility identifiers."]

        return Struct(comments: comments, name: structName) {
            for s in structs {
                s.generateLetBinding()
                s
            }
        }
    }

    static func generateStruct(viewControllerName: String, usedAccessibilityIdentifiers: [String], prefix: SwiftIdentifier, warning: (String) -> Void) -> Struct {
        let structName = SwiftIdentifier(name: viewControllerName)
        let qualifiedName = prefix + structName

        // Deduplicate identifiers, report warnings for empties
        let groupedIdentifiers = Array(Set(usedAccessibilityIdentifiers))
            .grouped(bySwiftIdentifier: { $0 })
        groupedIdentifiers.reportWarningsForDuplicatesAndEmpties(source: "accessibility identifier", container: "in \(viewControllerName)", result: "accessibility identifier", warning: warning)

        let letbindings = groupedIdentifiers.uniques
            .map { id in
                LetBinding(
                    comments: ["Accessibility identifier `\(id)`."],
                    name: SwiftIdentifier(name: id),
                    valueCodeString: "\"\(id)\""
                )
            }

        let comments = ["This `\(qualifiedName.value)` struct is generated, and contains static references to \(letbindings.count) accessibility identifiers."]

        return Struct(comments: comments, name: structName) {
            letbindings
        }
    }
}
