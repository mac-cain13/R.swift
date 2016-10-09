//
//  Nib.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

private let ElementNameToTypeMapping = [
  // TODO: Should contain all standard view elements, like button -> UIButton, view -> UIView etc
  "view": Type._UIView,
  "tableViewCell": Type._UITableViewCell,
  "collectionViewCell": Type._UICollectionViewCell,
  "collectionReusableView": Type._UICollectionReusableView
]

struct Nib: WhiteListedExtensionsResourceType, ReusableContainer {
  static let supportedExtensions: Set<String> = ["xib"]

  let name: String
  let rootViews: [Type]
  let reusables: [Reusable]

  init(url: URL) throws {
    try Nib.throwIfUnsupportedExtension(url.pathExtension)

    guard let filename = url.filename else {
      throw ResourceParsingError.parsingFailed("Couldn't extract filename from URL: \(url)")
    }
    name = filename

    guard let parser = XMLParser(contentsOf: url) else {
      throw ResourceParsingError.parsingFailed("Couldn't load file at: '\(url)'")
    }

    let parserDelegate = NibParserDelegate()
    parser.delegate = parserDelegate

    guard parser.parse() else {
        throw ResourceParsingError.parsingFailed("Invalid XML in file at: '\(url)'")
    }

    rootViews = parserDelegate.rootViews
    reusables = parserDelegate.reusables
  }
}

private class NibParserDelegate: NSObject, XMLParserDelegate {
  let ignoredRootViewElements = ["placeholder"]
  var rootViews: [Type] = []
  var reusables: [Reusable] = []

  // State
  var isObjectsTagOpened = false;
  var levelSinceObjectsTagOpened = 0;

  @objc func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
    switch elementName {
    case "objects":
      isObjectsTagOpened = true;

    default:
      if isObjectsTagOpened {
        levelSinceObjectsTagOpened += 1;

        if let rootView = viewWithAttributes(attributeDict, elementName: elementName)
          , levelSinceObjectsTagOpened == 1 && ignoredRootViewElements.filter({ $0 == elementName }).count == 0 {
            rootViews.append(rootView)
        }
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
        levelSinceObjectsTagOpened -= 1;
      }
    }
  }

  func viewWithAttributes(_ attributeDict: [String : String], elementName: String) -> Type? {
    let customModuleProvider = attributeDict["customModuleProvider"]
    let customModule = (customModuleProvider == "target") ? nil : attributeDict["customModule"]
    let customClass = attributeDict["customClass"]
    let customType = customClass
      .map { SwiftIdentifier(name: $0, lowercaseFirstCharacter: false) }
      .map { Type(module: Module(name: customModule), name: $0, optional: false) }

    return customType ?? ElementNameToTypeMapping[elementName] ?? Type._UIView
  }

  func reusableFromAttributes(_ attributeDict: [String : String], elementName: String) -> Reusable? {
    guard let reuseIdentifier = attributeDict["reuseIdentifier"] , reuseIdentifier != "" else {
      return nil
    }

    let customModuleProvider = attributeDict["customModuleProvider"]
    let customModule = (customModuleProvider == "target") ? nil : attributeDict["customModule"]
    let customClass = attributeDict["customClass"]
    let customType = customClass
      .map { SwiftIdentifier(name: $0, lowercaseFirstCharacter: false) }
      .map { Type(module: Module(name: customModule), name: $0, optional: false) }

    let type = customType ?? ElementNameToTypeMapping[elementName] ?? Type._UIView

    return Reusable(identifier: reuseIdentifier, type: type)
  }
}
