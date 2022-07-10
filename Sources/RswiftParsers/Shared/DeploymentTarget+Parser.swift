//
//  DeploymentTarget+Parser.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-10.
//

import RswiftResources

func parseDeploymentTargetVersion(_ str: String) -> DeploymentTarget.Version? {
    guard str.count > 2 else { return nil }
    guard let i = Int(str) else { return nil }
    let s = String(i, radix: 16)
    guard
        let major = Int(s[..<s.index(s.endIndex, offsetBy: -2)]),
        let minor = Int(s[s.index(s.endIndex, offsetBy: -2)..<s.index(s.endIndex, offsetBy: -1)])
    else {
        return nil
    }

    return (major, minor)
}
