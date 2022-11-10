//
//  LocalizedStringAppTests.swift
//  LocalizedStringAppTests
//
//  Created by Tom Lokhorst on 2019-08-30.
//  Copyright © 2019 R.swift. All rights reserved.
//

import XCTest
@testable import LocalizedStringApp

class LocalizedStringAppTests: XCTestCase {

  func testDefault() {
    XCTAssertEqual(
      R.string.one.one1(),
      NSLocalizedString("one1", tableName: "one", comment: "")
    )
    XCTAssertEqual(
      R.string.one.one2(),
      NSLocalizedString("one2", tableName: "one", comment: "")
    )

    XCTAssertEqual(
      R.string.two.two1(),
      NSLocalizedString("two1", tableName: "two", comment: "")
    )
    XCTAssertEqual(
      R.string.two.two2("Hello"),
      String(format: NSLocalizedString("two2", tableName: "two", comment: ""), locale: Locale.current, "Hello")
    )

    XCTAssertEqual(
      R.string.three.three1(),
      NSLocalizedString("three1", tableName: "three", comment: "")
    )
    XCTAssertEqual(
      R.string.three.three2(),
      NSLocalizedString("three2", tableName: "three", comment: "")
    )
    XCTAssertEqual(
      R.string.three.three2(),
      NSLocalizedString("three2", tableName: "three", comment: "")
    )

    XCTAssertEqual(
      R.string.four.four1(),
      NSLocalizedString("four1", tableName: "four", comment: "")
    )

    XCTAssertEqual(
      R.string.five.five1(),
      NSLocalizedString("five1", tableName: "five", comment: "")
    )
    XCTAssertEqual(
      R.string.five.five2(),
      NSLocalizedString("five2", tableName: "five", comment: "")
    )
    XCTAssertEqual(
      R.string.five.five4(),
      NSLocalizedString("five4", tableName: "five", comment: "")
    )

    XCTAssertEqual(
      R.string.six.six1(),
      NSLocalizedString("six1", tableName: "six", comment: "")
    )
    XCTAssertEqual(
      R.string.six.six2(),
      NSLocalizedString("six2", tableName: "six", comment: "")
    )

    XCTAssertEqual(
      R.string.seven.seven1(),
      NSLocalizedString("seven1", tableName: "seven", comment: "")
    )
    XCTAssertEqual(
      R.string.seven.seven2(),
      NSLocalizedString("seven2", tableName: "seven", comment: "")
    )
    XCTAssertEqual(
      R.string.seven.seven3(),
      NSLocalizedString("seven3", tableName: "seven", comment: "")
    )
    XCTAssertEqual(
      R.string.seven.seven4(),
      NSLocalizedString("seven4", tableName: "seven", comment: "")
    )

    XCTAssertEqual(
      R.string.eight.eight1(),
      NSLocalizedString("eight1", tableName: "eight", comment: "")
    )
    XCTAssertEqual(
      R.string.eight.eight2(),
      NSLocalizedString("eight2", tableName: "eight", comment: "")
    )
    XCTAssertEqual(
      R.string.eight.eight3(),
      NSLocalizedString("eight3", tableName: "eight", comment: "")
    )

    XCTAssertEqual(
      R.string.nine.nine1(),
      NSLocalizedString("nine1", tableName: "nine", comment: "")
    )
    XCTAssertEqual(
      R.string.nine.nine2(),
      NSLocalizedString("nine2", tableName: "nine", comment: "")
    )
//    XCTAssertEqual(
//      R.string.nine.nine3(),
//      NSLocalizedString("nine3", tableName: "nine", comment: "")
//    )
  }


