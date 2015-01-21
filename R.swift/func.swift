//
//  func.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 14-12-14.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

// MARK: Types

let ResourceFilename = "R.generated.swift"

struct AssetFolder {
  let name: String
  let imageAssets: [String]

  init(url: NSURL, fileManager: NSFileManager) {
    name = url.filename!

    let contents = fileManager.contentsOfDirectoryAtURL(url, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles, error: nil) as [NSURL]
    imageAssets = contents.map { $0.filename! }
  }
}

struct Storyboard {
  let name: String
  let segues: [String]
  let viewControllers: [ViewController]
  let usedImageIdentifiers: [String]

  init(url: NSURL) {
    name = url.filename!

    let parserDelegate = StoryboardParserDelegate()

    let parser = NSXMLParser(contentsOfURL: url)!
    parser.delegate = parserDelegate
    parser.parse()

    segues = parserDelegate.segues
    viewControllers = parserDelegate.viewControllers
    usedImageIdentifiers = parserDelegate.usedImageIdentifiers
  }

  struct ViewController {
    let storyboardIdentifier: String
    let customModule: String?
    let customClass: String

    func fullyQualifiedClass() -> String {
      if let customModule = customModule {
        return customModule + "." + customClass
      }

      return customClass
    }
  }
}

class StoryboardParserDelegate: NSObject, NSXMLParserDelegate {
  var segues: [String] = []
  var viewControllers: [Storyboard.ViewController] = []
  var usedImageIdentifiers: [String] = []

  func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
    switch elementName {
    case "segue":
      if let segueIdentifier = attributeDict["identifier"] as? String {
        segues.append(segueIdentifier)
      }

    case "image":
      if let imageIdentifier = attributeDict["name"] as? String {
        usedImageIdentifiers.append(imageIdentifier)
      }

    default:
      if let viewController = viewControllerFromAttributes(attributeDict) {
        viewControllers.append(viewController)
      }
    }
  }

  func viewControllerFromAttributes(attributeDict: [NSObject : AnyObject]) -> Storyboard.ViewController? {
    if attributeDict["sceneMemberID"] as? String == "viewController" {
      if let storyboardIdentifier = attributeDict["storyboardIdentifier"] as? String {
        let customModule = attributeDict["customModule"] as? String
        let customClass = attributeDict["customClass"] as? String ?? "UIViewController"

        return Storyboard.ViewController(storyboardIdentifier: storyboardIdentifier, customModule: customModule, customClass: customClass)
      }
    }

    return nil
  }
}

// MARK: Helper functions

let IndentationString = "  "
let indent = indentWithString(IndentationString)

func inputDirectories(processInfo: NSProcessInfo) -> [NSURL] {
  return processInfo.arguments.skip(1).map { NSURL(fileURLWithPath: $0 as String)! }
}

func filterDirectoryContentsRecursively(fileManager: NSFileManager, filter: (NSURL) -> Bool)(url: NSURL) -> [NSURL] {
  var assetFolders = [NSURL]()

  if let enumerator = fileManager.enumeratorAtURL(url, includingPropertiesForKeys: [NSURLIsDirectoryKey], options: NSDirectoryEnumerationOptions.SkipsHiddenFiles|NSDirectoryEnumerationOptions.SkipsPackageDescendants, errorHandler: nil) {

    while let enumeratorItem: AnyObject = enumerator.nextObject() {
      if let url = enumeratorItem as? NSURL {
        if filter(url) {
          assetFolders.append(url)
          enumerator.skipDescendants()
        }
      }
    }

  }

  return assetFolders
}

func sanitizedSwiftName(name: String) -> String {
  var components = name.componentsSeparatedByString("-")
  let firstComponent = components.removeAtIndex(0)
  return components.reduce(firstComponent) { $0 + $1.capitalizedString }.lowercaseFirstCharacter
}

func writeResourceFile(code: String, toFolderURL folderURL: NSURL) {
  let outputURL = folderURL.URLByAppendingPathComponent(ResourceFilename)
  code.writeToURL(outputURL, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
}

// MARK: Code generator functions

func swiftImports() -> String {
    return "import UIKit"
}

func swiftImageStructWithAssetFolders(assetFolders: [AssetFolder]) -> String {
  return distinct(assetFolders.flatMap { $0.imageAssets })
    .reduce("struct image {\n") {
      $0 + "    static var \(sanitizedSwiftName($1)): UIImage? { return UIImage(named: \"\($1)\") }\n"
    } + "}"
}

func swiftSegueStructWithStoryboards(storyboards: [Storyboard]) -> String {
  return distinct(storyboards.flatMap { $0.segues })
    .reduce("struct segue {\n") {
      $0 + "    static var \(sanitizedSwiftName($1)): String { return \"\($1)\" }\n"
    } + "}"
}

func swiftStructForStoryboard(storyboard: Storyboard) -> String {
  let instanceVar = "static var instance: UIStoryboard { return UIStoryboard(name: \"\(storyboard.name)\", bundle: nil) }"

  let viewControllers = storyboard.viewControllers.reduce("") {
    $0 + "static var \(sanitizedSwiftName($1.storyboardIdentifier)): \($1.fullyQualifiedClass())? { return instance.instantiateViewControllerWithIdentifier(\"\($1.storyboardIdentifier)\") as? \($1.fullyQualifiedClass()) }\n"
  }

  let validateStoryboardImages = distinct(storyboard.usedImageIdentifiers)
    .reduce("static func validateImages() {\n") {
      $0 + "    assert(UIImage(named: \"\($1)\") != nil, \"[R.swift] Image named '\($1)' is used in storyboard '\(storyboard.name)', but couldn't be loaded.\")\n"
    } + "}"

  let validateStoryboardViewControllers = storyboard.viewControllers
    .reduce("static func validateViewControllers() {\n") {
      $0 + "    assert(\(sanitizedSwiftName($1.storyboardIdentifier)) != nil, \"[R.swift] ViewController with identifier '\(sanitizedSwiftName($1.storyboardIdentifier))' could not be loaded from storyboard '\(storyboard.name)' as '\($1.fullyQualifiedClass())'.\")\n"
    } + "}"

  return "struct \(sanitizedSwiftName(storyboard.name)) {\n" + indent(string: instanceVar) + "\n" + indent(string: viewControllers) + indent(string: validateStoryboardImages) + "\n" + indent(string: validateStoryboardViewControllers) + "}"
}

func swiftCallStoryboardValidators(storyboard: Storyboard) -> String {
  return
    "storyboard.\(sanitizedSwiftName(storyboard.name)).validateImages()\n" +
    "storyboard.\(sanitizedSwiftName(storyboard.name)).validateViewControllers()"
}
