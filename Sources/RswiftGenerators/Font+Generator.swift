//
//  Font+Generator.swift
//  rswift
//
//  Created by Tom Lokhorst on 2021-04-18.
//

import Foundation
import RswiftResources
import SwiftFormat
import SwiftSyntax

extension Font {
    public func generateResourceLet() throws -> Syntax {
        let identifier = SwiftIdentifier(name: name)
        let sourceFile = try SyntaxParser.parse(source: """
            static let \(identifier) = Rswift.FontResource(fontName: \"\(name)\")
            """)
        return Syntax(sourceFile)
    }
}