  func testTurkish() {
    let myprefs = ["tr"]

    XCTAssertEqual(R.string.one.one1(preferredLanguages: myprefs),
                   "one 1, not localized")
    XCTAssertEqual(R.string.one.one2(preferredLanguages: myprefs),
                   "one 2, not localized")
    XCTAssertEqual(R.string.two.two1(preferredLanguages: myprefs),
                   "two1")
    XCTAssertEqual(R.string.two.two2("Hello", preferredLanguages: myprefs),
                   "two2")
    XCTAssertEqual(R.string.three.three1(preferredLanguages: myprefs),
                   "three1")
    XCTAssertEqual(R.string.three.three2(preferredLanguages: myprefs),
                   "three2")
    XCTAssertEqual(R.string.three.three3(preferredLanguages: myprefs),
                   "three3")
    XCTAssertEqual(R.string.four.four1(preferredLanguages: myprefs),
                   "four1")
    XCTAssertEqual(R.string.five.five1(preferredLanguages: myprefs),
                   "five 1, localized french")
    XCTAssertEqual(R.string.five.five2(preferredLanguages: myprefs),
                   "five 2, localized french")
    XCTAssertEqual(R.string.five.five4(preferredLanguages: myprefs),
                   "five 4, localized french")
    XCTAssertEqual(R.string.six.six1(preferredLanguages: myprefs),
                   "six 1, localized french")
    XCTAssertEqual(R.string.six.six2(preferredLanguages: myprefs),
                   "six 2, localized french")
    XCTAssertEqual(R.string.seven.seven1(preferredLanguages: myprefs),
                   "seven 1, localized french")
    XCTAssertEqual(R.string.seven.seven2(preferredLanguages: myprefs),
                   "seven 2, localized french")
    XCTAssertEqual(R.string.seven.seven3(preferredLanguages: myprefs),
                   "seven 3, localized french")
    XCTAssertEqual(R.string.seven.seven4(preferredLanguages: myprefs),
                   "seven 4, localized french")
    XCTAssertEqual(R.string.eight.eight1(preferredLanguages: myprefs),
                   "eight 1, localized french")
    XCTAssertEqual(R.string.eight.eight2(preferredLanguages: myprefs),
                   "eight 2, localized french")
    XCTAssertEqual(R.string.eight.eight3(preferredLanguages: myprefs),
                   "eight 3, localized base")
    XCTAssertEqual(R.string.nine.nine1(preferredLanguages: myprefs),
                   "nine 1, localized french")
    XCTAssertEqual(R.string.nine.nine2(preferredLanguages: myprefs),
                   "nine 2, localized french")
    XCTAssertEqual(R.string.nine.nine3(preferredLanguages: myprefs),
                   "nine 3, localized base")
  }


  func testDutch() {
    let myprefs = ["nl"]

    XCTAssertEqual(R.string.one.one1(preferredLanguages: myprefs),
                   "one 1, not localized")
    XCTAssertEqual(R.string.one.one2(preferredLanguages: myprefs),
                   "one 2, not localized")
    XCTAssertEqual(R.string.two.two1(preferredLanguages: myprefs),
                   "two1")
    XCTAssertEqual(R.string.two.two2("Hello", preferredLanguages: myprefs),
                   "two2")
    XCTAssertEqual(R.string.three.three1(preferredLanguages: myprefs),
                   "three 1, localized dutch")
    XCTAssertEqual(R.string.three.three2(preferredLanguages: myprefs),
                   "three2")
    XCTAssertEqual(R.string.three.three3(preferredLanguages: myprefs),
                   "three 3, localized dutch")
    XCTAssertEqual(R.string.four.four1(preferredLanguages: myprefs),
                   "four 1, localized dutch")
    XCTAssertEqual(R.string.five.five1(preferredLanguages: myprefs),
                   "five 1, localized french")
    XCTAssertEqual(R.string.five.five2(preferredLanguages: myprefs),
                   "five 2, localized french")
    XCTAssertEqual(R.string.five.five4(preferredLanguages: myprefs),
                   "five 4, localized french")
    XCTAssertEqual(R.string.six.six1(preferredLanguages: myprefs),
                   "six 1, localized french")
    XCTAssertEqual(R.string.six.six2(preferredLanguages: myprefs),
                   "six 2, localized french")
    XCTAssertEqual(R.string.seven.seven1(preferredLanguages: myprefs),
                   "seven 1, localized dutch")
    XCTAssertEqual(R.string.seven.seven2(preferredLanguages: myprefs),
                   "seven2")
    XCTAssertEqual(R.string.seven.seven3(preferredLanguages: myprefs),
                   "seven3")
    XCTAssertEqual(R.string.seven.seven4(preferredLanguages: myprefs),
                   "seven 4, localized dutch")
    XCTAssertEqual(R.string.eight.eight1(preferredLanguages: myprefs),
                   "eight 1, localized dutch")
    XCTAssertEqual(R.string.eight.eight2(preferredLanguages: myprefs),
                   "eight 2, localized base")
    XCTAssertEqual(R.string.eight.eight3(preferredLanguages: myprefs),
                   "eight 3, localized base")
    XCTAssertEqual(R.string.nine.nine1(preferredLanguages: myprefs),
                   "nine 1, localized dutch")
    XCTAssertEqual(R.string.nine.nine2(preferredLanguages: myprefs),
                   "nine 2, localized base")
    XCTAssertEqual(R.string.nine.nine3(preferredLanguages: myprefs),
                   "nine 3, localized base")
  }


