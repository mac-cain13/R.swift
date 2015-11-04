//
//  RelationsTests.swift
//  ResourceApp
//
//  Created by Tomas Harkema on 04-11-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import ResourceApp

class RelationsTests: XCTestCase {
  func testTabRelation() {
    let dat = R.storyboard.main.mainTabBarController.instance?.viewController(R.storyboard.main.mainTabBarController.firstViewContollerRelation)
    XCTAssertNotNil(dat)
  }
}
