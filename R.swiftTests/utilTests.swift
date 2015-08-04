//
//  utilTests.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 04-08-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import XCTest

class utilTests: XCTestCase {

  func testCatOptionals() {
    let testSets: [(input: [Int?], output: [Int])] = [
      ([], []),
      ([1, 2, 3], [1, 2, 3]),
      ([1, nil, 2, 3], [1, 2, 3]),
      ([nil, nil], []),
    ]

    testSets.each {
      XCTAssertEqual(catOptionals($0.input), $0.output)
    }
  }

  func testList() {
    let testSets: [(input: Int?, output: [Int])] = [
      (nil, []),
      (1, [1])
    ]

    testSets.each {
      XCTAssertEqual(list($0.input), $0.output)
    }
  }

  func testFlatten() {
    let testSets: [(input: [[Int]], output: [Int])] = [
      ([], []),
      ([[]], []),
      ([[1,2,3]], [1,2,3]),
      ([[1],[2,3]], [1,2,3]),
      ([[1],[2],[3]], [1,2,3]),
    ]

    testSets.each {
      XCTAssertEqual(flatten($0.input), $0.output)
    }
  }

}
