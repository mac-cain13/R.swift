//
//  MainTests.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 28-09-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import XCTest
@testable import RswiftCore

class MainTests: XCTestCase {

    func testGetFiles() throws {
        let xcodeprojURL = URL(fileURLWithPath: "/Users/tom/Projects/R.swift/Examples/ResourceApp/ResourceApp.xcodeproj")
        let paths = try RswiftCore().developGetFiles(xcodeprojURL: xcodeprojURL, targetName: "ResourceApp")
        XCTAssertFalse(paths.isEmpty)
    }

}
