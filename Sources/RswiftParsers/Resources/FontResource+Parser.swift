//
//  FontResource.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation
import RswiftResources
import CoreGraphics

extension FontResource: SupportedExtensions {
    static public let supportedExtensions: Set<String> = ["otf", "ttf"]

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
}
