//
//  RswiftCore.swift
//  rswift
//
//  Created by Tom Lokhorst on 2021-04-16.
//

import Foundation
import XcodeEdit

public struct RswiftCore {

    // Tempoary function for use during development
    func developGetFiles(xcodeprojURL: URL, targetName: String) throws -> [String] {
        let xcodeproj = try Xcodeproj(url: xcodeprojURL, warning: { print($0) })
        return try xcodeproj.resourcePaths(forTarget: targetName).map { "\($0)" }
    }
}
