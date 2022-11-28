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
//    XCTAssertNotNil(R.string.localizable.japaneseOnly())
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

    /*
    // Force locales, for decimal point and decimal comma versions
    let genericEN = R.string.generic(preferredLanguages: ["en_US"]) // (bundle: .main, locale: Locale(identifier: "en_US"))
    let genericNL = R.string.generic(preferredLanguages: ["nl_NL"]) // (bundle: .main, locale: Locale(identifier: "nl_NL"))
    let genericFR = R.string.generic(preferredLanguages: ["fr_FR"]) //(bundle: .main, locale: Locale(identifier: "fr_FR"))

    XCTAssertEqual(genericEN.precision1(12345.678), "one   -    12,345.68")
    XCTAssertEqual(genericEN.precision2(12345.678), "two   -    12,345.68")
    XCTAssertEqual(genericEN.precision3(12345.678), "three -  12,345.6780")
    XCTAssertEqual(genericEN.precision4(12345.678), "four  - 12,345.68")

    XCTAssertEqual(genericNL.precision1(12345.678), "one   -    12.345,68")
    XCTAssertEqual(genericNL.precision2(12345.678), "two   -    12.345,68")
    XCTAssertEqual(genericNL.precision3(12345.678), "three -  12.345,6780")
    XCTAssertEqual(genericNL.precision4(12345.678), "four  - 12.345,68")

    XCTAssertEqual(genericFR.precision1(12345.678), "one   -    12\u{202F}345,68")
    XCTAssertEqual(genericFR.precision2(12345.678), "two   -    12\u{202F}345,68")
    XCTAssertEqual(genericFR.precision3(12345.678), "three -  12\u{202F}345,6780")
    XCTAssertEqual(genericFR.precision4(12345.678), "four  - 12\u{202F}345,68")
     */

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
  }
}
