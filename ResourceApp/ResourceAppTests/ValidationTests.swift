//
//  ValidationTests.swift
//  ResourceAppTests
//
//  Created by Mathijs Kadijk on 20-07-15.
//  Copyright (c) 2015 Mathijs Kadijk. All rights reserved.
//

import UIKit
import XCTest
import Rswift
@testable import ResourceApp

class ValidationTests: XCTestCase {
  
  func testRunGlobalValidateMethod() {
    do {
      try R.validate()
      XCTFail("No error thrown")
    } catch let error as ValidationError {
      XCTAssertEqual(error.description, "[R.swift] Image named 'First' is used in storyboard 'Secondary', but couldn't be loaded.")
    } catch {
      XCTFail("Wrong error thrown")
    }
  }

  func testRunSpecificValidateMethods() {
    do {
      try R.storyboard.main.validate()
    } catch {
      XCTFail("Wrong error thrown")
    }

    do {
      try R.storyboard.secondary.validate()
      XCTFail("No error thrown")
    } catch let error as ValidationError {
      XCTAssertEqual(error.description, "[R.swift] Image named 'First' is used in storyboard 'Secondary', but couldn't be loaded.")
    } catch {
      XCTFail("Wrong error thrown")
    }
  }

}
