//
//  StringsTableParserTests.swift
//  Rswift
//
//  Created by Mathijs Bernson on 06/02/2025.
//

import Foundation
import Testing
@testable import RswiftResources
@testable import RswiftParsers

struct StringsTableParserTests {
    @Test func testParsingStringsFile() throws {
        let url = try #require(Bundle.module.url(forResource: "StringsFile", withExtension: "strings", subdirectory: "TestData"))
        let table = try StringsTable.parse(url: url)
        #expect(table.locale == .none)

        let hello = try #require(table.dictionary["hello-world"])
        #expect(hello.originalValue == "Hello World")
        #expect(hello.params.count == 0)

        let things = try #require(table.dictionary["number_of_things"])
        #expect(things.originalValue == "%d things")
        #expect(things.params.count == 1)
        #expect(things.params.first?.name == nil)
        #expect(things.params.first?.spec == .int)
    }

    @Test func testParsingStringCatalog() throws {
        let url = try #require(Bundle.module.url(forResource: "StringCatalog", withExtension: "xcstrings", subdirectory: "TestData"))
        let table = try StringsTable.parse(url: url)
        #expect(table.locale == .language("en"))

        let things = try #require(table.dictionary["number_of_things"])
        #expect(things.originalValue == "%d thing")
        #expect(things.params.count == 1)
        #expect(things.params.first?.name == nil)
        #expect(things.params.first?.spec == .int)
    }
}
