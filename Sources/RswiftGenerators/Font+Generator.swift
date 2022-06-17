//
//  Font+Generator.swift
//  rswift
//
//  Created by Tom Lokhorst on 2021-04-18.
//

import Foundation
import RswiftResources

extension Font {
    public func generateResourceLetCodeString() -> String {
        "let \(SwiftIdentifier(name: self.name).value) = \(self)"
    }
}

