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
    XCTAssertNotNil(R.string.localizable.projectAbnormalKey1())
    XCTAssertNotNil(R.string.generic.loremipsum())
    XCTAssertNotNil(R.string.settings.copyProgress(2, 4, 50.0))
  }
}
