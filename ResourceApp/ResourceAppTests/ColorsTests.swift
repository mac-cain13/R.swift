//
//  ColorsTests.swift
//  ResourceApp
//
//  Created by Tom Lokhorst on 2016-03-14.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation
import XCTest
@testable import ResourceApp

class ColorsTests: XCTestCase {

  func testNoNilColors() {
    XCTAssertNotNil(R.color.myRSwiftColors.allIsAOK())
    XCTAssertNotNil(R.color.myRSwiftColors.black())
    XCTAssertNotNil(R.color.myRSwiftColors.severeError())
  }

}
