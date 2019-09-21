//
//  InfoPlistTests.swift
//  ResourceAppTests
//
//  Created by Tom Lokhorst on 2019-09-20.
//  Copyright © 2019 Mathijs Kadijk. All rights reserved.
//

import UIKit
import XCTest
@testable import ResourceApp

class InfoPlistTests: XCTestCase {

  func testUserActivityTypes() {
    XCTAssertNotNil(R.info.nsUserActivityTypes.planTripIntent)
  }

  func testVariable() {
//    let x = (Bundle.main.object(forInfoDictionaryKey: "NSExtension") as? [String: Any])?["NSExtensionPrincipalClass"] as? String
    XCTAssertEqual(R.info.nsExtension.nsExtensionPrincipalClass, "ResourceApp.IntentHandler")
  }
}

//<key>NSExtension</key>
//<dict>
//  <key>NSExtensionAttributes</key>
//  <dict>
//    <key>IntentsRestrictedWhileLocked</key>
//    <array/>
//    <key>IntentsRestrictedWhileProtectedDataUnavailable</key>
//    <array/>
//    <key>IntentsSupported</key>
//    <array>
//      <string>PlanTripIntent</string>
//      <string>ShowDeparturesIntent</string>
//    </array>
//  </dict>
//  <key>NSExtensionPointIdentifier</key>
//  <string>com.apple.intents-service</string>
//  <key>NSExtensionPrincipalClass</key>
//  <string>$(PRODUCT_MODULE_NAME).IntentHandler</string>
//</dict>
