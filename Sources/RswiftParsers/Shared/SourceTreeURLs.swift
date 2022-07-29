//
//  SourceTreeURLs.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-29.
//

import Foundation
import XcodeEdit

public struct SourceTreeURLs {
    public let builtProductsDirURL: URL
    public let developerDirURL: URL
    public let sourceRootURL: URL
    public let sdkRootURL: URL
    public let platformURL: URL

    public init(builtProductsDirURL: URL, developerDirURL: URL, sourceRootURL: URL, sdkRootURL: URL, platformURL: URL) {
        self.builtProductsDirURL = builtProductsDirURL
        self.developerDirURL = developerDirURL
        self.sourceRootURL = sourceRootURL
        self.sdkRootURL = sdkRootURL
        self.platformURL = platformURL
    }

    public func url(for sourceTreeFolder: SourceTreeFolder) -> URL {
        switch sourceTreeFolder {
        case .buildProductsDir:
            return builtProductsDirURL
        case .developerDir:
            return developerDirURL
        case .sdkRoot:
            return sdkRootURL
        case .sourceRoot:
            return sourceRootURL
        case .platformDir:
            return platformURL
        }
    }
}
