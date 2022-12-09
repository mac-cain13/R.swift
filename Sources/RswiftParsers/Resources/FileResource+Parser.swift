//
//  FileResource.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//

import Foundation
import RswiftResources

extension FileResource {
    // These are all extensions of resources that are passed to some special compiler step and not directly available at runtime
    static public let unsupportedExtensions: Set<String> = [
        AssetCatalog.supportedExtensions,
        StringsTable.supportedExtensions,
        NibResource.supportedExtensions,
        StoryboardResource.supportedExtensions,
    ]
    .reduce([]) { $0.union($1) }

    static public func parse(url: URL) throws -> FileResource {
        guard let basename = url.filenameWithoutExtension else {
            throw ResourceParsingError("Couldn't extract filename from URL: \(url)")
        }

        let locale = LocaleReference(url: url)

        return FileResource(
            name: basename,
            pathExtension: url.pathExtension,
            bundle: .temp,
            locale: locale
        )
    }
}
