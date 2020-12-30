//
//  InfoPlistTests.swift
//  ResourceAppTests
//
//  Created by Tom Lokhorst on 2019-09-20.
//  Copyright © 2019 Mathijs Kadijk. All rights reserved.
//

import UIKit
import XCTest
@testable import ResourceApp

class InfoPlistTests: XCTestCase {

  func testUserActivityTypes() {
    XCTAssertNotNil(R.info.nsUserActivityTypes.planTripIntent)
  }

  func testVariable() {
    XCTAssertEqual(R.info.nsExtension.nsExtensionPrincipalClass, "ResourceApp.IntentHandler")
  }
}
