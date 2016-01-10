//
//  FilesTests.swift
//  ResourceApp
//
//  Created by Mathijs Kadijk on 25-09-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import UIKit
import XCTest
@testable import ResourceApp

class FilesTests: XCTestCase {

  func testNoNilResourceFiles() {
    XCTAssertNotNil(R.file.someJson() as NSURL?)
    XCTAssertNotNil(R.file.someJson() as String?)
  }
}
