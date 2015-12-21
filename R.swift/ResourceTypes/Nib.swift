//
//  Nib.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

private let ElementNameToTypeMapping = [
  // TODO: Should contain all standard view elements, like button -> UIButton, view -> UIView etc
  "view": Type._UIView,
  "tableViewCell": Type._UITableViewCell,
  "collectionViewCell": Type._UICollectionViewCell,
]

struct Nib: WhiteListedExtensionsResourceType, ReusableContainer {
  static let supportedExtensions: Set<String> = ["xib"]

  let name: String
  let rootViews: [Type]
  let reusables: [Reusable]

  init(url: NSURL) throws {
    try Nib.throwIfUnsupportedExtension(url.pathExtension)

    name = url.filename!

    let parserDelegate = NibParserDelegate();

    let parser = NSXMLParser(contentsOfURL: url)!
    parser.delegate = parserDelegate
    parser.parse()

    rootViews = parserDelegate.rootViews
    reusables = parserDelegate.reusables
  }
}

private class NibParserDelegate: NSObject, NSXMLParserDelegate {
  let ignoredRootViewElements = ["placeholder"]
  var rootViews: [Type] = []
  var reusables: [Reusable] = []

  // State
  var isObjectsTagOpened = false;
  var levelSinceObjectsTagOpened = 0;

  @objc func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
    switch elementName {
    case "objects":
      isObjectsTagOpened = true;

    default:
      if isObjectsTagOpened {
        levelSinceObjectsTagOpened++;

        if let rootView = viewWithAttributes(attributeDict)
          where levelSinceObjectsTagOpened == 1 && ignoredRootViewElements.filter({ $0 == elementName }).count == 0 {
            rootViews.append(rootView)
        }
      }

      if let reusable = reusableFromAttributes(attributeDict, elementName: elementName) {
        reusables.append(reusable)
      }
    }
  }

  @objc func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    switch elementName {
    case "objects":
      isObjectsTagOpened = false;

    default:
      if isObjectsTagOpened {
        levelSinceObjectsTagOpened--;
      }
    }
  }

  func viewWithAttributes(attributeDict: [String : String]) -> Type? {
    let customModuleProvider = attributeDict["customModuleProvider"]
    let customModule = (customModuleProvider == "target") ? nil : attributeDict["customModule"]
    let customClass = (attributeDict["customClass"]) ?? "UIView"
    return Type(module: Module(name: customModule), name: customClass)
  }

  func reusableFromAttributes(attributeDict: [String : String], elementName: String) -> Reusable? {
    if let reuseIdentifier = attributeDict["reuseIdentifier"] {
      let customModuleProvider = attributeDict["customModuleProvider"]
      let customModule = (customModuleProvider == "target") ? nil : attributeDict["customModule"]
      let customClass = attributeDict["customClass"]
      let customType = customClass.map { Type(module: Module(name: customModule), name: $0, optional: false) }

      let type = customType ?? ElementNameToTypeMapping[elementName] ?? Type._UIView

      return Reusable(identifier: reuseIdentifier, type: type)
    }
    
    return nil
  }
}
