//
//  FontsTests.swift
//  ResourceApp
//
//  Created by Mathijs Kadijk on 26-08-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import UIKit
import XCTest
import RswiftResources
@testable import ResourceApp

class FontsTests: XCTestCase {

  func testNoNilFonts() {
    XCTAssertNotNil(R.font.averiaLibreBold(size: 10))
    XCTAssertNotNil(R.font.averiaLibreBoldItalic(size: 20))
    XCTAssertNotNil(R.font.averiaLibreLight(size: 30))
    XCTAssertNotNil(R.font.averiaLibreRegular(size: 40))
    XCTAssertNotNil(R.font.goudyBookletter1911(size: 50))
  }

  func testNoValidationError() {
    XCTAssertNoThrow(try R.font.validate())
  }

  func testAllFonts() {
    XCTAssertEqual(Array(R.font.map(\.name)), ["AveriaLibre-Bold", "AveriaLibre-BoldItalic", "AveriaLibre-Light", "AveriaLibre-Regular", "GoudyBookletter1911"])
  }
}
