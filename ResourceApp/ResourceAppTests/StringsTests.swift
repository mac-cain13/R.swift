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
    XCTAssertNotNil(R.string.generic.loremipsum())
    XCTAssertNotNil(R.string.localizable.japaneseOnly())
    XCTAssertNotNil(R.string.localizable.one())
    XCTAssertNotNil(R.string.localizable.quote(4))
    XCTAssertNotNil(R.string.localizable.two())
    XCTAssertNotNil(R.string.settings.copyProgress(2, 4, 50.0))
    XCTAssertNotNil(R.string.settings.formatSpecifiers1(11, 22, "str"))
    XCTAssertNotNil(R.string.settings.formatSpecifiers3(11, 22, "str"))
    XCTAssertNotNil(R.string.settings.formatSpecifiers4(11, 22, "str"))
    XCTAssertNotNil(R.string.settings.multilineKeyWeird())
    XCTAssertNotNil(R.string.settings.notTranslated())
    XCTAssertNotNil(R.string.settings.title())
    XCTAssertNotNil(R.string.settings.scopeLuOutOfLuRuns(lu_completed_runs: 4, lu_total_runs: 2))

    XCTAssertEqual(
      R.string.settings.multilineKeyWeird(),
      NSLocalizedString("Multiline\t\\key/\n\"weird\"?!", tableName: "Settings", comment: ""))
  }
}
