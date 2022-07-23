//
//  FileResource.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation
import RswiftResources

extension FileResource {
    // These are all extensions of resources that are passed to some special compiler step and not directly available at runtime
    static public let unsupportedExtensions: Set<String> = [
      AssetCatalog.supportedExtensions,
      LocalizableStrings.supportedExtensions,
      NibResource.supportedExtensions,
      StoryboardResource.supportedExtensions,
    ]
    .reduce([]) { $0.union($1) }

    static public func parse(url: URL) throws -> FileResource {
        guard let basename = url.filenameWithoutExtension else {
            throw ResourceParsingError("Couldn't extract filename from URL: \(url)")
        }

        let locale = LocaleReference(url: url)

        return FileResource(fullname: url.lastPathComponent, locale: locale, name: basename, pathExtension: url.pathExtension)
    }
}
