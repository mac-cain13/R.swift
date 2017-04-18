//
//  ColorsTests.swift
//  ResourceApp
//
//  Created by Tom Lokhorst on 2016-03-14.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation
import XCTest
@testable import ResourceApp

class ColorsTests: XCTestCase {

  func testNoNilColors() {
    XCTAssertNotNil(R.color.myRSwiftColors.allIsAOK())
    XCTAssertNotNil(R.color.myRSwiftColors.severeError())
    XCTAssertNotNil(R.color.myRSwiftColors.seeThroughGray)
    XCTAssertNotNil(R.color.displayP3.red())
    XCTAssertNotNil(R.color.displayP3.green())
  }
  
  func testDisplayP3Colors() {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    R.color.displayP3.red().getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    XCTAssertTrue(round(red * 255) == 255)
    XCTAssertTrue(round(green * 255) == 0)
    XCTAssertTrue(round(blue * 255) == 0)
    XCTAssertTrue(round(alpha * 255) == 255)
    
    R.color.displayP3.green().getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    XCTAssertTrue(round(red * 255) == 0)
    XCTAssertTrue(round(green * 255) == 255)
    XCTAssertTrue(round(blue * 255) == 0)
    XCTAssertTrue(round(alpha * 255) == 255)
  }

}
