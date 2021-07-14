//
//  LocalizedStringGenerator.swift
//  
//
//  Created by Mathijs on 14/07/2021.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import RswiftResources

public struct LocalizedStringGenerator: Generator {
    public init() {}

    public func generateResourceLet(resource: LocalizedStrings) throws -> Syntax {
        let sourceCode = resource.identifiers
            .reduce("") { result, identifier in
                let swiftIdentifier = SwiftIdentifier(name: identifier)
                return result + "static let \(swiftIdentifier) = Rswift.LocalizedString(name: \"\(identifier)\")\n"
            }
        let sourceFile = try SyntaxParser.parse(source: sourceCode)
        return Syntax(sourceFile)
    }
}
