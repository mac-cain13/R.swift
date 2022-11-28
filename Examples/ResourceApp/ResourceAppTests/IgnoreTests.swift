//
//  IgnoreTests.swift
//  ResourceAppTests
//
//  Created by Mathijs Kadijk on 15-06-18.
//  Copyright © 2018 Mathijs Kadijk. All rights reserved.
//

import Foundation
import XCTest
import RswiftResources
@testable import ResourceApp

class IgnoreTests: XCTestCase {
  func testExplicitInclude() {
    XCTAssertNotNil(R.image.keepDontIgnoreme())
  }
}
