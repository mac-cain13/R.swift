//
//  AppTests.swift
//  AppTests
//
//  Created by Tom Lokhorst on 2022-11-10.
//

import XCTest
@testable import Foo
@testable import Bar

final class AppTests: XCTestCase {

    func testNotNil() throws {
        let fooBundle = Bundle.main.path(forResource: "Foo", ofType: "bundle").flatMap(Bundle.init(path:))!
        let barBundle = Bundle.main.path(forResource: "Bar", ofType: "bundle").flatMap(Bundle.init(path:))!

        let fooR = Foo._R(bundle: fooBundle)
        let barR = Bar._R(bundle: barBundle)

        XCTAssertNotNil(UIImage(resource: fooR.image.user))
        XCTAssertNotNil(UIImage(resource: barR.image.colorsJpg))
    }

}
