//
//  ImagesTests.swift
//  ResourceAppTests
//
//  Created by Mathijs Kadijk on 20-07-15.
//  Copyright (c) 2015 Mathijs Kadijk. All rights reserved.
//

import UIKit
import XCTest
@testable import ResourceApp

class ImagesTests: XCTestCase {
  
  func testNoNilImages() {
    XCTAssertNil(R.image.appIcon) // AppIcon is not available with "imageNamed"
    XCTAssertNotNil(R.image.eerste)
    XCTAssertNotNil(R.image.first)
    XCTAssertNotNil(R.image.firstNested)
    XCTAssertNotNil(R.image.secondNested)
  }

}
