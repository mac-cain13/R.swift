//
//  LocalizableStrings+Generator.swift
//  
//
//  Created by Tom Lokhorst on 2022-06-24.
//

import Foundation
import RswiftResources

extension LocalizableStrings {
    public func generateResourceLetCodeString() -> String {
        "let \(SwiftIdentifier(name: self.filename).value) = \(self)"
    }
}
