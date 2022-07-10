//
//  DeploymentTarget.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-10.
//

import Foundation

public struct DeploymentTarget {
    public typealias Version = (major: Int, minor: Int)

    public let version: Version?
    public let platform: String

    public init(version: Version?, platform: String) {
        self.version = version
        self.platform = platform
    }
}
