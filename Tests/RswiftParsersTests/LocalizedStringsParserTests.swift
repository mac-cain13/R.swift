//
//  File.swift
//  
//
//  Created by Mathijs on 14/07/2021.
//

import XCTest
@testable import RswiftParsers

class LocalizedStringsParserTests: XCTestCase {

    func testLocalizedStringsParser() throws {
        let stringsParser = LocalizedStringsParser()
        let strings = try stringsParser.parse(url: Bundle.module.url(forResource: "Localizable", withExtension: "strings")!)
        XCTAssertEqual(strings.filename, "Localizable.strings")
    }

}
