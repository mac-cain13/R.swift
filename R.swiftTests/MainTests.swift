//
//  MainTests.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 28-09-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import XCTest

class MainTests: XCTestCase {
    
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  let swiftNameData = [
    "easy": "easy",
    "easyAndSimple": "easyAndSimple",
    "easy with some spaces": "easyWithSomeSpaces",
    "(looks) easy": "looksEasy",
    "looks-easy": "looksEasy",
    "looks+like^some-kind*of%easy": "looksLikeSomeKindOfEasy",
    "(looks) easy, but it's not really NeXT that easy!": "looksEasyButItSNotReallyNeXTThatEasy",
    "easy 123 and done...": "easy123AndDone",
    "123 easy!": "easy",
    "123 456easy": "easy",
    "123 😄": "😄",
    "🇳🇱": "🇳🇱",
    "🌂MakeItRain!": "🌂MakeItRain",
  ]
  
  func testSwiftNameSanitization() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.

    swiftNameData.forEach {
      let sanitizedResult = SwiftIdentifier(name: $0.0, lowercaseFirstCharacter: true).description
      XCTAssertEqual(sanitizedResult, $0.1)
    }
  }
  
  func testPerformanceSwiftNameSanitization() {
    // This is an example of a performance test case.
    self.measureBlock {
      (0...1000).forEach { _ in
        let _ = SwiftIdentifier(name: "(looks) easy, but it's not reallY that easy!", lowercaseFirstCharacter: true)
      }
    }
  }
    
}
