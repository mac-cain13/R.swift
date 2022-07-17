//
//  StoryboardResource+Generator.swift
//  
//
//  Created by Tom Lokhorst on 2022-06-24.
//

import Foundation
import RswiftResources

extension StoryboardResource {
    public func generateResourceLetCodeString() -> String {
        "static let \(SwiftIdentifier(name: self.name).value) = \(self)"
    }
}
