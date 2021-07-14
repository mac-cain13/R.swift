//
//  ImageGenerator.swift
//  
//
//  Created by Mathijs on 14/07/2021.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import RswiftResources

public struct ImageGenerator: Generator {
    public init() {}

    public func generateResourceLet(resource: AssetFolder) throws -> Syntax {
        let sourceFile = SourceFile {
          Import("Rswift")

          Struct("ExampleStruct") {
            Let("syntax", of: "Syntax")
          }
        }

        let format = Format(indentWidth: 4)
        let syntax = sourceFile.buildSyntax(format: format, leadingTrivia: .zero)
        return syntax
    }
}
