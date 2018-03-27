//
//  ResourceBundleAppTests.swift
//  ResourceBundleAppTests
//
//  Created by Sven Driemecker on 27.03.18.
//  Copyright © 2018 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import ResourceBundleApp

class ResourceBundleAppTests: XCTestCase {
    
    func testThatMainStoryboardCanBeLoaded() {
      let storyboard = R.storyboard.main
      XCTAssertNotNil(storyboard)

      let firstViewController = storyboard.instantiateInitialViewController()
      XCTAssertNotNil(firstViewController)
  }
}
