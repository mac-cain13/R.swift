//
//  ResourceAppTests_tvOS.swift
//  ResourceAppTests-tvOS
//
//  Created by Carl Hill-Popper on 3/24/16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

@testable import ResourceApp_tvOS
import XCTest

class ResourceAppTests_tvOS: XCTestCase {

  let expectedWarnings = "warning: [R.swift] project.pbxproj is internally inconsistent.\n\n - PBXBuildFile (DEADBEEFDEADBEEFDEADBEEF) references missing fileRef C0FEFEC0FEFEC0FEFEC0FEFE\n - PBXBuildFile (DEADBEEFDEADBEEFDEADBEEF) is not used\n\nPerhaps a merge conflict?\n\n".components(separatedBy: "\n")

  func testWarningsAreLogged() {
    guard let logURL = Bundle(for: ResourceAppTests_tvOS.self).url(forResource: "rswift-tv", withExtension: "log") else {
      XCTFail("File rswift.log not found")
      return
    }

    do {
      let logContent = try String(contentsOf: logURL)
      let logLines = logContent.components(separatedBy: "\n")

      for warning in expectedWarnings {
        XCTAssertTrue(logLines.contains(warning), "Warning is not logged: '\(warning)'")
      }
      
      for logLine in logLines {
        XCTAssertTrue(expectedWarnings.contains(logLine), "Warning was not expected: '\(logLine)'")
      }

      XCTAssertEqual(logLines.count, expectedWarnings.count, "There are more/less warnings then expected")

    } catch {
      XCTFail("Failed to read rswift.log")
    }
  }
}
