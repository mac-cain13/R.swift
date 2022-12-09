//
//  PropertyListResource.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2018-07-08.
//

import Foundation

public struct PropertyListResource {
    public typealias Contents = [String: Any]

    public let buildConfigurationName: String
    public let contents: Contents
    public let url: URL

    public init(buildConfigurationName: String, contents: Contents, url: URL) {
        self.buildConfigurationName = buildConfigurationName
        self.contents = contents
        self.url = url
    }
}
