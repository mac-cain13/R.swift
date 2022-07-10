//
//  Nib.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation
import RswiftResources


extension Nib: SupportedExtensions {
    static public let supportedExtensions: Set<String> = ["xib"]

    static public func parse(url: URL) throws -> Nib {
        guard let basename = url.filenameWithoutExtension else {
            throw ResourceParsingError("Couldn't extract filename from URL: \(url)")
        }

        guard let parser = XMLParser(contentsOf: url) else {
            throw ResourceParsingError("Couldn't load file at: '\(url)'")
        }

        let parserDelegate = NibParserDelegate()
        parser.delegate = parserDelegate

        guard parser.parse() else {
            throw ResourceParsingError("Invalid XML in file at: '\(url)'")
        }

        return Nib(
            name: basename,
            deploymentTarget: parserDelegate.deploymentTarget,
            rootViews: parserDelegate.rootViews,
            reusables: parserDelegate.reusables,
            usedImageIdentifiers: parserDelegate.usedImageIdentifiers,
            usedColorResources: parserDelegate.usedColorReferences,
            usedAccessibilityIdentifiers: parserDelegate.usedAccessibilityIdentifiers
        )
    }
}

private let ElementNameToTypeMapping = [
    // TODO: Should contain all standard view elements, like button -> UIButton, view -> UIView etc
    "view": TypeReference._UIView,
    "tableViewCell": TypeReference._UITableViewCell,
    "collectionViewCell": TypeReference._UICollectionViewCell,
    "collectionReusableView": TypeReference._UICollectionReusableView
]

private class NibParserDelegate: NSObject, XMLParserDelegate {
    let ignoredRootViewElements = ["placeholder"]
    var deploymentTarget: DeploymentTarget?
    var rootViews: [TypeReference] = []
    var reusables: [Reusable] = []
    var usedImageIdentifiers: [NameCatalog] = []
    var usedColorReferences: [NameCatalog] = []
    var usedAccessibilityIdentifiers: [String] = []

    // State
    var isObjectsTagOpened = false;
    var levelSinceObjectsTagOpened = 0;

    @objc func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if isObjectsTagOpened {
            levelSinceObjectsTagOpened += 1
        }
        if elementName == "objects" {
            isObjectsTagOpened = true
        }

        switch elementName {
        case "deployment":
            let version = attributeDict["version"]
            if let platform = attributeDict["identifier"] {
                deploymentTarget = DeploymentTarget(version: version.flatMap(parseDeploymentTargetVersion(_:)), platform: platform)
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

        default:
            if let rootView = viewWithAttributes(attributeDict, elementName: elementName),
               levelSinceObjectsTagOpened == 1 && ignoredRootViewElements.allSatisfy({ $0 != elementName }) {
                rootViews.append(rootView)
            }
            if let reusable = reusableFromAttributes(attributeDict, elementName: elementName) {
                reusables.append(reusable)
            }
        }
    }

    @objc func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "objects":
            isObjectsTagOpened = false;

        default:
            if isObjectsTagOpened {
                levelSinceObjectsTagOpened -= 1
            }
        }
    }

    func viewWithAttributes(_ attributeDict: [String : String], elementName: String) -> TypeReference? {
        let customModuleProvider = attributeDict["customModuleProvider"]
        let customModule = (customModuleProvider == "target") ? nil : attributeDict["customModule"]
        let customClass = attributeDict["customClass"]
        let customType = customClass
            .map { TypeReference(module: ModuleReference(name: customModule), rawName: $0) }

        return customType ?? ElementNameToTypeMapping[elementName] ?? TypeReference._UIView
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

func parseDeploymentTargetVersion(_ str: String) -> DeploymentTarget.Version? {
    guard str.count > 2 else { return nil }
    guard let i = Int(str) else { return nil }
    let s = String(i, radix: 16)
    guard
        let major = Int(s[..<s.index(s.endIndex, offsetBy: -2)]),
        let minor = Int(s[s.index(s.endIndex, offsetBy: -2)..<s.index(s.endIndex, offsetBy: -1)])
    else {
        return nil
    }

    return (major, minor)
}
