//
//  Font.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation
import RswiftResources
import CoreGraphics

public struct FontParser: ResourceParser {
    public let supportedExtensions: Set<String> = ["otf", "ttf"]

    public init() {}

    public func parse(url: URL) throws -> Font {
        try throwIfUnsupportedExtension(url)

        guard let dataProvider = CGDataProvider(url: url as CFURL) else {
            throw ResourceParsingError("Unable to create data provider for font at \(url)")
        }

        let font = CGFont(dataProvider)
        guard let postScriptName = font?.postScriptName else {
            throw ResourceParsingError("No postscriptName associated to font at \(url)")
        }

        return Font(filename: url.lastPathComponent, name: postScriptName as String)
    }
}
