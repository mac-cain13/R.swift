//
//  DeploymentTarget.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-10.
//

import Foundation

public struct DeploymentTarget: Equatable {
    public typealias Version = (major: Int, minor: Int)

    public let version: Version?
    public let platform: String

    public init(version: Version?, platform: String) {
        self.version = version
        self.platform = platform
    }

    public static func ==(lhs: DeploymentTarget, rhs: DeploymentTarget) -> Bool {
        lhs.platform == rhs.platform
        && lhs.version?.major == rhs.version?.major
        && lhs.version?.minor == rhs.version?.minor
    }
}
