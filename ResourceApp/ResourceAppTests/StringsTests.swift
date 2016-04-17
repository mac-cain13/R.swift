//
//  StringsTests.swift
//  ResourceApp
//
//  Created by Nolan Warner on 26-08-15.
//  Copyright © 2015 Nolan Warner. All rights reserved.
//

import UIKit
import XCTest
@testable import ResourceApp

class StringsTests: XCTestCase {

  func testNoNilStrings() {
    XCTAssertNotNil(R.string.projectAbnormalKey1())
    XCTAssertNotNil(R.string.projectAbnormalKey2())
    XCTAssertNotNil(R.string.projectDuplicateKey1())
    XCTAssertNotNil(R.string.projectHyphenKey1())
    XCTAssertNotNil(R.string.projectMissingKey1())
    XCTAssertNotNil(R.string.projectMissingKey2())
    XCTAssertNotNil(R.string.projectMissingKey3())
    XCTAssertNotNil(R.string.projectMissingKey4())
    XCTAssertNotNil(R.string.projectMissingKey5())
    XCTAssertNotNil(R.string.projectMissingKey6())
    XCTAssertNotNil(R.string.projectMissingKey7())
    XCTAssertNotNil(R.string.projectMissingKey8())
    XCTAssertNotNil(R.string.projectMissingKey9())
    XCTAssertNotNil(R.string.projectMixedKey_1())
    XCTAssertNotNil(R.string.projectOddSpacingKey1())
    XCTAssertNotNil(R.string.project_underscoreKey_1())
  }
}
