//
//  ResourceAppTests.swift
//  ResourceAppTests
//
//  Created by Mathijs Kadijk on 20-07-15.
//  Copyright (c) 2015 Mathijs Kadijk. All rights reserved.
//

import UIKit
import XCTest
@testable import ResourceApp

class ResourceAppTests: XCTestCase {

  let expectedWarnings = [
    "warning: [R.swift] Locale 'en.lproj' is missing translations for keys: ['project.missingKey.3', 'project.missingKey.5', 'project.missingKey.6']",
    "warning: [R.swift] Locale 'es.lproj' is missing translations for keys: ['project.missingKey.2', 'project.missingKey.6', 'project.missingKey.7']",
    "warning: [R.swift] Locale 'ja.lproj' is missing translations for keys: ['project.missingKey.7', 'project.missingKey.8']",
    "warning: [R.swift] Locale 'en.lproj' has multiple translations for keys: ['project.duplicateKey.1', 'project.duplicateKey.2']",
    "warning: [R.swift] Locale 'es.lproj' has multiple translations for keys: ['project.duplicateKey.1', 'project.duplicateKey.2']",
    "warning: [R.swift] Locale 'ja.lproj' has multiple translations for keys: ['project.duplicateKey.1', 'project.duplicateKey.2']",
    "warning: [R.swift] Skipping 2 images because symbol 'second' would be generated for all of these images: Second, second",
    "warning: [R.swift] Skipping 2 xibs because symbol 'duplicate' would be generated for all of these xibs: Duplicate, duplicate",
    "warning: [R.swift] Skipping 2 storyboards because symbol 'duplicate' would be generated for all of these storyboards: Duplicate, duplicate",
    "warning: [R.swift] Skipping 2 reuseIdentifiers because symbol 'duplicateCellView' would be generated for all of these reuseIdentifiers: DuplicateCellView, duplicateCellView",
    "warning: [R.swift] Skipping 2 segues for 'SecondViewController' because symbol 'toFirst' would be generated for all of these segues, but with a different destination or segue type: ToFirst, toFirst",
    "warning: [R.swift] Skipping 2 images because symbol 'theAppIcon' would be generated for all of these images: The App Icon, TheAppIcon",
    "warning: [R.swift] Skipping 2 images because symbol 'second' would be generated for all of these images: Second, second",
    "warning: [R.swift] Skipping 2 resource files because symbol 'duplicateJson' would be generated for all of these files: Duplicate.json, duplicateJson",
    "warning: [R.swift] Destination view controller with id Zbd-89-K73 for segue toUnknown in FirstViewController not found in storyboard References. Is this storyboard corrupt?",
    "warning: [R.swift] Skipping 1 reuseIdentifier because no swift identifier can be generated for reuseIdentifier: ' '",
    "warning: [R.swift] Skipping 2 colors in palette 'My R.swift colors' because symbol 'black' would be generated for all of these colors: Black, Black?"
  ]

  func testWarningsAreLogged() {
    guard let logURL = NSBundle(forClass: ResourceAppTests.self).URLForResource("rswift", withExtension: "log") else {
      XCTFail("File rswift.log not found")
      return
    }

    do {
      let logContent = try String(contentsOfURL: logURL)
      let logLines = logContent.componentsSeparatedByString("\n")

      for warning in expectedWarnings {
        XCTAssertTrue(logLines.contains(warning), "Warning is not logged: '\(warning)'")
      }

      XCTAssertEqual(logLines.count, expectedWarnings.count, "There are more/less warnings then expected")
    } catch {
      XCTFail("Failed to read rswift.log")
    }
  }
}
