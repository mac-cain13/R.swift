//
//  ImageResource.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation
import RswiftResources
import CoreGraphics


extension ImageResource: SupportedExtensions {
    // See "Supported Image Formats" on https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIImage_Class/
    static public let supportedExtensions: Set<String> = ["tiff", "tif", "jpg", "jpeg", "gif", "png", "bmp", "bmpf", "ico", "cur", "xbm"]

    static public func parse(url: URL, assetTags: [String]?) throws -> ImageResource {
        let filename = url.lastPathComponent
        let pathExtension = url.pathExtension
        guard filename.count > 0 && pathExtension.count > 0 else {
            throw ResourceParsingError("Filename and/or extension could not be parsed from URL: \(url.absoluteString)")
        }

        let locale = LocaleReference(url: url)

        let extensions = ImageResource.supportedExtensions.joined(separator: "|")
        let regex = try! NSRegularExpression(pattern: "(~(ipad|iphone))?(@[2,3]x)?\\.(\(extensions))$", options: .caseInsensitive)
        let fullFileNameRange = NSRange(location: 0, length: filename.count)
        let pathExtensionToUse = (pathExtension == "png") ? "" : ".\(pathExtension)"
        let name = regex.stringByReplacingMatches(in: filename, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: fullFileNameRange, withTemplate: pathExtensionToUse)

        return ImageResource(name: name, locale: locale, onDemandResourceTags: assetTags)
    }
}
