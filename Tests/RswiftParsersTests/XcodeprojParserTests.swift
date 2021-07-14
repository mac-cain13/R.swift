//
//  File.swift
//  
//
//  Created by Mathijs on 14/07/2021.
//

import XCTest
@testable import RswiftParsers

class XcodeprojParserTests: XCTestCase {

    func testXcodeprojParser() throws {
        let xcodeprojParser = XcodeprojParser()
        let xcodeproj = try xcodeprojParser.parse(url: Bundle.module.url(forResource: "ExampleProject", withExtension: "xcodeproj", subdirectory: "Fixtures")!)

        let target = "ExampleProject"
        let testTarget = "ExampleProjectTests"
        let uiTestTarget = "ExampleProjectUITests"
        let targets = xcodeproj.targets().map { $0.name }
        XCTAssertEqual(targets, [target, testTarget, uiTestTarget])

        let configurations = try xcodeproj.buildConfigurations(forTarget: target).map { $0.name }
        XCTAssertEqual(configurations, ["Debug", "Release"])

        let paths = try xcodeproj.resourcePaths(forTarget: target)
            .map { $0.url(with: { _ in URL(fileURLWithPath: "/") }) }
            .map { $0.lastPathComponent }
        XCTAssertEqual(paths, ["Preview Assets.xcassets", "Assets.xcassets", "LaunchScreen.storyboard"])
    }

}
