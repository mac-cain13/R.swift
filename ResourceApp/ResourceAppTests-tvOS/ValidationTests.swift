//
//  ValidationTests.swift
//  ResourceAppTests-tvOS
//
//  Created by Mathijs Kadijk on 06/04/2019.
//  Copyright © 2019 Mathijs Kadijk. All rights reserved.
//

import UIKit
import XCTest
@testable import ResourceApp_tvOS

class ValidationTests: XCTestCase {

  func testValidation() throws {
    try R.validate()
  }
}

