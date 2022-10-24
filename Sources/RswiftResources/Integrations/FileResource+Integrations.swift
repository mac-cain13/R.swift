//
//  Bundle+FileResource.swift
//  R.swift.Library
//
//  Created by Mathijs Kadijk on 10-01-16.
//  From: https://github.com/mac-cain13/R.swift.Library
//  License: MIT License
//

import Foundation

extension FileResource {
    /**
     Returns the file URL for the given resource (`R.file.*`).

     - returns: The file URL for the resource file (`R.file.*`) or nil if the file could not be located.
     */
    public func url() -> URL? {
        bundle.url(forResource: name, withExtension: pathExtension)
    }

    /**
     Returns the file URL for the given resource (`R.file.*`).

     - returns: The file URL for the resource file (`R.file.*`) or nil if the file could not be located.
     */
    @available(*, renamed: "url()")
    public func callAsFunction() -> URL? {
        url()
    }
}

extension Bundle {
    /**
     Returns the file URL for the given resource (`R.file.*`).

     - parameter resource: The resource to get the file URL for (`R.file.*`).

     - returns: The file URL for the resource file (`R.file.*`) or nil if the file could not be located.
     */
    public func url(forResource resource: FileResource) -> URL? {
        url(forResource: resource.name, withExtension: resource.pathExtension)
    }

    /**
     Returns the full pathname for the resource (`R.file.*`).

     - parameter resource: The resource file to get the path for (`R.file.*`).

     - returns: The full pathname for the resource file (`R.file.*`) or nil if the file could not be located.
     */
    public func path(forResource resource: FileResource) -> String? {
        path(forResource: resource.name, ofType: resource.pathExtension)
    }
}
