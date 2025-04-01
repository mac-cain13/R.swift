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

        // Regular string
        let helloWorld = try #require(table.dictionary["hello-world"])
        #expect(helloWorld.originalValue == "Hello World")

        // Automatically extracted string
        let automatic = try #require(table.dictionary["automatic"])
        #expect(automatic.originalValue == "Automatic")

        // Untranslatable string
        #expect(table.dictionary["name"] == nil)

        // Plural string (vary by plural)
        let things = try #require(table.dictionary["number_of_things"])
        #expect(things.originalValue == "%d thing")
        #expect(things.params.count == 1)
        #expect(things.params.first?.name == nil)
        #expect(things.params.first?.spec == .int)

        // Device specific string (vary by device)
        let device = try #require(table.dictionary["proceed_label"])
        #expect(device.originalValue == "Proceed on your device")

        // String only translated in another language (should be ignored)
        #expect(table.dictionary["dutch-only"] == nil)
    }
}
