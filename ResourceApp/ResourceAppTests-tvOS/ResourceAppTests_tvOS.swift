//
//  ResourceAppTests_tvOS.swift
//  ResourceAppTests-tvOS
//
//  Created by Carl Hill-Popper on 3/24/16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

@testable import ResourceApp_tvOS
import XCTest

class ResourceAppTests_tvOS: XCTestCase {
  
  func testNonNilImages() {
    XCTAssertNotNil(R.image.imageStackAsset())
  }
  
}
