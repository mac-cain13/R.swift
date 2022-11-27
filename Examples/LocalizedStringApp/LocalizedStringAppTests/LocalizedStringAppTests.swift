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

    /* one */
    XCTAssertEqual(
      R.string.one.one1(),
      NSLocalizedString("one1", tableName: "one", comment: "")
    )
    XCTAssertEqual(
      R.string.one.one2(),
      NSLocalizedString("one2", tableName: "one", comment: "")
    )
    XCTAssertEqual(
      R.string.one.oneArg("ARG"),
      String(format: NSLocalizedString("oneArg", tableName: "one", comment: ""), "ARG")
    )

    /* two */
    XCTAssertEqual(
      R.string.two.two1(),
      NSLocalizedString("two1", tableName: "two", comment: "")
    )
    XCTAssertEqual(
      R.string.two.two2("Hello"),
      String(format: NSLocalizedString("two2", tableName: "two", comment: ""), locale: Locale.current, "Hello")
    )

    /* three */
    XCTAssertEqual(
      R.string.three.three1(),
      NSLocalizedString("three1", tableName: "three", comment: "")
    )
    XCTAssertEqual(
      R.string.three.three2(),
      NSLocalizedString("three2", tableName: "three", comment: "")
    )
    XCTAssertEqual(
      R.string.three.three3(),
      NSLocalizedString("three3", tableName: "three", comment: "")
    )
    XCTAssertEqual(
      R.string.three.threeArg1("ARG"),
      String(format: NSLocalizedString("threeArg1", tableName: "three", comment: ""), "ARG")
    )
    XCTAssertEqual(
      R.string.three.threeArg2("ARG"),
      String(format: NSLocalizedString("threeArg2", tableName: "three", comment: ""), "ARG")
    )
    XCTAssertEqual(
      R.string.three.threeArg3("ARG"),
      String(format: NSLocalizedString("threeArg3", tableName: "three", comment: ""), "ARG")
    )

    /* four */
    XCTAssertEqual(
      R.string.four.four1(),
      NSLocalizedString("four1", tableName: "four", comment: "")
    )
    XCTAssertEqual(
      R.string.four.fourArg("ARG"),
      String(format: NSLocalizedString("fourArg", tableName: "four", comment: ""), "ARG")
    )

    /* five */
    XCTAssertEqual(
      R.string.five.five1(),
      NSLocalizedString("five1", tableName: "five", comment: "")
    )
    XCTAssertEqual(
      R.string.five.five2(),
      NSLocalizedString("five2", tableName: "five", value: "five 2, localized french", comment: "")
    )
    XCTAssertEqual(
      R.string.five.five4(),
      NSLocalizedString("five4", tableName: "five", value: "five 4, localized french", comment: "")
    )
    XCTAssertEqual(
      R.string.five.fiveArg1("ARG"),
      String(format: NSLocalizedString("fiveArg1", tableName: "five", comment: ""), "ARG")
    )
    XCTAssertEqual(
      R.string.five.fiveArg2("ARG"),
      String(format: NSLocalizedString("fiveArg2", tableName: "five", value: "five 2 %@, localized french", comment: ""), "ARG")
    )
    XCTAssertEqual(
      R.string.five.fiveArg4("ARG"),
      String(format: NSLocalizedString("fiveArg4", tableName: "five", value: "five 4 %@, localized french", comment: ""), "ARG")
    )

    /* six */
    XCTAssertEqual(
      R.string.six.six1(),
      NSLocalizedString("six1", tableName: "six", comment: "")
    )
    XCTAssertEqual(
      R.string.six.six2(),
      NSLocalizedString("six2", tableName: "six", value: "six 2, localized french", comment: "")
    )
    XCTAssertEqual(
      R.string.six.sixArg1("ARG"),
      String(format: NSLocalizedString("sixArg1", tableName: "six", comment: ""), "ARG")
    )
    XCTAssertEqual(
      R.string.six.sixArg2("ARG"),
      String(format: NSLocalizedString("sixArg2", tableName: "six", value: "six 2 %@, localized french", comment: ""), "ARG")
    )

    /* seven */
    XCTAssertEqual(
      R.string.seven.seven1(),
      NSLocalizedString("seven1", tableName: "seven", comment: "")
    )
    XCTAssertEqual(
      R.string.seven.seven2(),
      NSLocalizedString("seven2", tableName: "seven", value: "seven 2, localized french", comment: "")
    )
    XCTAssertEqual(
      R.string.seven.seven3(),
      NSLocalizedString("seven3", tableName: "seven", value: "seven 3, localized french", comment: "")
    )
    XCTAssertEqual(
      R.string.seven.seven4(),
      NSLocalizedString("seven4", tableName: "seven", value: "seven 4, localized french", comment: "")
    )
    XCTAssertEqual(
      R.string.seven.sevenArg1("ARG"),
      String(format: NSLocalizedString("sevenArg1", tableName: "seven", comment: ""), "ARG")
    )
    XCTAssertEqual(
      R.string.seven.sevenArg2("ARG"),
      String(format: NSLocalizedString("sevenArg2", tableName: "seven", value: "seven 2 %@, localized french", comment: ""), "ARG")
    )
    XCTAssertEqual(
      R.string.seven.sevenArg3("ARG"),
      String(format: NSLocalizedString("sevenArg3", tableName: "seven", value: "seven 3 %@, localized french", comment: ""), "ARG")
    )
    XCTAssertEqual(
      R.string.seven.sevenArg4("ARG"),
      String(format: NSLocalizedString("sevenArg4", tableName: "seven", value: "seven 4 %@, localized french", comment: ""), "ARG")
    )

    /* eight */
    XCTAssertEqual(
      R.string.eight.eight1(),
      NSLocalizedString("eight1", tableName: "eight", comment: "")
    )
    XCTAssertEqual(
      R.string.eight.eight2(),
      NSLocalizedString("eight2", tableName: "eight", value: "eight 2, localized french", comment: "")
    )
    XCTAssertEqual(
      R.string.eight.eight3(),
      NSLocalizedString("eight3", tableName: "eight", comment: "")
    )
    XCTAssertEqual(
      R.string.eight.eightArg1("ARG"),
      String(format: NSLocalizedString("eightArg1", tableName: "eight", comment: ""), "ARG")
    )
    XCTAssertEqual(
      R.string.eight.eightArg2("ARG"),
      String(format: NSLocalizedString("eightArg2", tableName: "eight", value: "eight 2 %@, localized french", comment: ""), "ARG")
    )
    XCTAssertEqual(
      R.string.eight.eightArg3("ARG"),
      String(format: NSLocalizedString("eightArg3", tableName: "eight", comment: ""), "ARG")
    )

    /* nine */
    XCTAssertEqual(
      R.string.nine.nine1(),
      NSLocalizedString("nine1", tableName: "nine", comment: "")
    )
    XCTAssertEqual(
      R.string.nine.nine2(),
      NSLocalizedString("nine2", tableName: "nine", value: "nine 2, localized french", comment: "")
    )
    XCTAssertEqual(
      R.string.nine.nine3(),
      NSLocalizedString("nine3", tableName: "nine", comment: "")
    )
    XCTAssertEqual(
      R.string.nine.nineArg1("ARG"),
      String(format: NSLocalizedString("nineArg1", tableName: "nine", comment: ""), "ARG")
    )
    XCTAssertEqual(
      R.string.nine.nineArg2("ARG"),
      String(format: NSLocalizedString("nineArg2", tableName: "nine", value: "nine 2 %@, localized french", comment: ""), "ARG")
    )
    XCTAssertEqual(
      R.string.nine.nineArg3("ARG"),
      String(format: NSLocalizedString("nineArg3", tableName: "nine", comment: ""), "ARG")
    )

    /* ten */
    XCTAssertEqual(
      R.string.ten.ten1(things: 1),
      String(format: NSLocalizedString("ten1", tableName: "ten", comment: ""), 1)
    )
  }


  func testTurkish() {
    let myprefs = ["tr"]

    testPrefferedLanguages(myprefs: myprefs)

    /* one */
    XCTAssertEqual(R.string.one.one1(preferredLanguages: myprefs),
                   "one 1, not localized")
    XCTAssertEqual(R.string.one.one2(preferredLanguages: myprefs),
                   "one 2, not localized")
    XCTAssertEqual(R.string.one.oneArg("ARG", preferredLanguages: myprefs),
                   "one ARG, not localized")

    /* two */
    XCTAssertEqual(R.string.two.two1(preferredLanguages: myprefs),
                   "two1")
    XCTAssertEqual(R.string.two.two2("Hello", preferredLanguages: myprefs),
                   "two2")

    /* three */
    XCTAssertEqual(R.string.three.three1(preferredLanguages: myprefs),
                   "three1")
    XCTAssertEqual(R.string.three.three2(preferredLanguages: myprefs),
                   "three2")
    XCTAssertEqual(R.string.three.three3(preferredLanguages: myprefs),
                   "three3")
    XCTAssertEqual(R.string.three.threeArg1("ARG", preferredLanguages: myprefs),
                   "threeArg1")
    XCTAssertEqual(R.string.three.threeArg2("ARG", preferredLanguages: myprefs),
                   "threeArg2")
    XCTAssertEqual(R.string.three.threeArg3("ARG", preferredLanguages: myprefs),
                   "threeArg3")

    /* four */
    XCTAssertEqual(R.string.four.four1(preferredLanguages: myprefs),
                   "four1")
    XCTAssertEqual(R.string.four.fourArg("ARG", preferredLanguages: myprefs),
                   "fourArg")

    /* five */
    XCTAssertEqual(R.string.five.five1(preferredLanguages: myprefs),
                   "five 1, localized french")
    XCTAssertEqual(R.string.five.five2(preferredLanguages: myprefs),
                   "five 2, localized french")
    XCTAssertEqual(R.string.five.five4(preferredLanguages: myprefs),
                   "five 4, localized french")
    XCTAssertEqual(R.string.five.fiveArg1("ARG", preferredLanguages: myprefs),
                   "five 1 ARG, localized french")
    XCTAssertEqual(R.string.five.fiveArg2("ARG", preferredLanguages: myprefs),
                   "five 2 ARG, localized french")
    XCTAssertEqual(R.string.five.fiveArg4("ARG", preferredLanguages: myprefs),
                   "five 4 ARG, localized french")

    /* six */
    XCTAssertEqual(R.string.six.six1(preferredLanguages: myprefs),
                   "six 1, localized french")
    XCTAssertEqual(R.string.six.six2(preferredLanguages: myprefs),
                   "six 2, localized french")
    XCTAssertEqual(R.string.six.sixArg1("ARG", preferredLanguages: myprefs),
                   "six 1 ARG, localized french")
    XCTAssertEqual(R.string.six.sixArg2("ARG", preferredLanguages: myprefs),
                   "six 2 ARG, localized french")

    /* seven */
    XCTAssertEqual(R.string.seven.seven1(preferredLanguages: myprefs),
                   "seven 1, localized french")
    XCTAssertEqual(R.string.seven.seven2(preferredLanguages: myprefs),
                   "seven 2, localized french")
    XCTAssertEqual(R.string.seven.seven3(preferredLanguages: myprefs),
                   "seven 3, localized french")
    XCTAssertEqual(R.string.seven.seven4(preferredLanguages: myprefs),
                   "seven 4, localized french")
    XCTAssertEqual(R.string.seven.sevenArg1("ARG", preferredLanguages: myprefs),
                   "seven 1 ARG, localized french")
    XCTAssertEqual(R.string.seven.sevenArg2("ARG", preferredLanguages: myprefs),
                   "seven 2 ARG, localized french")
    XCTAssertEqual(R.string.seven.sevenArg3("ARG", preferredLanguages: myprefs),
                   "seven 3 ARG, localized french")
    XCTAssertEqual(R.string.seven.sevenArg4("ARG", preferredLanguages: myprefs),
                   "seven 4 ARG, localized french")

    /* eight */
    XCTAssertEqual(R.string.eight.eight1(preferredLanguages: myprefs),
                   "eight 1, localized french")
    XCTAssertEqual(R.string.eight.eight2(preferredLanguages: myprefs),
                   "eight 2, localized french")
    XCTAssertEqual(R.string.eight.eight3(preferredLanguages: myprefs),
                   "eight3")
    XCTAssertEqual(R.string.eight.eightArg1("ARG", preferredLanguages: myprefs),
                   "eight 1 ARG, localized french")
    XCTAssertEqual(R.string.eight.eightArg2("ARG", preferredLanguages: myprefs),
                   "eight 2 ARG, localized french")
    XCTAssertEqual(R.string.eight.eightArg3("ARG", preferredLanguages: myprefs),
                   "eightArg3")

    /* nine */
    XCTAssertEqual(R.string.nine.nine1(preferredLanguages: myprefs),
                   "nine 1, localized french")
    XCTAssertEqual(R.string.nine.nine2(preferredLanguages: myprefs),
                   "nine 2, localized french")
    XCTAssertEqual(R.string.nine.nine3(preferredLanguages: myprefs),
                   "nine3")
    XCTAssertEqual(R.string.nine.nineArg1("ARG", preferredLanguages: myprefs),
                   "nine 1 ARG, localized french")
    XCTAssertEqual(R.string.nine.nineArg2("ARG", preferredLanguages: myprefs),
                   "nine 2 ARG, localized french")
    XCTAssertEqual(R.string.nine.nineArg3("ARG", preferredLanguages: myprefs),
                   "nineArg3")

    /* ten */
    XCTAssertEqual(R.string.ten.ten1(things: 1, preferredLanguages: myprefs),
                   "ten 1 - 1 thing, localized french")
  }

  func testDutch() {
    let myprefs = ["nl"]

    testPrefferedLanguages(myprefs: myprefs)

    /* one */
    XCTAssertEqual(R.string.one.one1(preferredLanguages: myprefs),
                   "one 1, not localized")
    XCTAssertEqual(R.string.one.one2(preferredLanguages: myprefs),
                   "one 2, not localized")
    XCTAssertEqual(R.string.one.oneArg("ARG", preferredLanguages: myprefs),
                   "one ARG, not localized")

    /* two */
    XCTAssertEqual(R.string.two.two1(preferredLanguages: myprefs),
                   "two1")
    XCTAssertEqual(R.string.two.two2("Hello", preferredLanguages: myprefs),
                   "two2")

    /* three */
    XCTAssertEqual(R.string.three.three1(preferredLanguages: myprefs),
                   "three 1, localized dutch")
    XCTAssertEqual(R.string.three.three2(preferredLanguages: myprefs),
                   "three2")
    XCTAssertEqual(R.string.three.three3(preferredLanguages: myprefs),
                   "three 3, localized dutch")
    XCTAssertEqual(R.string.three.threeArg1("ARG", preferredLanguages: myprefs),
                   "three 1 ARG, localized dutch")
    XCTAssertEqual(R.string.three.threeArg2("ARG", preferredLanguages: myprefs),
                   "threeArg2")
    XCTAssertEqual(R.string.three.threeArg3("ARG", preferredLanguages: myprefs),
                   "three 3 ARG, localized dutch")

    /* four */
    XCTAssertEqual(R.string.four.four1(preferredLanguages: myprefs),
                   "four 1, localized dutch")
    XCTAssertEqual(R.string.four.fourArg("ARG", preferredLanguages: myprefs),
                   "four ARG, localized dutch")

    /* five */
    XCTAssertEqual(R.string.five.five1(preferredLanguages: myprefs),
                   "five 1, localized french")
    XCTAssertEqual(R.string.five.five2(preferredLanguages: myprefs),
                   "five 2, localized french")
    XCTAssertEqual(R.string.five.five4(preferredLanguages: myprefs),
                   "five 4, localized french")
    XCTAssertEqual(R.string.five.fiveArg1("ARG", preferredLanguages: myprefs),
                   "five 1 ARG, localized french")
    XCTAssertEqual(R.string.five.fiveArg2("ARG", preferredLanguages: myprefs),
                   "five 2 ARG, localized french")
    XCTAssertEqual(R.string.five.fiveArg4("ARG", preferredLanguages: myprefs),
                   "five 4 ARG, localized french")

    /* six */
    XCTAssertEqual(R.string.six.six1(preferredLanguages: myprefs),
                   "six 1, localized french")
    XCTAssertEqual(R.string.six.six2(preferredLanguages: myprefs),
                   "six 2, localized french")
    XCTAssertEqual(R.string.six.sixArg1("ARG", preferredLanguages: myprefs),
                   "six 1 ARG, localized french")
    XCTAssertEqual(R.string.six.sixArg2("ARG", preferredLanguages: myprefs),
                   "six 2 ARG, localized french")

    /* seven */
    XCTAssertEqual(R.string.seven.seven1(preferredLanguages: myprefs),
                   "seven 1, localized dutch")
    XCTAssertEqual(R.string.seven.seven2(preferredLanguages: myprefs),
                   "seven2")
    XCTAssertEqual(R.string.seven.seven3(preferredLanguages: myprefs),
                   "seven3")
    XCTAssertEqual(R.string.seven.seven4(preferredLanguages: myprefs),
                   "seven 4, localized dutch")
    XCTAssertEqual(R.string.seven.sevenArg1("ARG", preferredLanguages: myprefs),
                   "seven 1 ARG, localized dutch")
    XCTAssertEqual(R.string.seven.sevenArg2("ARG", preferredLanguages: myprefs),
                   "sevenArg2")
    XCTAssertEqual(R.string.seven.sevenArg3("ARG", preferredLanguages: myprefs),
                   "sevenArg3")
    XCTAssertEqual(R.string.seven.sevenArg4("ARG", preferredLanguages: myprefs),
                   "seven 4 ARG, localized dutch")

    /* eight */
    XCTAssertEqual(R.string.eight.eight1(preferredLanguages: myprefs),
                   "eight 1, localized dutch")
    XCTAssertEqual(R.string.eight.eight2(preferredLanguages: myprefs),
                   "eight2")
    XCTAssertEqual(R.string.eight.eight3(preferredLanguages: myprefs),
                   "eight3")
    XCTAssertEqual(R.string.eight.eightArg1("ARG", preferredLanguages: myprefs),
                   "eight 1 ARG, localized dutch")
    XCTAssertEqual(R.string.eight.eightArg2("ARG", preferredLanguages: myprefs),
                   "eightArg2")
    XCTAssertEqual(R.string.eight.eightArg3("ARG", preferredLanguages: myprefs),
                   "eightArg3")

    /* nine */
    XCTAssertEqual(R.string.nine.nine1(preferredLanguages: myprefs),
                   "nine 1, localized dutch")
    XCTAssertEqual(R.string.nine.nine2(preferredLanguages: myprefs),
                   "nine2")
    XCTAssertEqual(R.string.nine.nine3(preferredLanguages: myprefs),
                   "nine3")
    XCTAssertEqual(R.string.nine.nineArg1("ARG", preferredLanguages: myprefs),
                   "nine 1 ARG, localized dutch")
    XCTAssertEqual(R.string.nine.nineArg2("ARG", preferredLanguages: myprefs),
                   "nineArg2")
    XCTAssertEqual(R.string.nine.nineArg3("ARG", preferredLanguages: myprefs),
                   "nineArg3")

    /* ten */
    XCTAssertEqual(R.string.ten.ten1(things: 1, preferredLanguages: myprefs),
                   "ten 1 - 1 thing, localized dutch")
  }

  func testEnglish() {
    let myprefs = ["en"]

    testPrefferedLanguages(myprefs: myprefs)

    /* one */
    XCTAssertEqual(R.string.one.one1(preferredLanguages: myprefs),
                   "one 1, not localized")
    XCTAssertEqual(R.string.one.one2(preferredLanguages: myprefs),
                   "one 2, not localized")
    XCTAssertEqual(R.string.one.oneArg("ARG", preferredLanguages: myprefs),
                   "one ARG, not localized")

    /* two */
    XCTAssertEqual(R.string.two.two1(preferredLanguages: myprefs),
                   "two 1, localized english")
    XCTAssertEqual(R.string.two.two2("Hello", preferredLanguages: myprefs),
                   "two 2, Hello localized english")

    /* three */
    XCTAssertEqual(R.string.three.three1(preferredLanguages: myprefs),
                   "three 1, localized english")
    XCTAssertEqual(R.string.three.three2(preferredLanguages: myprefs),
                   "three 2, localized english")
    XCTAssertEqual(R.string.three.three3(preferredLanguages: myprefs),
                   "three3")
    XCTAssertEqual(R.string.three.threeArg1("ARG", preferredLanguages: myprefs),
                   "three 1 ARG, localized english")
    XCTAssertEqual(R.string.three.threeArg2("ARG", preferredLanguages: myprefs),
                   "three 2 ARG, localized english")
    XCTAssertEqual(R.string.three.threeArg3("ARG", preferredLanguages: myprefs),
                   "threeArg3")

    /* four */
    XCTAssertEqual(R.string.four.four1(preferredLanguages: myprefs),
                   "four1")
    XCTAssertEqual(R.string.four.fourArg("ARG", preferredLanguages: myprefs),
                   "fourArg")

    /* five */
    XCTAssertEqual(R.string.five.five1(preferredLanguages: myprefs),
                   "five 1, localized english")
    XCTAssertEqual(R.string.five.five2(preferredLanguages: myprefs),
                   "five 2, localized english")
    XCTAssertEqual(R.string.five.five4(preferredLanguages: myprefs),
                   "five4")
    XCTAssertEqual(R.string.five.fiveArg1("ARG", preferredLanguages: myprefs),
                   "five 1 ARG, localized english")
    XCTAssertEqual(R.string.five.fiveArg2("ARG", preferredLanguages: myprefs),
                   "five 2 ARG, localized english")
    XCTAssertEqual(R.string.five.fiveArg4("ARG", preferredLanguages: myprefs),
                   "fiveArg4")

    /* six */
    XCTAssertEqual(R.string.six.six1(preferredLanguages: myprefs),
                   "six 1, localized french")
    XCTAssertEqual(R.string.six.six2(preferredLanguages: myprefs),
                   "six 2, localized french")
    XCTAssertEqual(R.string.six.sixArg1("ARG", preferredLanguages: myprefs),
                   "six 1 ARG, localized french")
    XCTAssertEqual(R.string.six.sixArg2("ARG", preferredLanguages: myprefs),
                   "six 2 ARG, localized french")

    /* seven */
    XCTAssertEqual(R.string.seven.seven1(preferredLanguages: myprefs),
                   "seven 1, localized english")
    XCTAssertEqual(R.string.seven.seven2(preferredLanguages: myprefs),
                   "seven 2, localized english")
    XCTAssertEqual(R.string.seven.seven3(preferredLanguages: myprefs),
                   "seven3")
    XCTAssertEqual(R.string.seven.seven4(preferredLanguages: myprefs),
                   "seven4")
    XCTAssertEqual(R.string.seven.sevenArg1("ARG", preferredLanguages: myprefs),
                   "seven 1 ARG, localized english")
    XCTAssertEqual(R.string.seven.sevenArg2("ARG", preferredLanguages: myprefs),
                   "seven 2 ARG, localized english")
    XCTAssertEqual(R.string.seven.sevenArg3("ARG", preferredLanguages: myprefs),
                   "sevenArg3")
    XCTAssertEqual(R.string.seven.sevenArg4("ARG", preferredLanguages: myprefs),
                   "sevenArg4")

    /* eight */
    XCTAssertEqual(R.string.eight.eight1(preferredLanguages: myprefs),
                   "eight 1, localized base")
    XCTAssertEqual(R.string.eight.eight2(preferredLanguages: myprefs),
                   "eight 2, localized base")
    XCTAssertEqual(R.string.eight.eight3(preferredLanguages: myprefs),
                   "eight 3, localized base")
    XCTAssertEqual(R.string.eight.eightArg1("ARG", preferredLanguages: myprefs),
                   "eight 1 ARG, localized base")
    XCTAssertEqual(R.string.eight.eightArg2("ARG", preferredLanguages: myprefs),
                   "eight 2 ARG, localized base")
    XCTAssertEqual(R.string.eight.eightArg3("ARG", preferredLanguages: myprefs),
                   "eight 3 ARG, localized base")

    /* nine */
    XCTAssertEqual(R.string.nine.nine1(preferredLanguages: myprefs),
                   "nine 1, localized english")
    XCTAssertEqual(R.string.nine.nine2(preferredLanguages: myprefs),
                   "nine 2, localized english")
    XCTAssertEqual(R.string.nine.nine3(preferredLanguages: myprefs),
                   "nine3")
    XCTAssertEqual(R.string.nine.nineArg1("ARG", preferredLanguages: myprefs),
                   "nine 1 ARG, localized english")
    XCTAssertEqual(R.string.nine.nineArg2("ARG", preferredLanguages: myprefs),
                   "nine 2 ARG, localized english")
    XCTAssertEqual(R.string.nine.nineArg3("ARG", preferredLanguages: myprefs),
                   "nineArg3")

    /* ten */
    XCTAssertEqual(R.string.ten.ten1(things: 1, preferredLanguages: myprefs),
                   "ten 1 - 1 thing, localized french")
  }


  func testEnglishGB() {
    let myprefs = ["en-GB"]

    testPrefferedLanguages(myprefs: myprefs)

    /* one */
    XCTAssertEqual(R.string.one.one1(preferredLanguages: myprefs),
                   "one 1, not localized")
    XCTAssertEqual(R.string.one.one2(preferredLanguages: myprefs),
                   "one 2, not localized")
    XCTAssertEqual(R.string.one.oneArg("ARG", preferredLanguages: myprefs),
                   "one ARG, not localized")

    /* two */
    XCTAssertEqual(R.string.two.two1(preferredLanguages: myprefs),
                   "two 1, localized english")
    XCTAssertEqual(R.string.two.two2("Hello", preferredLanguages: myprefs),
                   "two 2, Hello localized english")

    /* three */
    XCTAssertEqual(R.string.three.three1(preferredLanguages: myprefs),
                   "three 1, localized english")
    XCTAssertEqual(R.string.three.three2(preferredLanguages: myprefs),
                   "three 2, localized english")
    XCTAssertEqual(R.string.three.three3(preferredLanguages: myprefs),
                   "three3")
    XCTAssertEqual(R.string.three.threeArg1("ARG", preferredLanguages: myprefs),
                   "three 1 ARG, localized english")
    XCTAssertEqual(R.string.three.threeArg2("ARG", preferredLanguages: myprefs),
                   "three 2 ARG, localized english")
    XCTAssertEqual(R.string.three.threeArg3("ARG", preferredLanguages: myprefs),
                   "threeArg3")

    /* four */
    XCTAssertEqual(R.string.four.four1(preferredLanguages: myprefs),
                   "four1")
    XCTAssertEqual(R.string.four.fourArg("ARG", preferredLanguages: myprefs),
                   "fourArg")

    /* five */
    XCTAssertEqual(R.string.five.five1(preferredLanguages: myprefs),
                   "five 1, localized english gb")
    XCTAssertEqual(R.string.five.five2(preferredLanguages: myprefs),
                   "five2")
    XCTAssertEqual(R.string.five.five4(preferredLanguages: myprefs),
                   "five4")
    XCTAssertEqual(R.string.five.fiveArg1("ARG", preferredLanguages: myprefs),
                   "five 1 ARG, localized english gb")
    XCTAssertEqual(R.string.five.fiveArg2("ARG", preferredLanguages: myprefs),
                   "fiveArg2")
    XCTAssertEqual(R.string.five.fiveArg4("ARG", preferredLanguages: myprefs),
                   "fiveArg4")

    /* six */
    XCTAssertEqual(R.string.six.six1(preferredLanguages: myprefs),
                   "six 1, localized french")
    XCTAssertEqual(R.string.six.six2(preferredLanguages: myprefs),
                   "six 2, localized french")
    XCTAssertEqual(R.string.six.sixArg1("ARG", preferredLanguages: myprefs),
                   "six 1 ARG, localized french")
    XCTAssertEqual(R.string.six.sixArg2("ARG", preferredLanguages: myprefs),
                   "six 2 ARG, localized french")

    /* seven */
    XCTAssertEqual(R.string.seven.seven1(preferredLanguages: myprefs),
                   "seven 1, localized english")
    XCTAssertEqual(R.string.seven.seven2(preferredLanguages: myprefs),
                   "seven 2, localized english")
    XCTAssertEqual(R.string.seven.seven3(preferredLanguages: myprefs),
                   "seven3")
    XCTAssertEqual(R.string.seven.seven4(preferredLanguages: myprefs),
                   "seven4")
    XCTAssertEqual(R.string.seven.sevenArg1("ARG", preferredLanguages: myprefs),
                   "seven 1 ARG, localized english")
    XCTAssertEqual(R.string.seven.sevenArg2("ARG", preferredLanguages: myprefs),
                   "seven 2 ARG, localized english")
    XCTAssertEqual(R.string.seven.sevenArg3("ARG", preferredLanguages: myprefs),
                   "sevenArg3")
    XCTAssertEqual(R.string.seven.sevenArg4("ARG", preferredLanguages: myprefs),
                   "sevenArg4")

    /* eight */
    XCTAssertEqual(R.string.eight.eight1(preferredLanguages: myprefs),
                   "eight 1, localized base")
    XCTAssertEqual(R.string.eight.eight2(preferredLanguages: myprefs),
                   "eight 2, localized base")
    XCTAssertEqual(R.string.eight.eight3(preferredLanguages: myprefs),
                   "eight 3, localized base")
    XCTAssertEqual(R.string.eight.eightArg1("ARG", preferredLanguages: myprefs),
                   "eight 1 ARG, localized base")
    XCTAssertEqual(R.string.eight.eightArg2("ARG", preferredLanguages: myprefs),
                   "eight 2 ARG, localized base")
    XCTAssertEqual(R.string.eight.eightArg3("ARG", preferredLanguages: myprefs),
                   "eight 3 ARG, localized base")

    /* nine */
    XCTAssertEqual(R.string.nine.nine1(preferredLanguages: myprefs),
                   "nine 1, localized base")
    XCTAssertEqual(R.string.nine.nine2(preferredLanguages: myprefs),
                   "nine 2, localized base")
    XCTAssertEqual(R.string.nine.nine3(preferredLanguages: myprefs),
                   "nine 3, localized base")
    XCTAssertEqual(R.string.nine.nineArg1("ARG", preferredLanguages: myprefs),
                   "nine 1 ARG, localized base")
    XCTAssertEqual(R.string.nine.nineArg2("ARG", preferredLanguages: myprefs),
                   "nine 2 ARG, localized base")
    XCTAssertEqual(R.string.nine.nineArg3("ARG", preferredLanguages: myprefs),
                   "nine 3 ARG, localized base")

    /* ten */
    XCTAssertEqual(R.string.ten.ten1(things: 1, preferredLanguages: myprefs),
                   "ten 1 - 1 thing, localized french")
  }


  func testFrench() {
    let myprefs = ["fr"]

    testPrefferedLanguages(myprefs: myprefs)

    /* one */
    XCTAssertEqual(R.string.one.one1(preferredLanguages: myprefs),
                   "one 1, not localized")
    XCTAssertEqual(R.string.one.one2(preferredLanguages: myprefs),
                   "one 2, not localized")
    XCTAssertEqual(R.string.one.oneArg("ARG", preferredLanguages: myprefs),
                   "one ARG, not localized")

    /* two */
    XCTAssertEqual(R.string.two.two1(preferredLanguages: myprefs),
                   "two1")
    XCTAssertEqual(R.string.two.two2("Hello", preferredLanguages: myprefs),
                   "two2")

    /* three */
    XCTAssertEqual(R.string.three.three1(preferredLanguages: myprefs),
                   "three1")
    XCTAssertEqual(R.string.three.three2(preferredLanguages: myprefs),
                   "three2")
    XCTAssertEqual(R.string.three.three3(preferredLanguages: myprefs),
                   "three3")
    XCTAssertEqual(R.string.three.threeArg1("ARG", preferredLanguages: myprefs),
                   "threeArg1")
    XCTAssertEqual(R.string.three.threeArg2("ARG", preferredLanguages: myprefs),
                   "threeArg2")
    XCTAssertEqual(R.string.three.threeArg3("ARG", preferredLanguages: myprefs),
                   "threeArg3")

    /* four */
    XCTAssertEqual(R.string.four.four1(preferredLanguages: myprefs),
                   "four1")
    XCTAssertEqual(R.string.four.fourArg("ARG", preferredLanguages: myprefs),
                   "fourArg")

    /* five */
    XCTAssertEqual(R.string.five.five1(preferredLanguages: myprefs),
                   "five 1, localized french")
    XCTAssertEqual(R.string.five.five2(preferredLanguages: myprefs),
                   "five 2, localized french")
    XCTAssertEqual(R.string.five.five4(preferredLanguages: myprefs),
                   "five 4, localized french")
    XCTAssertEqual(R.string.five.fiveArg1("ARG", preferredLanguages: myprefs),
                   "five 1 ARG, localized french")
    XCTAssertEqual(R.string.five.fiveArg2("ARG", preferredLanguages: myprefs),
                   "five 2 ARG, localized french")
    XCTAssertEqual(R.string.five.fiveArg4("ARG", preferredLanguages: myprefs),
                   "five 4 ARG, localized french")

    /* six */
    XCTAssertEqual(R.string.six.six1(preferredLanguages: myprefs),
                   "six 1, localized french")
    XCTAssertEqual(R.string.six.six2(preferredLanguages: myprefs),
                   "six 2, localized french")
    XCTAssertEqual(R.string.six.sixArg1("ARG", preferredLanguages: myprefs),
                   "six 1 ARG, localized french")
    XCTAssertEqual(R.string.six.sixArg2("ARG", preferredLanguages: myprefs),
                   "six 2 ARG, localized french")

    /* seven */
    XCTAssertEqual(R.string.seven.seven1(preferredLanguages: myprefs),
                   "seven 1, localized french")
    XCTAssertEqual(R.string.seven.seven2(preferredLanguages: myprefs),
                   "seven 2, localized french")
    XCTAssertEqual(R.string.seven.seven3(preferredLanguages: myprefs),
                   "seven 3, localized french")
    XCTAssertEqual(R.string.seven.seven4(preferredLanguages: myprefs),
                   "seven 4, localized french")
    XCTAssertEqual(R.string.seven.sevenArg1("ARG", preferredLanguages: myprefs),
                   "seven 1 ARG, localized french")
    XCTAssertEqual(R.string.seven.sevenArg2("ARG", preferredLanguages: myprefs),
                   "seven 2 ARG, localized french")
    XCTAssertEqual(R.string.seven.sevenArg3("ARG", preferredLanguages: myprefs),
                   "seven 3 ARG, localized french")
    XCTAssertEqual(R.string.seven.sevenArg4("ARG", preferredLanguages: myprefs),
                   "seven 4 ARG, localized french")

    /* eight */
    XCTAssertEqual(R.string.eight.eight1(preferredLanguages: myprefs),
                   "eight 1, localized french")
    XCTAssertEqual(R.string.eight.eight2(preferredLanguages: myprefs),
                   "eight 2, localized french")
    XCTAssertEqual(R.string.eight.eight3(preferredLanguages: myprefs),
                   "eight3")
    XCTAssertEqual(R.string.eight.eightArg1("ARG", preferredLanguages: myprefs),
                   "eight 1 ARG, localized french")
    XCTAssertEqual(R.string.eight.eightArg2("ARG", preferredLanguages: myprefs),
                   "eight 2 ARG, localized french")
    XCTAssertEqual(R.string.eight.eightArg3("ARG", preferredLanguages: myprefs),
                   "eightArg3")

    /* nine */
    XCTAssertEqual(R.string.nine.nine1(preferredLanguages: myprefs),
                   "nine 1, localized french")
    XCTAssertEqual(R.string.nine.nine2(preferredLanguages: myprefs),
                   "nine 2, localized french")
    XCTAssertEqual(R.string.nine.nine3(preferredLanguages: myprefs),
                   "nine3")
    XCTAssertEqual(R.string.nine.nineArg1("ARG", preferredLanguages: myprefs),
                   "nine 1 ARG, localized french")
    XCTAssertEqual(R.string.nine.nineArg2("ARG", preferredLanguages: myprefs),
                   "nine 2 ARG, localized french")
    XCTAssertEqual(R.string.nine.nineArg3("ARG", preferredLanguages: myprefs),
                   "nineArg3")

    /* ten */
    XCTAssertEqual(R.string.ten.ten1(things: 1, preferredLanguages: myprefs),
                   "ten 1 - 1 thing, localized french")
  }


  func testFrenchCanada() {
    let myprefs = ["fr-CA"]

    testPrefferedLanguages(myprefs: myprefs)

    /* one */
    XCTAssertEqual(R.string.one.one1(preferredLanguages: myprefs),
                   "one 1, not localized")
    XCTAssertEqual(R.string.one.one2(preferredLanguages: myprefs),
                   "one 2, not localized")
    XCTAssertEqual(R.string.one.oneArg("ARG", preferredLanguages: myprefs),
                   "one ARG, not localized")

    /* two */
    XCTAssertEqual(R.string.two.two1(preferredLanguages: myprefs),
                   "two1")
    XCTAssertEqual(R.string.two.two2("Hello", preferredLanguages: myprefs),
                   "two2")

    /* three */
    XCTAssertEqual(R.string.three.three1(preferredLanguages: myprefs),
                   "three1")
    XCTAssertEqual(R.string.three.three2(preferredLanguages: myprefs),
                   "three2")
    XCTAssertEqual(R.string.three.three3(preferredLanguages: myprefs),
                   "three3")
    XCTAssertEqual(R.string.three.threeArg1("ARG", preferredLanguages: myprefs),
                   "threeArg1")
    XCTAssertEqual(R.string.three.threeArg2("ARG", preferredLanguages: myprefs),
                   "threeArg2")
    XCTAssertEqual(R.string.three.threeArg3("ARG", preferredLanguages: myprefs),
                   "threeArg3")

    /* four */
    XCTAssertEqual(R.string.four.four1(preferredLanguages: myprefs),
                   "four1")
    XCTAssertEqual(R.string.four.fourArg("ARG", preferredLanguages: myprefs),
                   "fourArg")

    /* five */
    XCTAssertEqual(R.string.five.five1(preferredLanguages: myprefs),
                   "five 1, localized french canada")
    XCTAssertEqual(R.string.five.five2(preferredLanguages: myprefs),
                   "five2")
    XCTAssertEqual(R.string.five.five4(preferredLanguages: myprefs),
                   "five4")
    XCTAssertEqual(R.string.five.fiveArg1("ARG", preferredLanguages: myprefs),
                   "five 1 ARG, localized french canada")
    XCTAssertEqual(R.string.five.fiveArg2("ARG", preferredLanguages: myprefs),
                   "fiveArg2")
    XCTAssertEqual(R.string.five.fiveArg4("ARG", preferredLanguages: myprefs),
                   "fiveArg4")

    /* six */
    XCTAssertEqual(R.string.six.six1(preferredLanguages: myprefs),
                   "six 1, localized french canada")
    XCTAssertEqual(R.string.six.six2(preferredLanguages: myprefs),
                   "six2")
    XCTAssertEqual(R.string.six.sixArg1("ARG", preferredLanguages: myprefs),
                   "six 1 ARG, localized french canada")
    XCTAssertEqual(R.string.six.sixArg2("ARG", preferredLanguages: myprefs),
                   "sixArg2")

    /* seven */
    XCTAssertEqual(R.string.seven.seven1(preferredLanguages: myprefs),
                   "seven 1, localized french")
    XCTAssertEqual(R.string.seven.seven2(preferredLanguages: myprefs),
                   "seven 2, localized french")
    XCTAssertEqual(R.string.seven.seven3(preferredLanguages: myprefs),
                   "seven 3, localized french")
    XCTAssertEqual(R.string.seven.seven4(preferredLanguages: myprefs),
                   "seven 4, localized french")
    XCTAssertEqual(R.string.seven.sevenArg1("ARG", preferredLanguages: myprefs),
                   "seven 1 ARG, localized french")
    XCTAssertEqual(R.string.seven.sevenArg2("ARG", preferredLanguages: myprefs),
                   "seven 2 ARG, localized french")
    XCTAssertEqual(R.string.seven.sevenArg3("ARG", preferredLanguages: myprefs),
                   "seven 3 ARG, localized french")
    XCTAssertEqual(R.string.seven.sevenArg4("ARG", preferredLanguages: myprefs),
                   "seven 4 ARG, localized french")

    /* eight */
    XCTAssertEqual(R.string.eight.eight1(preferredLanguages: myprefs),
                   "eight 1, localized base")
    XCTAssertEqual(R.string.eight.eight2(preferredLanguages: myprefs),
                   "eight 2, localized base")
    XCTAssertEqual(R.string.eight.eight3(preferredLanguages: myprefs),
                   "eight 3, localized base")
    XCTAssertEqual(R.string.eight.eightArg1("ARG", preferredLanguages: myprefs),
                   "eight 1 ARG, localized base")
    XCTAssertEqual(R.string.eight.eightArg2("ARG", preferredLanguages: myprefs),
                   "eight 2 ARG, localized base")
    XCTAssertEqual(R.string.eight.eightArg3("ARG", preferredLanguages: myprefs),
                   "eight 3 ARG, localized base")

    /* nine */
    XCTAssertEqual(R.string.nine.nine1(preferredLanguages: myprefs),
                   "nine 1, localized base")
    XCTAssertEqual(R.string.nine.nine2(preferredLanguages: myprefs),
                   "nine 2, localized base")
    XCTAssertEqual(R.string.nine.nine3(preferredLanguages: myprefs),
                   "nine 3, localized base")
    XCTAssertEqual(R.string.nine.nineArg1("ARG", preferredLanguages: myprefs),
                   "nine 1 ARG, localized base")
    XCTAssertEqual(R.string.nine.nineArg2("ARG", preferredLanguages: myprefs),
                   "nine 2 ARG, localized base")
    XCTAssertEqual(R.string.nine.nineArg3("ARG", preferredLanguages: myprefs),
                   "nine 3 ARG, localized base")

    /* ten */
    XCTAssertEqual(R.string.ten.ten1(things: 1, preferredLanguages: myprefs),
                   "ten 1 - 1 thing, localized french")
  }


  func testPrefferedLanguages(myprefs: [String]) {

    /* one */
    XCTAssertEqual(R.string.one.one1(preferredLanguages: myprefs),
                   R.string.one(preferredLanguages: myprefs).one1())
    XCTAssertEqual(R.string.one.one2(preferredLanguages: myprefs),
                   R.string.one(preferredLanguages: myprefs).one2())
    XCTAssertEqual(R.string.one.oneArg("ARG", preferredLanguages: myprefs),
                   R.string.one(preferredLanguages: myprefs).oneArg("ARG"))

    /* two */
    XCTAssertEqual(R.string.two.two1(preferredLanguages: myprefs),
                   R.string.two(preferredLanguages: myprefs).two1())
    XCTAssertEqual(R.string.two.two2("Hello", preferredLanguages: myprefs),
                   R.string.two(preferredLanguages: myprefs).two2("Hello"))

    /* three */
    XCTAssertEqual(R.string.three.three1(preferredLanguages: myprefs),
                   R.string.three(preferredLanguages: myprefs).three1())
    XCTAssertEqual(R.string.three.three2(preferredLanguages: myprefs),
                   R.string.three(preferredLanguages: myprefs).three2())
    XCTAssertEqual(R.string.three.three3(preferredLanguages: myprefs),
                   R.string.three(preferredLanguages: myprefs).three3())
    XCTAssertEqual(R.string.three.threeArg1("ARG", preferredLanguages: myprefs),
                   R.string.three(preferredLanguages: myprefs).threeArg1("ARG"))
    XCTAssertEqual(R.string.three.threeArg2("ARG", preferredLanguages: myprefs),
                   R.string.three(preferredLanguages: myprefs).threeArg2("ARG"))
    XCTAssertEqual(R.string.three.threeArg3("ARG", preferredLanguages: myprefs),
                   R.string.three(preferredLanguages: myprefs).threeArg3("ARG"))

    /* four */
    XCTAssertEqual(R.string.four.four1(preferredLanguages: myprefs),
                   R.string.four(preferredLanguages: myprefs).four1())
    XCTAssertEqual(R.string.four.fourArg("ARG", preferredLanguages: myprefs),
                   R.string.four(preferredLanguages: myprefs).fourArg("ARG"))

    /* five */
    XCTAssertEqual(R.string.five.five1(preferredLanguages: myprefs),
                   R.string.five(preferredLanguages: myprefs).five1())
    XCTAssertEqual(R.string.five.five2(preferredLanguages: myprefs),
                   R.string.five(preferredLanguages: myprefs).five2())
    XCTAssertEqual(R.string.five.five4(preferredLanguages: myprefs),
                   R.string.five(preferredLanguages: myprefs).five4())
    XCTAssertEqual(R.string.five.fiveArg1("ARG", preferredLanguages: myprefs),
                   R.string.five(preferredLanguages: myprefs).fiveArg1("ARG"))
    XCTAssertEqual(R.string.five.fiveArg2("ARG", preferredLanguages: myprefs),
                   R.string.five(preferredLanguages: myprefs).fiveArg2("ARG"))
    XCTAssertEqual(R.string.five.fiveArg4("ARG", preferredLanguages: myprefs),
                   R.string.five(preferredLanguages: myprefs).fiveArg4("ARG"))

    /* six */
    XCTAssertEqual(R.string.six.six1(preferredLanguages: myprefs),
                   R.string.six(preferredLanguages: myprefs).six1())
    XCTAssertEqual(R.string.six.six2(preferredLanguages: myprefs),
                   R.string.six(preferredLanguages: myprefs).six2())
    XCTAssertEqual(R.string.six.sixArg1("ARG", preferredLanguages: myprefs),
                   R.string.six(preferredLanguages: myprefs).sixArg1("ARG"))
    XCTAssertEqual(R.string.six.sixArg2("ARG", preferredLanguages: myprefs),
                   R.string.six(preferredLanguages: myprefs).sixArg2("ARG"))

    /* seven */
    XCTAssertEqual(R.string.seven.seven1(preferredLanguages: myprefs),
                   R.string.seven(preferredLanguages: myprefs).seven1())
    XCTAssertEqual(R.string.seven.seven2(preferredLanguages: myprefs),
                   R.string.seven(preferredLanguages: myprefs).seven2())
    XCTAssertEqual(R.string.seven.seven3(preferredLanguages: myprefs),
                   R.string.seven(preferredLanguages: myprefs).seven3())
    XCTAssertEqual(R.string.seven.seven4(preferredLanguages: myprefs),
                   R.string.seven(preferredLanguages: myprefs).seven4())
    XCTAssertEqual(R.string.seven.sevenArg1("ARG", preferredLanguages: myprefs),
                   R.string.seven(preferredLanguages: myprefs).sevenArg1("ARG"))
    XCTAssertEqual(R.string.seven.sevenArg2("ARG", preferredLanguages: myprefs),
                   R.string.seven(preferredLanguages: myprefs).sevenArg2("ARG"))
    XCTAssertEqual(R.string.seven.sevenArg3("ARG", preferredLanguages: myprefs),
                   R.string.seven(preferredLanguages: myprefs).sevenArg3("ARG"))
    XCTAssertEqual(R.string.seven.sevenArg4("ARG", preferredLanguages: myprefs),
                   R.string.seven(preferredLanguages: myprefs).sevenArg4("ARG"))

    /* eight */
    XCTAssertEqual(R.string.eight.eight1(preferredLanguages: myprefs),
                   R.string.eight(preferredLanguages: myprefs).eight1())
    XCTAssertEqual(R.string.eight.eight2(preferredLanguages: myprefs),
                   R.string.eight(preferredLanguages: myprefs).eight2())
    XCTAssertEqual(R.string.eight.eight3(preferredLanguages: myprefs),
                   R.string.eight(preferredLanguages: myprefs).eight3())
    XCTAssertEqual(R.string.eight.eightArg1("ARG", preferredLanguages: myprefs),
                   R.string.eight(preferredLanguages: myprefs).eightArg1("ARG"))
    XCTAssertEqual(R.string.eight.eightArg2("ARG", preferredLanguages: myprefs),
                   R.string.eight(preferredLanguages: myprefs).eightArg2("ARG"))
    XCTAssertEqual(R.string.eight.eightArg3("ARG", preferredLanguages: myprefs),
                   R.string.eight(preferredLanguages: myprefs).eightArg3("ARG"))

    /* nine */
    XCTAssertEqual(R.string.nine.nine1(preferredLanguages: myprefs),
                   R.string.nine(preferredLanguages: myprefs).nine1())
    XCTAssertEqual(R.string.nine.nine2(preferredLanguages: myprefs),
                   R.string.nine(preferredLanguages: myprefs).nine2())
    XCTAssertEqual(R.string.nine.nine3(preferredLanguages: myprefs),
                   R.string.nine(preferredLanguages: myprefs).nine3())
    XCTAssertEqual(R.string.nine.nineArg1("ARG", preferredLanguages: myprefs),
                   R.string.nine(preferredLanguages: myprefs).nineArg1("ARG"))
    XCTAssertEqual(R.string.nine.nineArg2("ARG", preferredLanguages: myprefs),
                   R.string.nine(preferredLanguages: myprefs).nineArg2("ARG"))
    XCTAssertEqual(R.string.nine.nineArg3("ARG", preferredLanguages: myprefs),
                   R.string.nine(preferredLanguages: myprefs).nineArg3("ARG"))

    /* ten */
    XCTAssertEqual(R.string.ten.ten1(things: 1, preferredLanguages: myprefs),
                   R.string.ten(preferredLanguages: myprefs).ten1(things: 1))
  }

}
