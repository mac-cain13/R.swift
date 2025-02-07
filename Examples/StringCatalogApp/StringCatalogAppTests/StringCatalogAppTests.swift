//
//  StringCatalogAppTests.swift
//  StringCatalogAppTests
//
//  Created by Mathijs Bernson on 06/02/2025.
//

import Foundation
import Testing
@testable import StringCatalogApp

struct StringCatalogAppTests {

    @Test func testBasicStringCatalog() {
        #expect(R.string.basic.helloWorld() ==
                String(localized: "hello.world", table: "Basic"))
    }

    @Test func testFullStringCatalog() {
        #expect(R.string.full.automatic() ==
                String(localized: "automatic", table: "Full"))

        // String with plural based on one parameter (%d)
        #expect(R.string.full.number_of_things(1) == "1 thing")
        #expect(R.string.full.number_of_things(2) == "2 things")
        #expect(R.string.full.number_of_things(1) ==
                String(format: String(localized: "number_of_things", table: "Full"), 1))
        #expect(R.string.full.number_of_things(3) ==
                String(format: String(localized: "number_of_things", table: "Full"), 3))

        // String varied by device
        #expect(R.string.full.proceed_label() == "Proceed on your iPhone")
    }

}
