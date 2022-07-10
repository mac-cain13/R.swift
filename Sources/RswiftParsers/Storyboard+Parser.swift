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


extension Storyboard: SupportedExtensions {
    static public let supportedExtensions: Set<String> = ["storyboard"]
    
    static public func parse(url: URL) throws -> Storyboard {
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

        return Storyboard(
            name: basename,
            locale: locale,
            deploymentTarget: parserDelegate.deploymentTarget,
            initialViewControllerIdentifier: parserDelegate.initialViewControllerIdentifier,
            viewControllers: parserDelegate.viewControllers,
            viewControllerPlaceholders: parserDelegate.viewControllerPlaceholders,
            usedAccessibilityIdentifiers: parserDelegate.usedAccessibilityIdentifiers,
            usedImageIdentifiers: parserDelegate.usedImageIdentifiers,
            usedColorResources: parserDelegate.usedColorReferences,
            reusables: parserDelegate.reusables
        )
    }
}

private let ElementNameToTypeMapping: [String: TypeReference] = [
    "viewController": TypeReference._UIViewController,
    "tableViewCell": TypeReference(module: .uiKit, rawName: "UITableViewCell"),
    "tabBarController": TypeReference(module: .uiKit, rawName: "UITabBarController"),
    "glkViewController": TypeReference(module: .custom(name: "GLKit"), rawName: "GLKViewController"),
    "hostingController": TypeReference(module: .custom(name: "SwiftUI"), rawName: "UIHostingController"),
    "pageViewController": TypeReference(module: .uiKit, rawName: "UIPageViewController"),
    "tableViewController": TypeReference(module: .uiKit, rawName: "UITableViewController"),
    "splitViewController": TypeReference(module: .uiKit, rawName: "UISplitViewController"),
    "navigationController": TypeReference(module: .uiKit, rawName: "UINavigationController"),
    "avPlayerViewController": TypeReference(module: .custom(name: "AVKit"), rawName: "AVPlayerViewController"),
    "collectionViewController": TypeReference(module: .uiKit, rawName: "UICollectionViewController"),
    "lookAroundViewController": TypeReference(module: .custom(name: "MapKit"), rawName: "MKLookAroundViewController"),
]

private class StoryboardParserDelegate: NSObject, XMLParserDelegate {
    var initialViewControllerIdentifier: String?
    var deploymentTarget: DeploymentTarget?
    var viewControllers: [Storyboard.ViewController] = []
    var viewControllerPlaceholders: [Storyboard.ViewControllerPlaceholder] = []
    var usedImageIdentifiers: [NameCatalog] = []
    var usedColorReferences: [NameCatalog] = []
    var usedAccessibilityIdentifiers: [String] = []
    var reusables: [Reusable] = []

    // State
    var currentViewController: Storyboard.ViewController?

    @objc func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
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
                let type = customType ?? TypeReference._UIStoryboardSegue

                let segue = Storyboard.Segue(identifier: segueIdentifier, type: type, destination: destination, kind: kind)
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
                let placeholder = Storyboard.ViewControllerPlaceholder(
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

    func viewControllerFromAttributes(_ attributeDict: [String : String], elementName: String) -> Storyboard.ViewController? {
        guard let id = attributeDict["id"] , attributeDict["sceneMemberID"] == "viewController" else {
            return nil
        }

        let storyboardIdentifier = attributeDict["storyboardIdentifier"]

        let customModuleProvider = attributeDict["customModuleProvider"]
        let customModule = (customModuleProvider == "target") ? nil : attributeDict["customModule"]
        let customClass = attributeDict["customClass"]
        let customType = customClass
            .map { TypeReference(module: ModuleReference(name: customModule), rawName: $0) }

        let type = customType ?? ElementNameToTypeMapping[elementName] ?? TypeReference._UIViewController

        return Storyboard.ViewController(id: id, storyboardIdentifier: storyboardIdentifier, type: type, segues: [])
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

        let type = customType ?? ElementNameToTypeMapping[elementName] ?? TypeReference._UIView

        return Reusable(identifier: reuseIdentifier, type: type)
    }
}

