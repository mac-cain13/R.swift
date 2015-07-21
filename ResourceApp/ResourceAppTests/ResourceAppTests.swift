//
//  ResourceAppTests.swift
//  ResourceAppTests
//
//  Created by Mathijs Kadijk on 20-07-15.
//  Copyright (c) 2015 Mathijs Kadijk. All rights reserved.
//

import UIKit
import XCTest
import ResourceApp

class ResourceAppTests: XCTestCase {
  
  func testRunGlobalValidateMethod() {
    R.validate()
  }

  func testRunSpecificValidateMethods() {
    R.storyboard.main.validateImages()
    R.storyboard.main.validateViewControllers()
  }

}
