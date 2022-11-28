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

  let expectedWarnings = """
    warning: [R.swift] Missing reference 'missing' in 'fault delta' 'Generic.stringsdict'
    warning: [R.swift] Can't unify 'first' in 'fault beta' 'Generic.stringsdict'
    warning: [R.swift] Can't unify 'first' in 'fault gamma' 'Generic.stringsdict'
    warning: [R.swift] Missing reference 'missing' in 'fault alpha' 'Generic.stringsdict'
    warning: [R.swift] Missing reference 'first_one' in 'fault epsilon' 'Generic.stringsdict'
    warning: [R.swift] Missing reference 'first' in 'incorrect in dutch' 'Settings.stringsdict' (nl)
    warning: [R.swift] Skipping 2 images because symbol 'second' would be generated for all of these images: Second, second
    warning: [R.swift] Skipping 2 images because symbol 'theAppIcon' would be generated for all of these images: The App Icon, TheAppIcon
    warning: [R.swift] Skipping asset namespace 'conflicting' because symbol 'conflicting' would conflict with image: conflicting
    warning: [R.swift] Skipping 2 images namespace because symbol 'second' would be generated for all of these images: Second, Second
    warning: [R.swift] Skipping 2 colors because symbol 'myRed' would be generated for all of these colors: My Red, My Red
    warning: [R.swift] Destination view controller with id Zbd-89-K73 for segue toUnknown in FirstViewController not found in storyboard References. Is this storyboard corrupt?
    warning: [R.swift] Skipping 2 segues for 'SecondViewController' because symbol 'toFirst' would be generated for all of these segues: ToFirst, toFirst
    warning: [R.swift] Skipping 2 storyboards because symbol 'duplicate' would be generated for all of these files: Duplicate, duplicate
    warning: [R.swift] Skipping 2 view controllers because symbol 'validationClash' would be generated for all of these view controller identifiers: Validation clash, ValidationClash
    warning: [R.swift] Skipping 2 xibs because symbol 'duplicate' would be generated for all of these files: Duplicate, duplicate
    warning: [R.swift] Skipping 2 reuseIdentifiers because symbol 'duplicateCellView' would be generated for all of these reuse identifiers: DuplicateCellView, duplicateCellView
    warning: [R.swift] Skipping 1 reuseIdentifier because no swift identifier can be generated for reuse identifier: ' '
    warning: [R.swift] Skipping 2 resource files because symbol 'duplicateJson' would be generated for all of these files: Duplicate.json, duplicateJson
    warning: [R.swift] Skipping 2 strings files because symbol 'duplicate' would be generated for all of these files: Duplicate, Duplicate#
    warning: [R.swift] Skipping 1 strings file because no swift identifier can be generated for file: '@@'
    warning: [R.swift] Strings file 'Localizable' (es) is missing translations for keys: 'japanese only'
    warning: [R.swift] Strings file 'Localizable' (en) is missing translations for keys: 'japanese only'
    warning: [R.swift] Strings file 'Settings' (nl) is missing translations for keys: 'Not translated', 'incorrect in dutch'
    warning: [R.swift] Skipping string FormatSpecifiers2 in 'Settings' (nl), not all format specifiers are consecutive
    warning: [R.swift] Skipping string FormatSpecifiers6 in 'Settings' (Base), not all format specifiers are consecutive
    warning: [R.swift] Skipping string FormatSpecifiers6 in 'Settings' (nl), not all format specifiers are consecutive
    warning: [R.swift] Skipping string for key FormatSpecifiers5 (Settings), format specifiers don't match for all locales: Base, nl
    warning: [R.swift] Skipping string for key mismatch (Settings), format specifiers don't match for all locales: Base, nl
    warning: [R.swift] Skipping 1 string in 'Generic' because no swift identifier can be generated for key: '#'
    warning: [R.swift] Strings file 'Settings' (nl) has extra translations (not in Base) for keys: 'Only Dutch'
    warning: [R.swift] Strings file 'Generic' has extra translations (not in English) for keys: '#'
    warning: [R.swift] Skipping 2 infos because symbol 'duplicatePlistKey' would be generated for all of these infos: DuplicatePlistKey#, DuplicatePlistKey*
    warning: [R.swift] Skipping 2 infos because symbol 'duplicatePlistValue' would be generated for all of these infos: DuplicatePlistValue, DuplicatePlistValue
    """
    .trimmingCharacters(in: .whitespacesAndNewlines)
    .components(separatedBy: "\n")

  func testWarningsAreLogged() {
    guard let logURL = Bundle(for: ResourceAppTests.self).url(forResource: "rswift", withExtension: "log") else {
      XCTFail("File rswift.log not found")
      return
    }

    do {
      let logContent = try String(contentsOf: logURL)
      let logLines = logContent
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .components(separatedBy: "\n")

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
