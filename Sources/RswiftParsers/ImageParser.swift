//
//  File.swift
//  
//
//  Created by Mathijs on 14/07/2021.
//

import Foundation
import RswiftResources

public struct ImageParser: ResourceParser {
    public var supportedExtensions: Set<String> = ["launchimage", "imageset", "imagestack", "symbolset"]

    public func parse(url: URL) throws -> Image {
        try throwIfUnsupportedExtension(url)
        let name = url.deletingPathExtension().lastPathComponent
        guard !name.isEmpty else { throw ResourceInvalidNameError() }
        return Image(name: name)
    }
}
