//
//  Storyboard.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 09-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
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

  init(url: NSURL) throws {
    try Storyboard.throwIfUnsupportedExtension(url.pathExtension)

    name = url.filename!

    let parserDelegate = StoryboardParserDelegate()

    let parser = NSXMLParser(contentsOfURL: url)!
    parser.delegate = parserDelegate
    parser.parse()

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

    private mutating func addSegue(segue: Segue) {
      segues.append(segue)
    }
  }

  struct ViewControllerPlaceholder {
    enum ResolvedResult {
      case CustomBundle
      case Resolved(ViewController?)
    }

    let id: String
    let storyboardName: String?
    let referencedIdentifier: String?
    let bundleIdentifier: String?

    func resolveWithStoryboards(storyboards: [Storyboard]) -> ResolvedResult {
      if nil != bundleIdentifier {
        // Can't resolve storyboard in other bundles
        return .CustomBundle
      }

      guard let storyboardName = storyboardName else {
        // Storyboard reference without a storyboard defined?!
        return .Resolved(nil)
      }

      let storyboard = storyboards
        .filter { $0.name == storyboardName }

      guard let referencedIdentifier = referencedIdentifier else {
        return .Resolved(storyboard.first?.initialViewController)
      }

      return .Resolved(storyboard
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
  }
}

private class StoryboardParserDelegate: NSObject, NSXMLParserDelegate {
  var initialViewControllerIdentifier: String?
  var viewControllers: [Storyboard.ViewController] = []
  var viewControllerPlaceholders: [Storyboard.ViewControllerPlaceholder] = []
  var usedImageIdentifiers: [String] = []
  var reusables: [Reusable] = []

  // State
  var currentViewController: (String, Storyboard.ViewController)?

  @objc func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
    switch elementName {
    case "document":
      if let initialViewController = attributeDict["initialViewController"] {
        initialViewControllerIdentifier = initialViewController
      }

    case "segue":
      let customModuleProvider = attributeDict["customModuleProvider"]
      let customModule = (customModuleProvider == "target") ? nil : attributeDict["customModule"]
      let customClass = attributeDict["customClass"]
      let customType = customClass.map { Type(module: Module(name: customModule), name: $0, optional: false) }

      if let customType = customType where attributeDict["kind"] != "custom" {
        warn("Set the segue of class \(customType) with identifier '\(attributeDict["identifier"] ?? "-no identifier-")' to type custom, using segue subclasses with other types can cause crashes on iOS 8 and lower.")
      }

      if let segueIdentifier = attributeDict["identifier"],
        segueDestination = attributeDict["destination"]
      {
        let type = customType ?? Type._UIStoryboardSegue

        let segue = Storyboard.Segue(identifier: segueIdentifier, type: type, destination: segueDestination)
        currentViewController!.1.addSegue(segue)
      }

    case "image":
      if let imageIdentifier = attributeDict["name"] {
        usedImageIdentifiers.append(imageIdentifier)
      }

    case "viewControllerPlaceholder":
      if let id = attributeDict["id"] where attributeDict["sceneMemberID"] == "viewController" {
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
        currentViewController = (elementName, viewController)
      }

      if let reusable = reusableFromAttributes(attributeDict, elementName: elementName) {
        reusables.append(reusable)
      }
    }
  }

  @objc func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if let currentViewController = currentViewController where elementName == currentViewController.0 {
      viewControllers.append(currentViewController.1)
      self.currentViewController = nil
    }
  }

  func viewControllerFromAttributes(attributeDict: [String : String], elementName: String) -> Storyboard.ViewController? {
    guard let id = attributeDict["id"] where attributeDict["sceneMemberID"] == "viewController" else {
      return nil
    }

    let storyboardIdentifier = attributeDict["storyboardIdentifier"]

    let customModuleProvider = attributeDict["customModuleProvider"]
    let customModule = (customModuleProvider == "target") ? nil : attributeDict["customModule"]
    let customClass = attributeDict["customClass"]
    let customType = customClass.map { Type(module: Module(name: customModule), name: $0, optional: false) }

    let type = customType ?? ElementNameToTypeMapping[elementName] ?? Type._UIViewController

    return Storyboard.ViewController(id: id, storyboardIdentifier: storyboardIdentifier, type: type, segues: [])
  }

  func reusableFromAttributes(attributeDict: [String : String], elementName: String) -> Reusable? {
    guard let reuseIdentifier = attributeDict["reuseIdentifier"] where reuseIdentifier != "" else {
      return nil
    }

    let customModuleProvider = attributeDict["customModuleProvider"]
    let customModule = (customModuleProvider == "target") ? nil : attributeDict["customModule"]
    let customClass = attributeDict["customClass"]
    let customType = customClass.map { Type(module: Module(name: customModule), name: $0, optional: false) }

    let type = customType ?? ElementNameToTypeMapping[elementName] ?? Type._UIView
    
    return Reusable(identifier: reuseIdentifier, type: type)
  }
}

