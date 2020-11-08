//
//  ImagesTests.swift
//  ResourceAppTests-tvOS
//
//  Created by Mathijs Kadijk on 20-07-15.
//  Copyright (c) 2015 Mathijs Kadijk. All rights reserved.
//
import UIKit
import XCTest
@testable import ResourceApp_tvOS

class ImagesTests: XCTestCase {

  func testNonNilImages() throws {
    XCTAssertNotNil(R.image.imageStackAsset())
  }
}
