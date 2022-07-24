//
//  FileResource+Generator.swift
//  
//
//  Created by Tom Lokhorst on 2022-06-24.
//

import Foundation
import RswiftResources

extension FileResource {
    public static func generateStruct(resources: [FileResource], prefix: SwiftIdentifier) -> Struct {
        let structName = SwiftIdentifier(name: "file")
        let qualifiedName = prefix + structName
        let warning: (String) -> Void = { print("warning:", $0) }

        // For resource files, the contents of the different locales don't matter, so we just use the first one
        let firstLocales = Dictionary(grouping: resources, by: \.fullname)
            .values.map(\.first!)
        let groupedFiles = firstLocales.grouped(bySwiftIdentifier: \.fullname)

        groupedFiles.reportWarningsForDuplicatesAndEmpties(source: "resource file", result: "file", warning: warning)

        let letbindings = groupedFiles.uniques.map { $0.generateLetBinding() }
//            .sorted { $0.name < $1.name }

        let comments = ["This `\(qualifiedName.value)` struct is generated, and contains static references to \(letbindings.count) resource files."]

        return Struct(comments: comments, name: structName) {
            letbindings
        }
    }
}

extension FileResource {
    func generateLetBinding() -> LetBinding {
        let code = "FileResource(name: \"\(name)\", filename: \"\(fullname)\")"
        return LetBinding(
            comments: ["Resource file `\(fullname)`."],
            isStatic: true,
            name: SwiftIdentifier(name: fullname),
            valueCodeString: code
        )
    }
}