  func testEnglish() {
    let myprefs = ["en"]

    XCTAssertEqual(R.string.one.one1(preferredLanguages: myprefs),
                   "one 1, not localized")
    XCTAssertEqual(R.string.one.one2(preferredLanguages: myprefs),
                   "one 2, not localized")
    XCTAssertEqual(R.string.two.two1(preferredLanguages: myprefs),
                   "two 1, localized english")
    XCTAssertEqual(R.string.two.two2("Hello", preferredLanguages: myprefs),
                   "two 2, Hello localized english")
    XCTAssertEqual(R.string.three.three1(preferredLanguages: myprefs),
                   "three 1, localized english")
    XCTAssertEqual(R.string.three.three2(preferredLanguages: myprefs),
                   "three 2, localized english")
    XCTAssertEqual(R.string.three.three3(preferredLanguages: myprefs),
                   "three3")
    XCTAssertEqual(R.string.four.four1(preferredLanguages: myprefs),
                   "four1")
    XCTAssertEqual(R.string.five.five1(preferredLanguages: myprefs),
                   "five 1, localized english")
    XCTAssertEqual(R.string.five.five2(preferredLanguages: myprefs),
                   "five 2, localized english")
    XCTAssertEqual(R.string.five.five4(preferredLanguages: myprefs),
                   "five4")
    XCTAssertEqual(R.string.six.six1(preferredLanguages: myprefs),
                   "six 1, localized french")
    XCTAssertEqual(R.string.six.six2(preferredLanguages: myprefs),
                   "six 2, localized french")
    XCTAssertEqual(R.string.seven.seven1(preferredLanguages: myprefs),
                   "seven 1, localized english")
    XCTAssertEqual(R.string.seven.seven2(preferredLanguages: myprefs),
                   "seven 2, localized english")
    XCTAssertEqual(R.string.seven.seven3(preferredLanguages: myprefs),
                   "seven3")
    XCTAssertEqual(R.string.seven.seven4(preferredLanguages: myprefs),
                   "seven4")
    XCTAssertEqual(R.string.eight.eight1(preferredLanguages: myprefs),
                   "eight 1, localized base")
    XCTAssertEqual(R.string.eight.eight2(preferredLanguages: myprefs),
                   "eight 2, localized base")
    XCTAssertEqual(R.string.eight.eight3(preferredLanguages: myprefs),
                   "eight 3, localized base")
    XCTAssertEqual(R.string.nine.nine1(preferredLanguages: myprefs),
                   "nine 1, localized english")
    XCTAssertEqual(R.string.nine.nine2(preferredLanguages: myprefs),
                   "nine 2, localized english")
    XCTAssertEqual(R.string.nine.nine3(preferredLanguages: myprefs),
                   "nine 3, localized base")
  }


