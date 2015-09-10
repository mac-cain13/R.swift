//
//  NibTests.swift
//  ResourceApp
//
//  Created by Mathijs Kadijk on 27-08-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import UIKit
import XCTest
@testable import ResourceApp

class NibTests: XCTestCase {

  func testNibName() {
    XCTAssertEqual(R.nib.myView.name, "My View")
  }

}
