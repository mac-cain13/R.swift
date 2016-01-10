//
//  StoryboardTests.swift
//  ResourceApp
//
//  Created by Mathijs Kadijk on 10-01-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import ResourceApp

class StoryboardTests: XCTestCase {

  func testStoryboardNames() {
    XCTAssertEqual(R.storyboard.main.name, "Main")
    XCTAssertEqual(R.storyboard.secondary.name, "Secondary")
    XCTAssertEqual(R.storyboard.specials.name, "Specials")
  }

  func testStoryboardInitialViewControllers() {
    XCTAssertNotNil(R.storyboard.main.initialViewController(), "Initial view controller is missing")
    XCTAssertNotNil(R.storyboard.secondary.initialViewController(), "Initial view controller is missing")
  }

  func testStoryboardSpecificViewControllers() {
    XCTAssertNotNil(R.storyboard.main.thirdViewController(), "Specific view controller is missing")
    XCTAssertNotNil(R.storyboard.specials.glkVC(), "Specific view controller is missing")
  }
}
