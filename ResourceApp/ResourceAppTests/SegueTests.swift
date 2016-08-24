//
//  SegueTests.swift
//  ResourceApp
//
//  Created by Tom Lokhorst on 2016-08-08.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import ResourceApp

class SegueTests: XCTestCase {

  func testSegueNames() {
    XCTAssertEqual(R.segue.firstViewController.toSomeStoryboard.identifier, "toSomeStoryboard")
    XCTAssertEqual(R.segue.secondViewController.attachedSegue.identifier, "attachedSegue")
    XCTAssertEqual(R.segue.secondViewController.recognizerSegue.identifier, "recognizerSegue")
    XCTAssertEqual(R.segue.secondViewController.toThird.identifier, "toThird")
  }
}
