//
//  ColorParser.swift
//  
//
//  Created by Mathijs on 14/07/2021.
//

import Foundation
import RswiftResources

public struct ColorParser: ResourceParser {
    public var supportedExtensions: Set<String>

    public func parse(url: URL) throws -> Color {
        try throwIfUnsupportedExtension(url)
        let name = url.deletingPathExtension().lastPathComponent
        guard !name.isEmpty else { throw ResourceInvalidNameError() }
        return Color(name: name)
    }
}
