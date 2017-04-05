//
//  Storyboard.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

private let ElementNameToTypeMapping = [
  "viewController": Type._UIViewController,
  "tableViewCell": Type(module: "UIKit", name: "UITableViewCell"),
  "tabBarController": Type(module: "UIKit", name: "UITabBarController"),
  "glkViewController": Type(module: "GLKit", name: "GLKViewController"),
  "pageViewController": Type(module: "UIKit", name: "UIPageViewController"),
  "tableViewController": Type(module: "UIKit", name: "UITableViewController"),
  "splitViewController": Type(module: "UIKit", name: "UISplitViewController"),
  "navigationController": Type(module: "UIKit", name: "UINavigationController"),
  "avPlayerViewController": Type(module: "AVKit", name: "AVPlayerViewController"),
  "collectionViewController": Type(module: "UIKit", name: "UICollectionViewController"),
]

struct Storyboard: WhiteListedExtensionsResourceType, ReusableContainer {
  static let supportedExtensions: Set<String> = ["storyboard"]

  let name: String
  private let initialViewControllerIdentifier: String?
  let viewControllers: [ViewController]
  let viewControllerPlaceholders: [ViewControllerPlaceholder]
  let usedImageIdentifiers: [String]
  let reusables: [Reusable]

  var initialViewController: ViewController? {
    return viewControllers
      .filter { $0.id == self.initialViewControllerIdentifier }
      .first
  }

  init(url: URL) throws {
    try Storyboard.throwIfUnsupportedExtension(url.pathExtension)

    guard let filename = url.filename else {
      throw ResourceParsingError.parsingFailed("Couldn't extract filename from URL: \(url)")
    }
    name = filename

    guard let parser = XMLParser(contentsOf: url) else {
      throw ResourceParsingError.parsingFailed("Couldn't load file at: '\(url)'")
    }

    let parserDelegate = StoryboardParserDelegate()
    parser.delegate = parserDelegate

    guard parser.parse() else {
      throw ResourceParsingError.parsingFailed("Invalid XML in file at: '\(url)'")
    }

    initialViewControllerIdentifier = parserDelegate.initialViewControllerIdentifier
    viewControllers = parserDelegate.viewControllers
    viewControllerPlaceholders = parserDelegate.viewControllerPlaceholders
    usedImageIdentifiers = parserDelegate.usedImageIdentifiers
    reusables = parserDelegate.reusables
  }

  struct ViewController {
    let id: String
    let storyboardIdentifier: String?
    let type: Type
    private(set) var segues: [Segue]

    fileprivate mutating func add(_ segue: Segue) {
      segues.append(segue)
    }
  }

  struct ViewControllerPlaceholder {
    enum ResolvedResult {
      case customBundle
      case resolved(ViewController?)
    }

    let id: String
    let storyboardName: String?
    let referencedIdentifier: String?
    let bundleIdentifier: String?

    func resolveWithStoryboards(_ storyboards: [Storyboard]) -> ResolvedResult {
      if nil != bundleIdentifier {
        // Can't resolve storyboard in other bundles
        return .customBundle
      }

      guard let storyboardName = storyboardName else {
        // Storyboard reference without a storyboard defined?!
        return .resolved(nil)
      }

      let storyboard = storyboards
        .filter { $0.name == storyboardName }

      guard let referencedIdentifier = referencedIdentifier else {
        return .resolved(storyboard.first?.initialViewController)
      }

      return .resolved(storyboard
        .flatMap {
          $0.viewControllers.filter { $0.storyboardIdentifier == referencedIdentifier }
        }
        .first)
    }
  }

  struct Segue {
    let identifier: String
    let type: Type
    let destination: String
    let kind: String
  }
}

private class StoryboardParserDelegate: NSObject, XMLParserDelegate {
  var initialViewControllerIdentifier: String?
  var viewControllers: [Storyboard.ViewController] = []
  var viewControllerPlaceholders: [Storyboard.ViewControllerPlaceholder] = []
  var usedImageIdentifiers: [String] = []
  var reusables: [Reusable] = []

  // State
  var currentViewController: Storyboard.ViewController?

  @objc func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
    switch elementName {
    case "document":
      if let initialViewController = attributeDict["initialViewController"] {
        initialViewControllerIdentifier = initialViewController
      }

    case "segue":
      let customModuleProvider = attributeDict["customModuleProvider"]
      let customModule = (customModuleProvider == "target") ? nil : attributeDict["customModule"]
      let customClass = attributeDict["customClass"]
      let customType = customClass
        .map { SwiftIdentifier(name: $0, lowercaseStartingCharacters: false) }
        .map { Type(module: Module(name: customModule), name: $0, optional: false) }

      if let customType = customType , attributeDict["kind"] != "custom" {
        warn("Set the segue of class \(customType) with identifier '\(attributeDict["identifier"] ?? "-no identifier-")' to type custom, using segue subclasses with other types can cause crashes on iOS 8 and lower.")
      }

      if let segueIdentifier = attributeDict["identifier"],
        let destination = attributeDict["destination"],
        let kind = attributeDict["kind"]
      {
        let type = customType ?? Type._UIStoryboardSegue

        let segue = Storyboard.Segue(identifier: segueIdentifier, type: type, destination: destination, kind: kind)
        currentViewController?.add(segue)
      }

    case "image":
      if let imageIdentifier = attributeDict["name"] {
        usedImageIdentifiers.append(imageIdentifier)
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
      .map { SwiftIdentifier(name: $0, lowercaseStartingCharacters: false) }
      .map { Type(module: Module(name: customModule), name: $0, optional: false) }

    let type = customType ?? ElementNameToTypeMapping[elementName] ?? Type._UIViewController

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
      .map { SwiftIdentifier(name: $0, lowercaseStartingCharacters: false) }
      .map { Type(module: Module(name: customModule), name: $0, optional: false) }

    let type = customType ?? ElementNameToTypeMapping[elementName] ?? Type._UIView
    
    return Reusable(identifier: reuseIdentifier, type: type)
  }
}

