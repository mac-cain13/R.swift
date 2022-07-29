//
//  main.swift
//  rswift
//
//  Created by Tom Lokhorst on 2021-04-18.
//

import Foundation
import RswiftCore
import RswiftParsers
import XcodeEdit


// Temporary development code

struct EnvironmentKeys {
    static let action = "ACTION"

    static let bundleIdentifier = "PRODUCT_BUNDLE_IDENTIFIER"
    static let productModuleName = "PRODUCT_MODULE_NAME"
    static let target = "TARGET_NAME"
    static let xcodeproj = "PROJECT_FILE_PATH"
    static let infoPlistFile = "INFOPLIST_FILE"
    static let codeSignEntitlements = "CODE_SIGN_ENTITLEMENTS"

    static let builtProductsDir = SourceTreeFolder.buildProductsDir.rawValue
    static let developerDir = SourceTreeFolder.developerDir.rawValue
    static let platformDir = SourceTreeFolder.platformDir.rawValue
    static let sdkRoot = SourceTreeFolder.sdkRoot.rawValue
    static let sourceRoot = SourceTreeFolder.sourceRoot.rawValue
}

let processInfo = ProcessInfo()
let targetName = processInfo.environment[EnvironmentKeys.target] ?? "ResourceApp"

let xcodeprojURL = URL(fileURLWithPath: processInfo.environment[EnvironmentKeys.xcodeproj] ?? "/Users/tom/Projects/R.swift/Examples/ResourceApp/ResourceApp.xcodeproj")
let sourceRootURL = xcodeprojURL.deletingLastPathComponent()
let rswiftIgnoreURL = sourceRootURL.appendingPathComponent(".rswiftignore")
let fakeURL = URL(fileURLWithPath: "/FAKE")

let sourceTreeURLs = SourceTreeURLs(
    builtProductsDirURL: fakeURL,
    developerDirURL: fakeURL,
    sourceRootURL: sourceRootURL,
    sdkRootURL: fakeURL,
    platformURL: fakeURL
)

let core = RswiftCore(
    xcodeprojURL: xcodeprojURL,
    targetName: targetName,
    productModuleName: processInfo.environment[EnvironmentKeys.productModuleName],
    infoPlistFile: processInfo.environment[EnvironmentKeys.infoPlistFile].map { URL(fileURLWithPath: $0) },
    codeSignEntitlements: processInfo.environment[EnvironmentKeys.codeSignEntitlements].map { URL(fileURLWithPath: $0) },
    rswiftIgnoreURL: rswiftIgnoreURL,
    sourceTreeURLs: sourceTreeURLs
)

print("Start")
try core.developRun()
