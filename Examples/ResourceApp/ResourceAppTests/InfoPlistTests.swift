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
    XCTAssertEqual(R.info.nsExtension.nsExtensionPrincipalClass, "ResourceApp.IntentHandler")
  }
  
  func testUIApplicationShortcutItems() {
    XCTAssertEqual(R.info.uiApplicationShortcutItems.nlMathijskadijkShortcutsQrScanning.uiApplicationShortcutItemIconFile, "ShortcutQrScanning")
    XCTAssertEqual(R.info.uiApplicationShortcutItems.nlMathijskadijkShortcutsQrScanning.uiApplicationShortcutItemTitle, "Scan QR-code")
    XCTAssertEqual(R.info.uiApplicationShortcutItems.nlMathijskadijkShortcutsQrScanning.uiApplicationShortcutItemType, "nl.mathijskadijk.shortcuts.qr-scanning")
    
    XCTAssertEqual(R.info.uiApplicationShortcutItems.nlMathijskadijkShortcutsSendParcel.uiApplicationShortcutItemIconFile, "ShortcutSendParcel")
    XCTAssertEqual(R.info.uiApplicationShortcutItems.nlMathijskadijkShortcutsSendParcel.uiApplicationShortcutItemTitle, "Send a Parcel")
    XCTAssertEqual(R.info.uiApplicationShortcutItems.nlMathijskadijkShortcutsSendParcel.uiApplicationShortcutItemType, "nl.mathijskadijk.shortcuts.send-parcel")
  }
  
  func testUIApplicationSceneManifest() {
    XCTAssertFalse(R.info.uiApplicationSceneManifest.uiApplicationSupportsMultipleScenes)
    
    XCTAssertEqual(R.info.uiApplicationSceneManifest.uiSceneConfigurations.uiWindowSceneSessionRoleApplication.defaultConfiguration.uiSceneConfigurationName, "Default Configuration")
    XCTAssertEqual(R.info.uiApplicationSceneManifest.uiSceneConfigurations.uiWindowSceneSessionRoleApplication.defaultConfiguration.uiSceneDelegateClassName, "ResourceApp.SceneDelegate")
  }
  
  func testNSUserActivityTypes() {
    XCTAssertEqual(R.info.nsUserActivityTypes.planTripIntent, "PlanTripIntent")
    XCTAssertEqual(R.info.nsUserActivityTypes.showDeparturesIntent, "ShowDeparturesIntent")
  }
  
  func testNSExtension() {
    XCTAssertEqual(R.info.nsExtension.nsExtensionAttributes.intentsSupported.planTripIntent, "PlanTripIntent")
    XCTAssertEqual(R.info.nsExtension.nsExtensionAttributes.intentsSupported.showDeparturesIntent, "ShowDeparturesIntent")
    
    XCTAssertEqual(R.info.nsExtension.nsExtensionPrincipalClass, "ResourceApp.IntentHandler")
    XCTAssertEqual(R.info.nsExtension.nsExtensionPointIdentifier, "com.apple.intents-service")
  }
}
