//
//  FontGenerator.swift
//  rswift
//
//  Created by Tom Lokhorst on 2021-04-18.
//

import Foundation
import RswiftResources
import SwiftFormat
import SwiftSyntax

public struct FontGenerator: Generator {
    public init() {}

    public func generateResourceLet(resource font: Font) throws -> Syntax {
        let identifier = SwiftIdentifier(name: font.name)
        let sourceFile = try SyntaxParser.parse(source: """
            static let \(identifier) = Rswift.FontResource(fontName: \"\(font.name)\")
            """)
        return Syntax(sourceFile)
    }
}
