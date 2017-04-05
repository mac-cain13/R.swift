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
  }

  func testCorrectValues() {
    XCTAssertEqual(
      R.string.settings.multilineKeyWeird(),
      NSLocalizedString("Multiline\t\\key/\n\"weird\"?!", tableName: "Settings", comment: ""))

    XCTAssertEqual(
      R.string.generic.correctAlpha(first: 1),
      "Pre Alpha (| One Alpha |)")

    XCTAssertEqual(
      R.string.generic.correctBeta(first: 1, second: 2),
      "Pre Beta (| One Beta.first x Other Beta.second: 2 |)")

    XCTAssertEqual(
      R.string.generic.correctGamma(first: 1, second: 2),
      "Pre Gamma (| Other Gamma.second: 2 x One Gamma.first |)")

    XCTAssertEqual(
      R.string.generic.correctDelta(first: 1, second: 2),
      "Pre Delta (| One Delta.first (1). Second: Other Delta.second: 2 |)")

    XCTAssertEqual(
      R.string.generic.correctEpsilon(first: 1, second: 2),
      "Pre Epsilon (| Other Epsilon.first: 1. Second: Other Epsilon.second: 2 |)")

    XCTAssertEqual(
      R.string.generic.correctEta("ONE", second: 2, 3),
      "Pre Eta (| ONE - Other Eta.second: 2. - 3|)")

    XCTAssertEqual(
      R.string.generic.correctTheta(first: 1, second: 2, third: 3),
      "Pre Theta (| One Theta.first |)")

    XCTAssertEqual(
      R.string.generic.correctZeta("ONE", second: 2),
      "Pre Zeta (| ONE Other Zeta.second: 2. |)")
    
    XCTAssertNil(R.string.comments.starKey1.comment)
    
    XCTAssertEqual(
      R.string.comments.starKey2.comment,
      "comment belongs to key2")
    
    XCTAssertEqual(
      R.string.comments.starKey3.comment,
      "comment belongs to key3")
    
    XCTAssertNil(R.string.comments.starKey4.comment)
    
    XCTAssertEqual(
      R.string.comments.starKey5.comment,
      "first part of comment for key5\nsecond part of comment, should be merged")
    
    XCTAssertEqual(
      R.string.comments.starKey6.comment,
      "big, multiline comment\nbelonging to key6")

    XCTAssertNil(R.string.comments.starKey7.comment)

    XCTAssertNil(R.string.comments.starKey8.comment)
    
    XCTAssertNil(R.string.comments.slashKey1.comment)
    
    XCTAssertEqual(
      R.string.comments.slashKey2.comment,
      "comment belongs to key2")
    
    XCTAssertEqual(
      R.string.comments.slashKey3.comment,
      "comment belongs to key3")
    
    XCTAssertNil(R.string.comments.slashKey4.comment)
    
    XCTAssertEqual(
      R.string.comments.slashKey5.comment,
      "first part of comment for key5\nsecond part of comment, should be merged")
    
    XCTAssertEqual(
      R.string.comments.slashKey6.comment,
      "big, multiline comment\nbelonging to key6")

    XCTAssertNil(R.string.comments.slashKey7.comment)

    XCTAssertNil(R.string.comments.slashKey8.comment)
  }
}
