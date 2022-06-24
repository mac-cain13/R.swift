//
//  Storyboard+Generator.swift
//  
//
//  Created by Tom Lokhorst on 2022-06-24.
//

import Foundation
import RswiftResources

extension Storyboard {
    public func generateResourceLetCodeString() -> String {
        "let \(SwiftIdentifier(name: self.name).value) = \(self)"
    }
}
