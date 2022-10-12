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
        let warning: (String) -> Void = { print("warning: [R.swift]", $0) }

        // For resource files, the contents of the different locales don't matter, so we just use the first one
        let firstLocales = Dictionary(grouping: resources, by: \.filename)
            .values.map(\.first!)

        let groupedFiles = firstLocales.grouped(bySwiftIdentifier: \.filename)
        groupedFiles.reportWarningsForDuplicatesAndEmpties(source: "resource file", result: "file", warning: warning)

        let vargetters = groupedFiles.uniques.map { $0.generateVarGetter() }
//            .sorted { $0.name < $1.name }

        let comments = ["This `\(qualifiedName.value)` struct is generated, and contains static references to \(vargetters.count) resource files."]

        return Struct(comments: comments, name: structName) {
            Init.bundle
            vargetters
        }
    }
}

extension FileResource {
    func generateVarGetter() -> VarGetter {
        VarGetter(
            comments: ["Resource file `\(filename)`."],
            name: SwiftIdentifier(name: filename),
            typeReference: TypeReference(module: .rswiftResources, rawName: "FileResource"),
            valueCodeString: ".init(name: \"\(name.escapedStringLiteral)\", pathExtension: \"\(pathExtension.escapedStringLiteral)\", bundle: _bundle, locale: \(locale?.codeString() ?? "nil"))"
        )
    }
}
