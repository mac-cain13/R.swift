//
//  File.swift
//  
//
//  Created by Mathijs on 14/07/2021.
//

import XCTest
@testable import RswiftParsers
import RswiftResources

class AssetFolderParserTests: XCTestCase {

    func testAssetCatalogParser() throws {
        let assetFolderParser = AssetFolderParser()
        let assetFolder = try assetFolderParser.parse(url: Bundle.module.url(forResource: "Media", withExtension: "xcassets", subdirectory: "Fixtures")!)
        XCTAssertEqual(assetFolder.name, "Media.xcassets")
        XCTAssertEqual(assetFolder.colorAssets.map(\.lastPathComponent), ["TestColor.colorset"])
        XCTAssertEqual(assetFolder.imageAssets.map(\.lastPathComponent), ["TestImage.imageset"])
//        XCTAssertEqual(assetFolder.subfolders.count, 2)
//        guard assetFolder.subfolders.indices.contains(0) else { XCTFail(); return }
//        let subfolder = assetFolder.subfolders[0]
//        XCTAssertEqual(subfolder.name, "Subfolder1")
//        XCTAssertEqual(assetFolder.subfolders.colorAssets.map(\.lastPathComponent), ["TestColor.colorset"])
    }

}
