//
//  FontResource.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//

import Foundation
import RswiftResources

#if canImport(CoreGraphics)
import CoreGraphics
#endif

extension FontResource: SupportedExtensions {
    static public let supportedExtensions: Set<String> = ["otf", "ttf"]

    #if canImport(CoreGraphics)
    static public func parse(url: URL) throws -> FontResource {
        guard let dataProvider = CGDataProvider(url: url as CFURL) else {
            throw ResourceParsingError("Unable to create data provider for font at \(url)")
        }

        let font = CGFont(dataProvider)
        guard let postScriptName = font?.postScriptName else {
            throw ResourceParsingError("No postscriptName associated to font at \(url)")
        }

        return FontResource(
            name: postScriptName as String,
            bundle: .temp,
            filename: url.lastPathComponent
        )
    }
    #else
    static public func parse(url: URL) throws -> FontResource {
        throw ResourceParsingError("Unsupported FontResource.parse")
    }
    #endif
}
