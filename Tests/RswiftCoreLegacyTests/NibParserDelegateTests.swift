//
//  NibParserTests.swift
//  RswiftCoreTests
//
//  Created by Rafael Nobre on 04/07/18.
//

import XCTest
@testable import RswiftCoreLegacy

class NibParserTests: XCTestCase {

    let nibContents = """
    <?xml version="1.0" encoding="UTF-8"?>
    <document type="com.apple.InterfaceBuilder3.CocoaTouch.XIB" version="3.0" toolsVersion="14269.14" targetRuntime="iOS.CocoaTouch" propertyAccessControl="none" useAutolayout="YES" useTraitCollections="YES" useSafeAreas="YES" colorMatched="YES">
        <device id="retina4_7" orientation="portrait">
            <adaptation id="fullscreen"/>
        </device>
        <dependencies>
            <plugIn identifier="com.apple.InterfaceBuilder.IBCocoaTouchPlugin" version="14252.5"/>
            <capability name="documents saved in the Xcode 8 format" minToolsVersion="8.0"/>
        </dependencies>
        <objects>
            <placeholder placeholderIdentifier="IBFilesOwner" id="-1" userLabel="File's Owner"/>
            <placeholder placeholderIdentifier="IBFirstResponder" id="-2" customClass="UIResponder"/>
            <tableViewCell clipsSubviews="YES" contentMode="scaleToFill" preservesSuperviewLayoutMargins="YES" selectionStyle="default" indentationWidth="10" reuseIdentifier="myCellIdentifier" rowHeight="200" id="ypE-6P-i0e" customClass="MyCell" customModule="MyTest" customModuleProvider="target">
                <rect key="frame" x="0.0" y="0.0" width="375" height="200"/>
                <autoresizingMask key="autoresizingMask"/>
                <tableViewCellContentView key="contentView" opaque="NO" clipsSubviews="YES" multipleTouchEnabled="YES" contentMode="center" preservesSuperviewLayoutMargins="YES" insetsLayoutMarginsFromSafeArea="NO" tableViewCell="ypE-6P-i0e" id="aZO-BP-7IV">
                    <rect key="frame" x="0.0" y="0.0" width="375" height="199.5"/>
                    <autoresizingMask key="autoresizingMask"/>
                    <subviews>
                        <view contentMode="scaleToFill" translatesAutoresizingMaskIntoConstraints="NO" id="Dtl-UW-NDc">
                            <rect key="frame" x="0.0" y="0.0" width="4" height="199.5"/>
                            <color key="backgroundColor" red="1" green="0.24504831199999999" blue="0.18311663910000001" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
                            <constraints>
                                <constraint firstAttribute="width" constant="4" id="Ky9-3Q-fhB"/>
                            </constraints>
                        </view>
                    </subviews>
                    <constraints>
                        <constraint firstAttribute="bottom" secondItem="Dtl-UW-NDc" secondAttribute="bottom" id="9xG-7x-lbh"/>
                        <constraint firstAttribute="trailing" relation="greaterThanOrEqual" secondItem="Dtl-UW-NDc" secondAttribute="trailing" id="i4D-F1-HfE"/>
                        <constraint firstItem="Dtl-UW-NDc" firstAttribute="leading" secondItem="aZO-BP-7IV" secondAttribute="leading" id="noH-OA-aot"/>
                        <constraint firstItem="Dtl-UW-NDc" firstAttribute="top" secondItem="aZO-BP-7IV" secondAttribute="top" id="ziA-27-u51"/>
                    </constraints>
                </tableViewCellContentView>
                <connections>
                    <outlet property="signalView" destination="Dtl-UW-NDc" id="Tmc-Ei-6cd"/>
                </connections>
                <point key="canvasLocation" x="-14.5" y="-160"/>
            </tableViewCell>
        </objects>
    </document>

    """
  
    func testTopLevelObjectsAreNotAffectedByColorTags() {
        guard let data = nibContents.data(using: String.Encoding.utf8) else {
            return XCTFail("Unable to create nibContents")
        }
      
        let parser = XMLParser(data: data)
      
        let parserDelegate = NibParserDelegate()
        parser.delegate = parserDelegate
      
        guard parser.parse() else {
          return XCTFail("Invalid XML")
        }
        
        XCTAssert(parserDelegate.rootViews.count == 1)
        XCTAssert(parserDelegate.reusables.count == 1)
    }

    func testRootViewTypeIsCorrectlyExposed() {
        guard let data = nibContents.data(using: String.Encoding.utf8) else {
            return XCTFail("Unable to create nibContents")
        }
        
        let parser = XMLParser(data: data)
        
        let parserDelegate = NibParserDelegate()
        parser.delegate = parserDelegate
        
        guard parser.parse() else {
            return XCTFail("Invalid XML")
        }
        
        XCTAssert(parserDelegate.rootViews.first != Type._UIView)
    }
}
