//
//  Generator.swift
//  
//
//  Created by Mathijs on 14/07/2021.
//

import Foundation
import SwiftSyntax

public protocol Generator {
    associatedtype ResourceType

    func generateResourceLet(resource: ResourceType) throws -> Syntax
}
