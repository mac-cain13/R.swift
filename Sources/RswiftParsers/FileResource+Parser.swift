//
//  ResourceFile.swift
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
    static let unsupportedExtensions: Set<String> = [
//      AssetFolder.supportedExtensions,
//      Storyboard.supportedExtensions,
//      Nib.supportedExtensions,
//      LocalizableStrings.supportedExtensions,
    ]
//    .reduce([]) { $0.union($1) }

    static public func parse(url: URL) throws -> FileResource {
        guard let basename = url.filenameWithoutExtension else {
            throw ResourceParsingError("Couldn't extract filename from URL: \(url)")
        }

        return FileResource(fullname: url.lastPathComponent, name: basename, pathExtension: url.pathExtension)
    }
}
