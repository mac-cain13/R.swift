//
//  MainTests.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 28-09-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import XCTest

class MainTests: XCTestCase {
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
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
    "PRFXMyClass": "prfxMyClass",
    "NSSomeThing": "nsSomeThing",
    "MyClass": "myClass",
    "PRFX_MyClass": "prfx_MyClass",
    "PRFX-myClass": "prfxMyClass",
    "123NSSomeThing": "nsSomeThing",
    "PR123FXMyClass": "pr123FXMyClass"
  ]
  
  func testSwiftNameSanitization() {
    RswiftCore.isEdgeEnabled = true
    
    swiftNameData.forEach {
      let sanitizedResult = SwiftIdentifier(name: $0.0, lowercaseStartingCharacters: true).description
      XCTAssertEqual(sanitizedResult, $0.1)
    }
  }
  
  func testPerformanceSwiftNameSanitization() {
    // This is an example of a performance test case.
    self.measure {
      (0...1000).forEach { _ in
        let _ = SwiftIdentifier(name: "(looks) easy, but it's not reallY that easy!", lowercaseStartingCharacters: true)
      }
    }
  }
    
}
