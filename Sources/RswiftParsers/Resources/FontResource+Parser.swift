//
// RFontResource.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//

import Foundation
import RswiftResources
import CoreGraphics

extension RFontResource: SupportedExtensions {
    static public let supportedExtensions: Set<String> = ["otf", "ttf"]

    static public func parse(url: URL) throws -> RFontResource {
        guard let dataProvider = CGDataProvider(url: url as CFURL) else {
            throw ResourceParsingError("Unable to create data provider for font at \(url)")
        }

        let font = CGFont(dataProvider)
        guard let postScriptName = font?.postScriptName else {
            throw ResourceParsingError("No postscriptName associated to font at \(url)")
        }

        return RFontResource(
            name: postScriptName as String,
            bundle: .temp,
            filename: url.lastPathComponent
        )
    }
}
