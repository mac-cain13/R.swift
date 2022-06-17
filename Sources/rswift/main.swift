//
//  main.swift
//  rswift
//
//  Created by Tom Lokhorst on 2021-04-18.
//

import Foundation
import RswiftCore

// Temporary development code
let xcodeprojURL = URL(fileURLWithPath: "/Users/tom/Projects/R.swift/Examples/ResourceApp/ResourceApp.xcodeproj")
let targetName = "ResourceApp"
let sourceRootURL = xcodeprojURL.deletingLastPathComponent()
let fakeURL = URL(fileURLWithPath: "/FAKE")

let core = RswiftCore(
    xcodeprojURL: xcodeprojURL,
    targetName: targetName,
    bundleIdentifier: "FAKE",
    productModuleName: "FAKE",
    infoPlistFile: nil,
    codeSignEntitlements: nil,
    builtProductsDirURL: fakeURL,
    developerDirURL: fakeURL,
    sourceRootURL: sourceRootURL,
    sdkRootURL: fakeURL,
    platformURL: fakeURL
)

try core.developRun()