  func testEnglishGB() {
    let myprefs = ["en-GB"]

    XCTAssertEqual(R.string.one.one1(preferredLanguages: myprefs),
                   "one 1, not localized")
    XCTAssertEqual(R.string.one.one2(preferredLanguages: myprefs),
                   "one 2, not localized")
    XCTAssertEqual(R.string.two.two1(preferredLanguages: myprefs),
                   "two 1, localized english")
    XCTAssertEqual(R.string.two.two2("Hello", preferredLanguages: myprefs),
                   "two 2, Hello localized english")
    XCTAssertEqual(R.string.three.three1(preferredLanguages: myprefs),
                   "three 1, localized english")
    XCTAssertEqual(R.string.three.three2(preferredLanguages: myprefs),
                   "three 2, localized english")
    XCTAssertEqual(R.string.three.three3(preferredLanguages: myprefs),
                   "three3")
    XCTAssertEqual(R.string.four.four1(preferredLanguages: myprefs),
                   "four1")
    XCTAssertEqual(R.string.five.five1(preferredLanguages: myprefs),
                   "five 1, localized english gb")
    XCTAssertEqual(R.string.five.five2(preferredLanguages: myprefs),
                   "five2")
    XCTAssertEqual(R.string.five.five4(preferredLanguages: myprefs),
                   "five4")
    XCTAssertEqual(R.string.six.six1(preferredLanguages: myprefs),
                   "six 1, localized french")
    XCTAssertEqual(R.string.six.six2(preferredLanguages: myprefs),
                   "six 2, localized french")
    XCTAssertEqual(R.string.seven.seven1(preferredLanguages: myprefs),
                   "seven 1, localized english")
    XCTAssertEqual(R.string.seven.seven2(preferredLanguages: myprefs),
                   "seven 2, localized english")
    XCTAssertEqual(R.string.seven.seven3(preferredLanguages: myprefs),
                   "seven3")
    XCTAssertEqual(R.string.seven.seven4(preferredLanguages: myprefs),
                   "seven4")
    XCTAssertEqual(R.string.eight.eight1(preferredLanguages: myprefs),
                   "eight 1, localized base")
    XCTAssertEqual(R.string.eight.eight2(preferredLanguages: myprefs),
                   "eight 2, localized base")
    XCTAssertEqual(R.string.eight.eight3(preferredLanguages: myprefs),
                   "eight 3, localized base")
    XCTAssertEqual(R.string.nine.nine1(preferredLanguages: myprefs),
                   "nine 1, localized base")
    XCTAssertEqual(R.string.nine.nine2(preferredLanguages: myprefs),
                   "nine 2, localized base")
    XCTAssertEqual(R.string.nine.nine3(preferredLanguages: myprefs),
                   "nine 3, localized base")
  }


  func testFrench() {
    let myprefs = ["fr"]

    XCTAssertEqual(R.string.one.one1(preferredLanguages: myprefs),
                   "one 1, not localized")
    XCTAssertEqual(R.string.one.one2(preferredLanguages: myprefs),
                   "one 2, not localized")
    XCTAssertEqual(R.string.two.two1(preferredLanguages: myprefs),
                   "two1")
    XCTAssertEqual(R.string.two.two2("Hello", preferredLanguages: myprefs),
                   "two2")
    XCTAssertEqual(R.string.three.three1(preferredLanguages: myprefs),
                   "three1")
    XCTAssertEqual(R.string.three.three2(preferredLanguages: myprefs),
                   "three2")
    XCTAssertEqual(R.string.three.three3(preferredLanguages: myprefs),
                   "three3")
    XCTAssertEqual(R.string.four.four1(preferredLanguages: myprefs),
                   "four1")
    XCTAssertEqual(R.string.five.five1(preferredLanguages: myprefs),
                   "five 1, localized french")
    XCTAssertEqual(R.string.five.five2(preferredLanguages: myprefs),
                   "five 2, localized french")
    XCTAssertEqual(R.string.five.five4(preferredLanguages: myprefs),
                   "five 4, localized french")
    XCTAssertEqual(R.string.six.six1(preferredLanguages: myprefs),
                   "six 1, localized french")
    XCTAssertEqual(R.string.six.six2(preferredLanguages: myprefs),
                   "six 2, localized french")
    XCTAssertEqual(R.string.seven.seven1(preferredLanguages: myprefs),
                   "seven 1, localized french")
    XCTAssertEqual(R.string.seven.seven2(preferredLanguages: myprefs),
                   "seven 2, localized french")
    XCTAssertEqual(R.string.seven.seven3(preferredLanguages: myprefs),
                   "seven 3, localized french")
    XCTAssertEqual(R.string.seven.seven4(preferredLanguages: myprefs),
                   "seven 4, localized french")
    XCTAssertEqual(R.string.eight.eight1(preferredLanguages: myprefs),
                   "eight 1, localized french")
    XCTAssertEqual(R.string.eight.eight2(preferredLanguages: myprefs),
                   "eight 2, localized french")
    XCTAssertEqual(R.string.eight.eight3(preferredLanguages: myprefs),
                   "eight 3, localized base")
    XCTAssertEqual(R.string.nine.nine1(preferredLanguages: myprefs),
                   "nine 1, localized french")
    XCTAssertEqual(R.string.nine.nine2(preferredLanguages: myprefs),
                   "nine 2, localized french")
    XCTAssertEqual(R.string.nine.nine3(preferredLanguages: myprefs),
                   "nine 3, localized base")
  }


