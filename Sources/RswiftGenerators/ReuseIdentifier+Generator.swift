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

        let unifiedNibs = unifyLocalizations(nibs: nibs, warning: warning)
        let unifiedStoryboards = unifyLocalizations(storyboards: storyboards, warning: warning)

        let reusables = unifiedNibs.flatMap(\.reusables) + unifiedStoryboards.flatMap(\.reusables)
        let deduplicatedReusables = Dictionary(grouping: reusables, by: \.hashValue)
            .values.compactMap(\.first)

        let groupedReusables = deduplicatedReusables.grouped(bySwiftIdentifier: \.identifier)
        groupedReusables.reportWarningsForDuplicatesAndEmpties(source: "reuseIdentifier", result: "reuse identifier", warning: warning)

        let letbindings = groupedReusables.uniques
            .map { $0.generateVarGetter() }
            .sorted { $0.name < $1.name }

        let comments = ["This `\(qualifiedName.value)` struct is generated, and contains static references to \(letbindings.count) reuse identifiers."]

        return Struct(comments: comments, name: structName) {
            letbindings
        }
    }

    private static func unifyLocalizations(nibs: [NibResource], warning: (String) -> Void) -> [NibResource] {
        var result: [NibResource] = []

        for localizations in Dictionary(grouping: nibs, by: \.name).values {
            guard let nib = localizations.first else { continue }
            let ur = nib.unify(localizations: localizations)

            let rs = ur.differentReusables.map { "'\($0.identifier)'" }.uniqueAndSorted()
            if rs.count > 0 {
                warning("Skipping generation of \(rs.count) reuseIdentifiers in nib '\(nib.name)', because \(rs.joined(separator: ", ")) don't match in all localizations")
                continue
            }
            result.append(ur.resource)
        }

        return result
    }

    private static func unifyLocalizations(storyboards: [StoryboardResource], warning: (String) -> Void) -> [StoryboardResource] {
        var result: [StoryboardResource] = []

        for localizations in Dictionary(grouping: storyboards, by: \.name).values {
            guard let storyboard = localizations.first else { continue }
            let ur = storyboard.unify(localizations: localizations)

            let rs = ur.differentReusables.map { "'\($0.identifier)'" }.uniqueAndSorted()
            if rs.count > 0 {
                warning("Skipping generation of \(rs.count) reuseIdentifiers in storyboard '\(storyboard.name)', because \(rs.joined(separator: ", ")) don't match in all localizations")
                continue
            }
            result.append(ur.storyboard)
        }

        return result
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

    func generateVarGetter() -> VarGetter {
        VarGetter(
            comments: ["Reuse identifier `\(identifier)`."],
            name: SwiftIdentifier(name: identifier),
            typeReference: genericTypeReference,
            valueCodeString: ".init(identifier: \"\(identifier)\")"
        )
    }
}
