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
        let warning: (String) -> Void = { print("warning: [R.swift]", $0) }

        let groupedResources = resources.grouped(bySwiftIdentifier: { $0.name })
        groupedResources.reportWarningsForDuplicatesAndEmpties(source: "font resource", result: "font", warning: warning)

        let letbindings = groupedResources.uniques.map { $0.generateLetBinding() }

        let comments = ["This `\(qualifiedName.value)` struct is generated, and contains static references to \(letbindings.count) fonts."]

        return Struct(comments: comments, name: structName, protocols: [.sequence]) {
            if letbindings.count > 0 {
                generateMakeIterator(names: letbindings.map(\.name))
                generateValidate()
            }
            letbindings
        }
    }

    private static func generateMakeIterator(names: [SwiftIdentifier]) -> Function {
        Function(
            comments: [],
            name: .init(name: "makeIterator"),
            params: [],
            returnType: .someIteratorProtocol(.fontResource),
            valueCodeString: "[\(names.map(\.value).joined(separator: ", "))].makeIterator()"
        )
    }

    private static func generateValidate() -> Function {
        Function(
            comments: [],
            name: .init(name: "validate"),
            params: [],
            returnThrows: true,
            returnType: .void,
            valueCodeString: #"""
            for font in self {
              if UIFont(resource: font, size: 42) == nil { throw RswiftResources.ValidationError("[R.swift] Font '\(font.name)' could not be loaded, is '\(font.filename)' added to the UIAppFonts array in this targets Info.plist?") }
            }
            """#
        )
    }
}

extension FontResource {
    func generateLetBinding() -> LetBinding {
        LetBinding(
            comments: ["Font `\(name)`."],
            name: SwiftIdentifier(name: name),
            valueCodeString: "FontResource(name: \"\(name)\", filename: \"\(filename)\")"
        )
    }
}
