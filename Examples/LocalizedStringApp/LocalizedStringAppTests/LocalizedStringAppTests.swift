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
    let strings = R.string(preferredLanguages: myprefs)

    /* one */
    XCTAssertEqual(strings.one.one1(),
                   "one 1, not localized")
    XCTAssertEqual(strings.one.one2(),
                   "one 2, not localized")
    XCTAssertEqual(strings.one.oneArg("ARG"),
                   "one ARG, not localized")

    /* two */
    XCTAssertEqual(strings.two.two1(),
                   "two1")
    XCTAssertEqual(strings.two.two2("Hello"),
                   "two2")

    /* three */
    XCTAssertEqual(strings.three.three1(),
                   "three1")
    XCTAssertEqual(strings.three.three2(),
                   "three2")
    XCTAssertEqual(strings.three.three3(),
                   "three3")
    XCTAssertEqual(strings.three.threeArg1("ARG"),
                   "threeArg1")
    XCTAssertEqual(strings.three.threeArg2("ARG"),
                   "threeArg2")
    XCTAssertEqual(strings.three.threeArg3("ARG"),
                   "threeArg3")

    /* four */
    XCTAssertEqual(strings.four.four1(),
                   "four1")
    XCTAssertEqual(strings.four.fourArg("ARG"),
                   "fourArg")

    /* five */
    XCTAssertEqual(strings.five.five1(),
                   "five 1, localized french")
    XCTAssertEqual(strings.five.five2(),
                   "five 2, localized french")
    XCTAssertEqual(strings.five.five4(),
                   "five 4, localized french")
    XCTAssertEqual(strings.five.fiveArg1("ARG"),
                   "five 1 ARG, localized french")
    XCTAssertEqual(strings.five.fiveArg2("ARG"),
                   "five 2 ARG, localized french")
    XCTAssertEqual(strings.five.fiveArg4("ARG"),
                   "five 4 ARG, localized french")

    /* six */
    XCTAssertEqual(strings.six.six1(),
                   "six 1, localized french")
    XCTAssertEqual(strings.six.six2(),
                   "six 2, localized french")
    XCTAssertEqual(strings.six.sixArg1("ARG"),
                   "six 1 ARG, localized french")
    XCTAssertEqual(strings.six.sixArg2("ARG"),
                   "six 2 ARG, localized french")

    /* seven */
    XCTAssertEqual(strings.seven.seven1(),
                   "seven 1, localized french")
    XCTAssertEqual(strings.seven.seven2(),
                   "seven 2, localized french")
    XCTAssertEqual(strings.seven.seven3(),
                   "seven 3, localized french")
    XCTAssertEqual(strings.seven.seven4(),
                   "seven 4, localized french")
    XCTAssertEqual(strings.seven.sevenArg1("ARG"),
                   "seven 1 ARG, localized french")
    XCTAssertEqual(strings.seven.sevenArg2("ARG"),
                   "seven 2 ARG, localized french")
    XCTAssertEqual(strings.seven.sevenArg3("ARG"),
                   "seven 3 ARG, localized french")
    XCTAssertEqual(strings.seven.sevenArg4("ARG"),
                   "seven 4 ARG, localized french")

    /* eight */
    XCTAssertEqual(strings.eight.eight1(),
                   "eight 1, localized french")
    XCTAssertEqual(strings.eight.eight2(),
                   "eight 2, localized french")
    XCTAssertEqual(strings.eight.eight3(),
                   "eight3")
    XCTAssertEqual(strings.eight.eightArg1("ARG"),
                   "eight 1 ARG, localized french")
    XCTAssertEqual(strings.eight.eightArg2("ARG"),
                   "eight 2 ARG, localized french")
    XCTAssertEqual(strings.eight.eightArg3("ARG"),
                   "eightArg3")

    /* nine */
    XCTAssertEqual(strings.nine.nine1(),
                   "nine 1, localized french")
    XCTAssertEqual(strings.nine.nine2(),
                   "nine 2, localized french")
    XCTAssertEqual(strings.nine.nine3(),
                   "nine3")
    XCTAssertEqual(strings.nine.nineArg1("ARG"),
                   "nine 1 ARG, localized french")
    XCTAssertEqual(strings.nine.nineArg2("ARG"),
                   "nine 2 ARG, localized french")
    XCTAssertEqual(strings.nine.nineArg3("ARG"),
                   "nineArg3")

    /* ten */
    XCTAssertEqual(strings.ten.ten1(things: 1),
                   "ten 1 - 1 thing, localized french")
  }

  func testDutch() {
    let myprefs = ["nl"]

    testPrefferedLanguages(myprefs: myprefs)
    let strings = R.string(preferredLanguages: myprefs)

    /* one */
    XCTAssertEqual(strings.one.one1(),
                   "one 1, not localized")
    XCTAssertEqual(strings.one.one2(),
                   "one 2, not localized")
    XCTAssertEqual(strings.one.oneArg("ARG"),
                   "one ARG, not localized")

    /* two */
    XCTAssertEqual(strings.two.two1(),
                   "two1")
    XCTAssertEqual(strings.two.two2("Hello"),
                   "two2")

    /* three */
    XCTAssertEqual(strings.three.three1(),
                   "three 1, localized dutch")
    XCTAssertEqual(strings.three.three2(),
                   "three2")
    XCTAssertEqual(strings.three.three3(),
                   "three 3, localized dutch")
    XCTAssertEqual(strings.three.threeArg1("ARG"),
                   "three 1 ARG, localized dutch")
    XCTAssertEqual(strings.three.threeArg2("ARG"),
                   "threeArg2")
    XCTAssertEqual(strings.three.threeArg3("ARG"),
                   "three 3 ARG, localized dutch")

    /* four */
    XCTAssertEqual(strings.four.four1(),
                   "four 1, localized dutch")
    XCTAssertEqual(strings.four.fourArg("ARG"),
                   "four ARG, localized dutch")

    /* five */
    XCTAssertEqual(strings.five.five1(),
                   "five 1, localized french")
    XCTAssertEqual(strings.five.five2(),
                   "five 2, localized french")
    XCTAssertEqual(strings.five.five4(),
                   "five 4, localized french")
    XCTAssertEqual(strings.five.fiveArg1("ARG"),
                   "five 1 ARG, localized french")
    XCTAssertEqual(strings.five.fiveArg2("ARG"),
                   "five 2 ARG, localized french")
    XCTAssertEqual(strings.five.fiveArg4("ARG"),
                   "five 4 ARG, localized french")

    /* six */
    XCTAssertEqual(strings.six.six1(),
                   "six 1, localized french")
    XCTAssertEqual(strings.six.six2(),
                   "six 2, localized french")
    XCTAssertEqual(strings.six.sixArg1("ARG"),
                   "six 1 ARG, localized french")
    XCTAssertEqual(strings.six.sixArg2("ARG"),
                   "six 2 ARG, localized french")

    /* seven */
    XCTAssertEqual(strings.seven.seven1(),
                   "seven 1, localized dutch")
    XCTAssertEqual(strings.seven.seven2(),
                   "seven2")
    XCTAssertEqual(strings.seven.seven3(),
                   "seven3")
    XCTAssertEqual(strings.seven.seven4(),
                   "seven 4, localized dutch")
    XCTAssertEqual(strings.seven.sevenArg1("ARG"),
                   "seven 1 ARG, localized dutch")
    XCTAssertEqual(strings.seven.sevenArg2("ARG"),
                   "sevenArg2")
    XCTAssertEqual(strings.seven.sevenArg3("ARG"),
                   "sevenArg3")
    XCTAssertEqual(strings.seven.sevenArg4("ARG"),
                   "seven 4 ARG, localized dutch")

    /* eight */
    XCTAssertEqual(strings.eight.eight1(),
                   "eight 1, localized dutch")
    XCTAssertEqual(strings.eight.eight2(),
                   "eight2")
    XCTAssertEqual(strings.eight.eight3(),
                   "eight3")
    XCTAssertEqual(strings.eight.eightArg1("ARG"),
                   "eight 1 ARG, localized dutch")
    XCTAssertEqual(strings.eight.eightArg2("ARG"),
                   "eightArg2")
    XCTAssertEqual(strings.eight.eightArg3("ARG"),
                   "eightArg3")

    /* nine */
    XCTAssertEqual(strings.nine.nine1(),
                   "nine 1, localized dutch")
    XCTAssertEqual(strings.nine.nine2(),
                   "nine2")
    XCTAssertEqual(strings.nine.nine3(),
                   "nine3")
    XCTAssertEqual(strings.nine.nineArg1("ARG"),
                   "nine 1 ARG, localized dutch")
    XCTAssertEqual(strings.nine.nineArg2("ARG"),
                   "nineArg2")
    XCTAssertEqual(strings.nine.nineArg3("ARG"),
                   "nineArg3")

    /* ten */
    XCTAssertEqual(strings.ten.ten1(things: 1),
                   "ten 1 - 1 thing, localized dutch")
  }

  func testEnglish() {
    let myprefs = ["en"]

    testPrefferedLanguages(myprefs: myprefs)
    let strings = R.string(preferredLanguages: myprefs)

    /* one */
    XCTAssertEqual(strings.one.one1(),
                   "one 1, not localized")
    XCTAssertEqual(strings.one.one2(),
                   "one 2, not localized")
    XCTAssertEqual(strings.one.oneArg("ARG"),
                   "one ARG, not localized")

    /* two */
    XCTAssertEqual(strings.two.two1(),
                   "two 1, localized english")
    XCTAssertEqual(strings.two.two2("Hello"),
                   "two 2, Hello localized english")

    /* three */
    XCTAssertEqual(strings.three.three1(),
                   "three 1, localized english")
    XCTAssertEqual(strings.three.three2(),
                   "three 2, localized english")
    XCTAssertEqual(strings.three.three3(),
                   "three3")
    XCTAssertEqual(strings.three.threeArg1("ARG"),
                   "three 1 ARG, localized english")
    XCTAssertEqual(strings.three.threeArg2("ARG"),
                   "three 2 ARG, localized english")
    XCTAssertEqual(strings.three.threeArg3("ARG"),
                   "threeArg3")

    /* four */
    XCTAssertEqual(strings.four.four1(),
                   "four1")
    XCTAssertEqual(strings.four.fourArg("ARG"),
                   "fourArg")

    /* five */
    XCTAssertEqual(strings.five.five1(),
                   "five 1, localized english")
    XCTAssertEqual(strings.five.five2(),
                   "five 2, localized english")
    XCTAssertEqual(strings.five.five4(),
                   "five4")
    XCTAssertEqual(strings.five.fiveArg1("ARG"),
                   "five 1 ARG, localized english")
    XCTAssertEqual(strings.five.fiveArg2("ARG"),
                   "five 2 ARG, localized english")
    XCTAssertEqual(strings.five.fiveArg4("ARG"),
                   "fiveArg4")

    /* six */
    XCTAssertEqual(strings.six.six1(),
                   "six 1, localized french")
    XCTAssertEqual(strings.six.six2(),
                   "six 2, localized french")
    XCTAssertEqual(strings.six.sixArg1("ARG"),
                   "six 1 ARG, localized french")
    XCTAssertEqual(strings.six.sixArg2("ARG"),
                   "six 2 ARG, localized french")

    /* seven */
    XCTAssertEqual(strings.seven.seven1(),
                   "seven 1, localized english")
    XCTAssertEqual(strings.seven.seven2(),
                   "seven 2, localized english")
    XCTAssertEqual(strings.seven.seven3(),
                   "seven3")
    XCTAssertEqual(strings.seven.seven4(),
                   "seven4")
    XCTAssertEqual(strings.seven.sevenArg1("ARG"),
                   "seven 1 ARG, localized english")
    XCTAssertEqual(strings.seven.sevenArg2("ARG"),
                   "seven 2 ARG, localized english")
    XCTAssertEqual(strings.seven.sevenArg3("ARG"),
                   "sevenArg3")
    XCTAssertEqual(strings.seven.sevenArg4("ARG"),
                   "sevenArg4")

    /* eight */
    XCTAssertEqual(strings.eight.eight1(),
                   "eight 1, localized base")
    XCTAssertEqual(strings.eight.eight2(),
                   "eight 2, localized base")
    XCTAssertEqual(strings.eight.eight3(),
                   "eight 3, localized base")
    XCTAssertEqual(strings.eight.eightArg1("ARG"),
                   "eight 1 ARG, localized base")
    XCTAssertEqual(strings.eight.eightArg2("ARG"),
                   "eight 2 ARG, localized base")
    XCTAssertEqual(strings.eight.eightArg3("ARG"),
                   "eight 3 ARG, localized base")

    /* nine */
    XCTAssertEqual(strings.nine.nine1(),
                   "nine 1, localized english")
    XCTAssertEqual(strings.nine.nine2(),
                   "nine 2, localized english")
    XCTAssertEqual(strings.nine.nine3(),
                   "nine3")
    XCTAssertEqual(strings.nine.nineArg1("ARG"),
                   "nine 1 ARG, localized english")
    XCTAssertEqual(strings.nine.nineArg2("ARG"),
                   "nine 2 ARG, localized english")
    XCTAssertEqual(strings.nine.nineArg3("ARG"),
                   "nineArg3")

    /* ten */
    XCTAssertEqual(strings.ten.ten1(things: 1),
                   "ten 1 - 1 thing, localized french")
  }


  func testEnglishGB() {
    let myprefs = ["en-GB"]

    testPrefferedLanguages(myprefs: myprefs)
    let strings = R.string(preferredLanguages: myprefs)

    /* one */
    XCTAssertEqual(strings.one.one1(),
                   "one 1, not localized")
    XCTAssertEqual(strings.one.one2(),
                   "one 2, not localized")
    XCTAssertEqual(strings.one.oneArg("ARG"),
                   "one ARG, not localized")

    /* two */
    XCTAssertEqual(strings.two.two1(),
                   "two 1, localized english")
    XCTAssertEqual(strings.two.two2("Hello"),
                   "two 2, Hello localized english")

    /* three */
    XCTAssertEqual(strings.three.three1(),
                   "three 1, localized english")
    XCTAssertEqual(strings.three.three2(),
                   "three 2, localized english")
    XCTAssertEqual(strings.three.three3(),
                   "three3")
    XCTAssertEqual(strings.three.threeArg1("ARG"),
                   "three 1 ARG, localized english")
    XCTAssertEqual(strings.three.threeArg2("ARG"),
                   "three 2 ARG, localized english")
    XCTAssertEqual(strings.three.threeArg3("ARG"),
                   "threeArg3")

    /* four */
    XCTAssertEqual(strings.four.four1(),
                   "four1")
    XCTAssertEqual(strings.four.fourArg("ARG"),
                   "fourArg")

    /* five */
    XCTAssertEqual(strings.five.five1(),
                   "five 1, localized english gb")
    XCTAssertEqual(strings.five.five2(),
                   "five2")
    XCTAssertEqual(strings.five.five4(),
                   "five4")
    XCTAssertEqual(strings.five.fiveArg1("ARG"),
                   "five 1 ARG, localized english gb")
    XCTAssertEqual(strings.five.fiveArg2("ARG"),
                   "fiveArg2")
    XCTAssertEqual(strings.five.fiveArg4("ARG"),
                   "fiveArg4")

    /* six */
    XCTAssertEqual(strings.six.six1(),
                   "six 1, localized french")
    XCTAssertEqual(strings.six.six2(),
                   "six 2, localized french")
    XCTAssertEqual(strings.six.sixArg1("ARG"),
                   "six 1 ARG, localized french")
    XCTAssertEqual(strings.six.sixArg2("ARG"),
                   "six 2 ARG, localized french")

    /* seven */
    XCTAssertEqual(strings.seven.seven1(),
                   "seven 1, localized english")
    XCTAssertEqual(strings.seven.seven2(),
                   "seven 2, localized english")
    XCTAssertEqual(strings.seven.seven3(),
                   "seven3")
    XCTAssertEqual(strings.seven.seven4(),
                   "seven4")
    XCTAssertEqual(strings.seven.sevenArg1("ARG"),
                   "seven 1 ARG, localized english")
    XCTAssertEqual(strings.seven.sevenArg2("ARG"),
                   "seven 2 ARG, localized english")
    XCTAssertEqual(strings.seven.sevenArg3("ARG"),
                   "sevenArg3")
    XCTAssertEqual(strings.seven.sevenArg4("ARG"),
                   "sevenArg4")

    /* eight */
    XCTAssertEqual(strings.eight.eight1(),
                   "eight 1, localized base")
    XCTAssertEqual(strings.eight.eight2(),
                   "eight 2, localized base")
    XCTAssertEqual(strings.eight.eight3(),
                   "eight 3, localized base")
    XCTAssertEqual(strings.eight.eightArg1("ARG"),
                   "eight 1 ARG, localized base")
    XCTAssertEqual(strings.eight.eightArg2("ARG"),
                   "eight 2 ARG, localized base")
    XCTAssertEqual(strings.eight.eightArg3("ARG"),
                   "eight 3 ARG, localized base")

    /* nine */
    XCTAssertEqual(strings.nine.nine1(),
                   "nine 1, localized base")
    XCTAssertEqual(strings.nine.nine2(),
                   "nine 2, localized base")
    XCTAssertEqual(strings.nine.nine3(),
                   "nine 3, localized base")
    XCTAssertEqual(strings.nine.nineArg1("ARG"),
                   "nine 1 ARG, localized base")
    XCTAssertEqual(strings.nine.nineArg2("ARG"),
                   "nine 2 ARG, localized base")
    XCTAssertEqual(strings.nine.nineArg3("ARG"),
                   "nine 3 ARG, localized base")

    /* ten */
    XCTAssertEqual(strings.ten.ten1(things: 1),
                   "ten 1 - 1 thing, localized french")
  }


  func testFrench() {
    let myprefs = ["fr"]

    testPrefferedLanguages(myprefs: myprefs)
    let strings = R.string(preferredLanguages: myprefs)

    /* one */
    XCTAssertEqual(strings.one.one1(),
                   "one 1, not localized")
    XCTAssertEqual(strings.one.one2(),
                   "one 2, not localized")
    XCTAssertEqual(strings.one.oneArg("ARG"),
                   "one ARG, not localized")

    /* two */
    XCTAssertEqual(strings.two.two1(),
                   "two1")
    XCTAssertEqual(strings.two.two2("Hello"),
                   "two2")

    /* three */
    XCTAssertEqual(strings.three.three1(),
                   "three1")
    XCTAssertEqual(strings.three.three2(),
                   "three2")
    XCTAssertEqual(strings.three.three3(),
                   "three3")
    XCTAssertEqual(strings.three.threeArg1("ARG"),
                   "threeArg1")
    XCTAssertEqual(strings.three.threeArg2("ARG"),
                   "threeArg2")
    XCTAssertEqual(strings.three.threeArg3("ARG"),
                   "threeArg3")

    /* four */
    XCTAssertEqual(strings.four.four1(),
                   "four1")
    XCTAssertEqual(strings.four.fourArg("ARG"),
                   "fourArg")

    /* five */
    XCTAssertEqual(strings.five.five1(),
                   "five 1, localized french")
    XCTAssertEqual(strings.five.five2(),
                   "five 2, localized french")
    XCTAssertEqual(strings.five.five4(),
                   "five 4, localized french")
    XCTAssertEqual(strings.five.fiveArg1("ARG"),
                   "five 1 ARG, localized french")
    XCTAssertEqual(strings.five.fiveArg2("ARG"),
                   "five 2 ARG, localized french")
    XCTAssertEqual(strings.five.fiveArg4("ARG"),
                   "five 4 ARG, localized french")

    /* six */
    XCTAssertEqual(strings.six.six1(),
                   "six 1, localized french")
    XCTAssertEqual(strings.six.six2(),
                   "six 2, localized french")
    XCTAssertEqual(strings.six.sixArg1("ARG"),
                   "six 1 ARG, localized french")
    XCTAssertEqual(strings.six.sixArg2("ARG"),
                   "six 2 ARG, localized french")

    /* seven */
    XCTAssertEqual(strings.seven.seven1(),
                   "seven 1, localized french")
    XCTAssertEqual(strings.seven.seven2(),
                   "seven 2, localized french")
    XCTAssertEqual(strings.seven.seven3(),
                   "seven 3, localized french")
    XCTAssertEqual(strings.seven.seven4(),
                   "seven 4, localized french")
    XCTAssertEqual(strings.seven.sevenArg1("ARG"),
                   "seven 1 ARG, localized french")
    XCTAssertEqual(strings.seven.sevenArg2("ARG"),
                   "seven 2 ARG, localized french")
    XCTAssertEqual(strings.seven.sevenArg3("ARG"),
                   "seven 3 ARG, localized french")
    XCTAssertEqual(strings.seven.sevenArg4("ARG"),
                   "seven 4 ARG, localized french")

    /* eight */
    XCTAssertEqual(strings.eight.eight1(),
                   "eight 1, localized french")
    XCTAssertEqual(strings.eight.eight2(),
                   "eight 2, localized french")
    XCTAssertEqual(strings.eight.eight3(),
                   "eight3")
    XCTAssertEqual(strings.eight.eightArg1("ARG"),
                   "eight 1 ARG, localized french")
    XCTAssertEqual(strings.eight.eightArg2("ARG"),
                   "eight 2 ARG, localized french")
    XCTAssertEqual(strings.eight.eightArg3("ARG"),
                   "eightArg3")

    /* nine */
    XCTAssertEqual(strings.nine.nine1(),
                   "nine 1, localized french")
    XCTAssertEqual(strings.nine.nine2(),
                   "nine 2, localized french")
    XCTAssertEqual(strings.nine.nine3(),
                   "nine3")
    XCTAssertEqual(strings.nine.nineArg1("ARG"),
                   "nine 1 ARG, localized french")
    XCTAssertEqual(strings.nine.nineArg2("ARG"),
                   "nine 2 ARG, localized french")
    XCTAssertEqual(strings.nine.nineArg3("ARG"),
                   "nineArg3")

    /* ten */
    XCTAssertEqual(strings.ten.ten1(things: 1),
                   "ten 1 - 1 thing, localized french")
  }


  func testFrenchCanada() {
    let myprefs = ["fr-CA"]

    testPrefferedLanguages(myprefs: myprefs)
    let strings = R.string(preferredLanguages: myprefs)

    /* one */
    XCTAssertEqual(strings.one.one1(),
                   "one 1, not localized")
    XCTAssertEqual(strings.one.one2(),
                   "one 2, not localized")
    XCTAssertEqual(strings.one.oneArg("ARG"),
                   "one ARG, not localized")

    /* two */
    XCTAssertEqual(strings.two.two1(),
                   "two1")
    XCTAssertEqual(strings.two.two2("Hello"),
                   "two2")

    /* three */
    XCTAssertEqual(strings.three.three1(),
                   "three1")
    XCTAssertEqual(strings.three.three2(),
                   "three2")
    XCTAssertEqual(strings.three.three3(),
                   "three3")
    XCTAssertEqual(strings.three.threeArg1("ARG"),
                   "threeArg1")
    XCTAssertEqual(strings.three.threeArg2("ARG"),
                   "threeArg2")
    XCTAssertEqual(strings.three.threeArg3("ARG"),
                   "threeArg3")

    /* four */
    XCTAssertEqual(strings.four.four1(),
                   "four1")
    XCTAssertEqual(strings.four.fourArg("ARG"),
                   "fourArg")

    /* five */
    XCTAssertEqual(strings.five.five1(),
                   "five 1, localized french canada")
    XCTAssertEqual(strings.five.five2(),
                   "five2")
    XCTAssertEqual(strings.five.five4(),
                   "five4")
    XCTAssertEqual(strings.five.fiveArg1("ARG"),
                   "five 1 ARG, localized french canada")
    XCTAssertEqual(strings.five.fiveArg2("ARG"),
                   "fiveArg2")
    XCTAssertEqual(strings.five.fiveArg4("ARG"),
                   "fiveArg4")

    /* six */
    XCTAssertEqual(strings.six.six1(),
                   "six 1, localized french canada")
    XCTAssertEqual(strings.six.six2(),
                   "six2")
    XCTAssertEqual(strings.six.sixArg1("ARG"),
                   "six 1 ARG, localized french canada")
    XCTAssertEqual(strings.six.sixArg2("ARG"),
                   "sixArg2")

    /* seven */
    XCTAssertEqual(strings.seven.seven1(),
                   "seven 1, localized french")
    XCTAssertEqual(strings.seven.seven2(),
                   "seven 2, localized french")
    XCTAssertEqual(strings.seven.seven3(),
                   "seven 3, localized french")
    XCTAssertEqual(strings.seven.seven4(),
                   "seven 4, localized french")
    XCTAssertEqual(strings.seven.sevenArg1("ARG"),
                   "seven 1 ARG, localized french")
    XCTAssertEqual(strings.seven.sevenArg2("ARG"),
                   "seven 2 ARG, localized french")
    XCTAssertEqual(strings.seven.sevenArg3("ARG"),
                   "seven 3 ARG, localized french")
    XCTAssertEqual(strings.seven.sevenArg4("ARG"),
                   "seven 4 ARG, localized french")

    /* eight */
    XCTAssertEqual(strings.eight.eight1(),
                   "eight 1, localized base")
    XCTAssertEqual(strings.eight.eight2(),
                   "eight 2, localized base")
    XCTAssertEqual(strings.eight.eight3(),
                   "eight 3, localized base")
    XCTAssertEqual(strings.eight.eightArg1("ARG"),
                   "eight 1 ARG, localized base")
    XCTAssertEqual(strings.eight.eightArg2("ARG"),
                   "eight 2 ARG, localized base")
    XCTAssertEqual(strings.eight.eightArg3("ARG"),
                   "eight 3 ARG, localized base")

    /* nine */
    XCTAssertEqual(strings.nine.nine1(),
                   "nine 1, localized base")
    XCTAssertEqual(strings.nine.nine2(),
                   "nine 2, localized base")
    XCTAssertEqual(strings.nine.nine3(),
                   "nine 3, localized base")
    XCTAssertEqual(strings.nine.nineArg1("ARG"),
                   "nine 1 ARG, localized base")
    XCTAssertEqual(strings.nine.nineArg2("ARG"),
                   "nine 2 ARG, localized base")
    XCTAssertEqual(strings.nine.nineArg3("ARG"),
                   "nine 3 ARG, localized base")

    /* ten */
    XCTAssertEqual(strings.ten.ten1(things: 1),
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
