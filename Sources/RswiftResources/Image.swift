//
//  Image.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

public struct Image {
    public let name: String
    public let onDemandResourceTags: [String]?

    public init(name: String, onDemandResourceTags: [String]?) {
        self.name = name
        self.onDemandResourceTags = onDemandResourceTags
    }
}
