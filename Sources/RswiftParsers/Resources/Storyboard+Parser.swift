//
//  Storyboard.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation
import RswiftResources


let uikitElementToTypes: [String: TypeReference] = [
    "viewController": TypeReference(module: .uiKit, rawName: "UIViewController"),
    "tableViewCell": TypeReference(module: .uiKit, rawName: "UITableViewCell"),
    "tabBarController": TypeReference(module: .uiKit, rawName: "UITabBarController"),
    "glkViewController": TypeReference(module: .custom(name: "GLKit"), rawName: "GLKViewController"),
    "hostingController": .uiViewController, // TypeReference(module: .custom(name: "SwiftUI"), rawName: "UIHostingController"),
    "pageViewController": TypeReference(module: .uiKit, rawName: "UIPageViewController"),
    "tableViewController": TypeReference(module: .uiKit, rawName: "UITableViewController"),
    "splitViewController": TypeReference(module: .uiKit, rawName: "UISplitViewController"),
    "navigationController": TypeReference(module: .uiKit, rawName: "UINavigationController"),
    "avPlayerViewController": TypeReference(module: .custom(name: "AVKit"), rawName: "AVPlayerViewController"),
    "collectionViewController": TypeReference(module: .uiKit, rawName: "UICollectionViewController"),
    "lookAroundViewController": TypeReference(module: .custom(name: "MapKit"), rawName: "MKLookAroundViewController"),

    "view": TypeReference.uiView,
    "tableViewCell": TypeReference(module: .uiKit, rawName: "UITableViewCell"),
    "collectionViewCell": TypeReference(module: .uiKit, rawName: "UICollectionViewCell"),
    "collectionReusableView": TypeReference(module: .uiKit, rawName: "UICollectionReusableView"),
]

let macosElementTypes: [String: TypeReference] = [
    "viewController": TypeReference(module: .appKit, rawName: "NSViewController"),
    "tabViewController": TypeReference(module: .appKit, rawName: "NSTabViewController"),
    "splitViewController": TypeReference(module: .appKit, rawName: "NSSplitViewController"),
    "hostingController": .nsViewController, // TypeReference(module: .custom(name: "SwiftUI"), rawName: "NSHostingController"),
    "pagecontroller": TypeReference(module: .appKit, rawName: "NSPageController"),
    "windowController": TypeReference(module: .appKit, rawName: "NSWindowController"),
    "lookAroundViewController": TypeReference(module: .custom(name: "MapKit"), rawName: "MKLookAroundViewController"),

    "view": TypeReference.nsView,
    "scrollView": TypeReference(module: .appKit, rawName: "NSScrollView"),
    "tableCellView": TypeReference(module: .appKit, rawName: "NSTableCellView"),
    "collectionViewItem": TypeReference(module: .appKit, rawName: "NSCollectionViewItem"),
]

extension StoryboardResource: SupportedExtensions {
    static public let supportedExtensions: Set<String> = ["storyboard"]
    
    static public func parse(url: URL) throws -> StoryboardResource {
        guard let basename = url.filenameWithoutExtension else {
            throw ResourceParsingError("Couldn't extract filename from URL: \(url)")
        }

        let locale = LocaleReference(url: url)

        guard let parser = XMLParser(contentsOf: url) else {
            throw ResourceParsingError("Couldn't load file at: '\(url)'")
        }

        let parserDelegate = StoryboardParserDelegate()
        parser.delegate = parserDelegate

        guard parser.parse() else {
            throw ResourceParsingError("Invalid XML in file at: '\(url)'")
        }

        return StoryboardResource(
            name: basename,
            locale: locale,
            deploymentTarget: parserDelegate.deploymentTarget,
            initialViewControllerIdentifier: parserDelegate.initialViewControllerIdentifier,
            viewControllers: parserDelegate.viewControllers,
            viewControllerPlaceholders: parserDelegate.viewControllerPlaceholders,
            generatedIds: parserDelegate.generatedIds,
            usedAccessibilityIdentifiers: parserDelegate.usedAccessibilityIdentifiers,
            usedImageIdentifiers: parserDelegate.usedImageIdentifiers,
            usedColorResources: parserDelegate.usedColorReferences,
            reusables: parserDelegate.reusables,
            isAppKit: parserDelegate.isAppKit
        )
    }
}

private class StoryboardParserDelegate: NSObject, XMLParserDelegate {
    var isAppKit = false
    var initialViewControllerIdentifier: String?
    var deploymentTarget: DeploymentTarget?
    var viewControllers: [StoryboardResource.ViewController] = []
    var viewControllerPlaceholders: [StoryboardResource.ViewControllerPlaceholder] = []
    var generatedIds: [String] = []
    var usedImageIdentifiers: [NameCatalog] = []
    var usedColorReferences: [NameCatalog] = []
    var usedAccessibilityIdentifiers: [String] = []
    var reusables: [Reusable] = []

    // State
    var currentViewController: StoryboardResource.ViewController?

