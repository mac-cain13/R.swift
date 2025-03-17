//
//  StringCatalogDecodingTests.swift
//  Rswift
//
//  Created by Mathijs Bernson on 15/01/2025.
//

import Foundation
import Testing
@testable import RswiftResources
@testable import RswiftParsers

struct StringCatalogDecodingTests {
    let decoder = JSONDecoder()

    @Test func testDecodingStringCatalog() throws {
        let url = try #require(Bundle.module.url(forResource: "StringCatalog", withExtension: "xcstrings", subdirectory: "TestData"))
        do {
            let data = try Data(contentsOf: url)
            let stringCatalog = try decoder.decode(StringCatalog.self, from: data)
            #expect(stringCatalog.sourceLanguage == "en")
            #expect(stringCatalog.strings.count == 6)

            // Automatically extracted string
            let automatic = try #require(stringCatalog.strings["automatic"])
            #expect(automatic.localizations["en"]?.stringUnit?.value == "Automatic")
            #expect(automatic.localizations["nl"]?.stringUnit?.value == "Automatisch")

            // Manually managed string
            let manual = try #require(stringCatalog.strings["goodbye-world"])
            #expect(manual.localizations["en"]?.stringUnit?.value == nil)
            #expect(manual.localizations["nl"]?.stringUnit?.value == "Dag Wereld")

            // Untranslatable string
            let untranslated = try #require(stringCatalog.strings["name"])
            #expect(untranslated.localizations["nl"]?.stringUnit?.value == "Mathijs")

            // Plural string (vary by plural)
            let plural = try #require(stringCatalog.strings["number_of_things"])
            let pluralVariations = try #require(plural.localizations["nl"]?.variations?.plural)
            #expect(pluralVariations["one"]?.stringUnit?.value == "%d ding")
            #expect(pluralVariations["other"]?.stringUnit?.value == "%d dingen")

            // Device specific string (vary by device)
            let device = try #require(stringCatalog.strings["proceed_label"])
            let deviceVariations = try #require(device.localizations["en"]?.variations?.device)
            #expect(deviceVariations["iphone"]?.stringUnit?.value == "Proceed on your iPhone")
            #expect(deviceVariations["other"]?.stringUnit?.value == "Proceed on your device")
        } catch {
            Issue.record(error, "String catalog failed to parse")
        }
    }
}