  func testFrenchCanada() {
    let myprefs = ["fr-CA"]

    XCTAssertEqual(R.string.one.one1(preferredLanguages: myprefs),
                   "one 1, not localized")
    XCTAssertEqual(R.string.one.one2(preferredLanguages: myprefs),
                   "one 2, not localized")
    XCTAssertEqual(R.string.two.two1(preferredLanguages: myprefs),
                   "two1")
    XCTAssertEqual(R.string.two.two2("Hello", preferredLanguages: myprefs),
                   "two2")
    XCTAssertEqual(R.string.three.three1(preferredLanguages: myprefs),
                   "three1")
    XCTAssertEqual(R.string.three.three2(preferredLanguages: myprefs),
                   "three2")
    XCTAssertEqual(R.string.three.three3(preferredLanguages: myprefs),
                   "three3")
    XCTAssertEqual(R.string.four.four1(preferredLanguages: myprefs),
                   "four1")
    XCTAssertEqual(R.string.five.five1(preferredLanguages: myprefs),
                   "five 1, localized french canada")
    XCTAssertEqual(R.string.five.five2(preferredLanguages: myprefs),
                   "five2")
    XCTAssertEqual(R.string.five.five4(preferredLanguages: myprefs),
                   "five4")
    XCTAssertEqual(R.string.six.six1(preferredLanguages: myprefs),
                   "six 1, localized french canada")
    XCTAssertEqual(R.string.six.six2(preferredLanguages: myprefs),
                   "six2")
    XCTAssertEqual(R.string.seven.seven1(preferredLanguages: myprefs),
                   "seven 1, localized french")
    XCTAssertEqual(R.string.seven.seven2(preferredLanguages: myprefs),
                   "seven 2, localized french")
    XCTAssertEqual(R.string.seven.seven3(preferredLanguages: myprefs),
                   "seven 3, localized french")
    XCTAssertEqual(R.string.seven.seven4(preferredLanguages: myprefs),
                   "seven 4, localized french")
    XCTAssertEqual(R.string.eight.eight1(preferredLanguages: myprefs),
                   "eight 1, localized base")
    XCTAssertEqual(R.string.eight.eight2(preferredLanguages: myprefs),
                   "eight 2, localized base")
    XCTAssertEqual(R.string.eight.eight3(preferredLanguages: myprefs),
                   "eight 3, localized base")
    XCTAssertEqual(R.string.nine.nine1(preferredLanguages: myprefs),
                   "nine 1, localized base")
    XCTAssertEqual(R.string.nine.nine2(preferredLanguages: myprefs),
                   "nine 2, localized base")
    XCTAssertEqual(R.string.nine.nine3(preferredLanguages: myprefs),
                   "nine 3, localized base")
  }

}
