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
    XCTAssertNotNil(R.clr.myRSwiftColors.allIsAOK())
    XCTAssertNotNil(R.clr.myRSwiftColors.severeError())
    XCTAssertNotNil(R.clr.myRSwiftColors.seeThroughGray)
  }

}