    @objc func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if let id = attributeDict["id"], isGenerated(id: id) {
            generatedIds.append(id)
        }

        switch elementName {
        case "deployment":
            let version = attributeDict["version"]
            if let platform = attributeDict["identifier"] {
                deploymentTarget = DeploymentTarget(version: version.flatMap(parseDeploymentTargetVersion(_:)), platform: platform)
            }

        case "document":
            if let initialViewController = attributeDict["initialViewController"] {
                initialViewControllerIdentifier = initialViewController
            }
            isAppKit = attributeDict["targetRuntime"] == "MacOSX.Cocoa"

        case "segue":
            let customModuleProvider = attributeDict["customModuleProvider"]
            let customModule = (customModuleProvider == "target") ? nil : attributeDict["customModule"]
            let customClass = attributeDict["customClass"]
            let customType = customClass
                .map { TypeReference(module: ModuleReference(name: customModule), rawName: $0) }

            if let segueIdentifier = attributeDict["identifier"],
               let destination = attributeDict["destination"],
               let kind = attributeDict["kind"]
            {
                let type = customType ?? (isAppKit ? .nsStoryboardSegue : .uiStoryboardSegue)

                let segue = StoryboardResource.Segue(identifier: segueIdentifier, type: type, destination: destination, kind: kind)
                currentViewController?.segues.append(segue)
            }

        case "image":
            if let imageIdentifier = attributeDict["name"] {
                usedImageIdentifiers.append(NameCatalog(name: imageIdentifier, catalog: attributeDict["catalog"]))
            }

        case "color":
            if let colorName = attributeDict["name"] {
                usedColorReferences.append(NameCatalog(name: colorName, catalog: attributeDict["catalog"]))
            }

        case "accessibility":
            if let accessibilityIdentifier = attributeDict["identifier"] {
                usedAccessibilityIdentifiers.append(accessibilityIdentifier)
            }

        case "userDefinedRuntimeAttribute":
            if let accessibilityIdentifier = attributeDict["value"], "accessibilityIdentifier" == attributeDict["keyPath"] && "string" == attributeDict["type"] {
                usedAccessibilityIdentifiers.append(accessibilityIdentifier)
            }

        case "viewControllerPlaceholder":
            if let id = attributeDict["id"] , attributeDict["sceneMemberID"] == "viewController" {
                let placeholder = StoryboardResource.ViewControllerPlaceholder(
                    id: id,
                    storyboardName: attributeDict["storyboardName"],
                    referencedIdentifier: attributeDict["referencedIdentifier"],
                    bundleIdentifier: attributeDict["bundleIdentifier"]
                )
                viewControllerPlaceholders.append(placeholder)
            }

        default:
            if let viewController = viewControllerFromAttributes(attributeDict, elementName: elementName) {
                currentViewController = viewController
            }

            if let reusable = reusableFromAttributes(attributeDict, elementName: elementName) {
                reusables.append(reusable)
            }
        }
    }
    
    @objc func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        // We keep the current view controller open to collect segues until the closing scene:
        // <scene>
        //   <viewController>
        //     ...
        //     <segue />
        //   </viewController>
        //   <segue />
        // </scene>
        if elementName == "scene" {
            if let currentViewController = currentViewController {
                viewControllers.append(currentViewController)
                self.currentViewController = nil
            }
        }
    }

    func viewControllerFromAttributes(_ attributeDict: [String : String], elementName: String) -> StoryboardResource.ViewController? {
        guard let id = attributeDict["id"] , attributeDict["sceneMemberID"] == "viewController" else {
            return nil
        }

        let storyboardIdentifier = attributeDict["storyboardIdentifier"]

        let customModuleProvider = attributeDict["customModuleProvider"]
        let customModule = (customModuleProvider == "target") ? nil : attributeDict["customModule"]
        let customClass = attributeDict["customClass"]
        let customType = customClass
            .map { TypeReference(module: ModuleReference(name: customModule), rawName: $0) }

        let type = customType ?? (isAppKit ? (macosElementTypes[elementName] ?? .nsViewController) : (uikitElementToTypes[elementName] ?? .uiViewController))

        return StoryboardResource.ViewController(id: id, storyboardIdentifier: storyboardIdentifier, type: type, segues: [])
    }

    func reusableFromAttributes(_ attributeDict: [String : String], elementName: String) -> Reusable? {
        guard let reuseIdentifier = attributeDict["reuseIdentifier"] , reuseIdentifier != "" else {
            return nil
        }

        let customModuleProvider = attributeDict["customModuleProvider"]
        let customModule = (customModuleProvider == "target") ? nil : attributeDict["customModule"]
        let customClass = attributeDict["customClass"]
        let customType = customClass
            .map { TypeReference(module: ModuleReference(name: customModule), rawName: $0) }

        let type = customType ?? (isAppKit ? (macosElementTypes[elementName] ?? .nsView) : (uikitElementToTypes[elementName] ?? .uiView))

        return Reusable(identifier: reuseIdentifier, type: type)
    }
}
