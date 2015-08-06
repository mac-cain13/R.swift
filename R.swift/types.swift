//
//  types.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 30-01-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

// MARK: Helper types

typealias Reusable = (identifier: String, type: Type)

protocol ReusableContainer {
  var reusables: [Reusable] { get }
}

class Box<T> {
  let value: T

  init(value: T) {
    self.value = value
  }
}

/// MARK: Swift types

struct Type: Printable, Equatable {
  static let _Void = Type(name: "Void")
  static let _AnyObject = Type(name: "AnyObject")
  static let _String = Type(name: "String")
  static let _UINib = Type(name: "UINib")
  static let _UIView = Type(name: "UIView")
  static let _UIImage = Type(name: "UIImage")
  static let _NSIndexPath = Type(name: "NSIndexPath")
  static let _UITableView = Type(name: "UITableView")
  static let _UITableViewCell = Type(name: "UITableViewCell")
  static let _UITableViewHeaderFooterView = Type(name: "UITableViewHeaderFooterView")
  static let _UIStoryboard = Type(name: "UIStoryboard")
  static let _UICollectionView = Type(name: "UICollectionView")
  static let _UICollectionViewCell = Type(name: "UICollectionViewCell")
  static let _UICollectionReusableView = Type(name: "UICollectionReusableView")
  static let _UIViewController = Type(name: "UIViewController")

  let module: String?
  let name: String
  let genericTypeBox: Box<Type?>
  let optional: Bool

  var fullyQualifiedName: String {
    let optionalString = optional ? "?" : ""

    if let genericType = genericTypeBox.value {
      return "\(fullName)<\(genericType)>\(optionalString)"
    }

    return "\(fullName)\(optionalString)"
  }

  private var fullName: String {
    if let module = module {
      return "\(module).\((name))"
    }

    return name
  }

  var description: String {
    return fullyQualifiedName
  }

  init(name: String, genericType: Type? = nil, optional: Bool = false) {
    self.module = nil
    self.name = name
    self.genericTypeBox = Box(value: genericType)
    self.optional = optional
  }

  init(module: String?, name: String, genericType: Type? = nil, optional: Bool = false) {
    self.module = module
    self.name = name
    self.genericTypeBox = Box(value: genericType)
    self.optional = optional
  }

  func asOptional() -> Type {
    return Type(module: module, name: name, genericType: genericTypeBox.value, optional: true)
  }

  func asNonOptional() -> Type {
    return Type(module: module, name: name, genericType: genericTypeBox.value, optional: false)
  }

  func withGenericType(genericType: Type) -> Type {
    return Type(module: module, name: name, genericType: genericType, optional: optional)
  }
}

func ==(lhs: Type, rhs: Type) -> Bool {
  return (lhs.module == rhs.module && lhs.name == rhs.name && lhs.optional == rhs.optional)
}

struct Typealias: Printable {
  let alias: Type
  let type: Type?

  var description: String {
    let typeString = type.map { " = \($0)" } ?? ""

    return "typealias \(alias)\(typeString)"
  }
}

struct Var: Printable {
  let isStatic: Bool
  let name: String
  let type: Type
  let getter: String

  var description: String {
    let staticString = isStatic ? "static " : ""
    let swiftName = sanitizedSwiftName(name, lowercaseFirstCharacter: true)
    return "\(staticString)var \(swiftName): \(type) { \(getter) }"
  }
}

struct Let: Printable {
  let name: String
  let type: Type

  var description: String {
    let swiftName = sanitizedSwiftName(name, lowercaseFirstCharacter: true)
    return "let \(swiftName): \(type)"
  }
}

struct Function: Printable {
  let isStatic: Bool
  let name: String
  let generics: String?
  let parameters: [Parameter]
  let returnType: Type
  let body: String

  var callName: String {
    return sanitizedSwiftName(name, lowercaseFirstCharacter: true)
  }

  var description: String {
    let staticString = isStatic ? "static " : ""
    let genericsString = generics.map { "<\($0)>" } ?? ""
    let parameterString = join(", ", parameters)
    let returnString = Type._Void == returnType ? "" : " -> \(returnType)"
    return "\(staticString)func \(callName)\(genericsString)(\(parameterString))\(returnString) {\n\(indent(body))\n}"
  }

  struct Parameter: Printable {
    let name: String
    let localName: String?
    let type: Type
    let defaultValue: String?

    var swiftName: String {
      return sanitizedSwiftName(name, lowercaseFirstCharacter: true)
    }

    var description: String {
      let definition = localName.map({ "\(self.swiftName) \($0): \(type)" }) ?? "\(swiftName): \(type)"
      return defaultValue.map({ "\(definition) = \($0)" }) ?? definition
    }

    init(name: String, type: Type, defaultValue: String? = nil) {
      self.name = name
      self.localName = nil
      self.type = type
      self.defaultValue = defaultValue
    }

    init(name: String, localName: String?, type: Type, defaultValue: String? = nil) {
      self.name = name
      self.localName = localName
      self.type = type
      self.defaultValue = defaultValue
    }
  }
}

struct Protocol: Printable {
  let type: Type
  let typealiasses: [Typealias]
  let vars: [Var]

  var description: String {
    let typealiassesString = join("\n", typealiasses.sorted { sanitizedSwiftName($0.alias.fullyQualifiedName) < sanitizedSwiftName($1.alias.fullyQualifiedName) })
    let varsString = join("\n", vars.sorted { sanitizedSwiftName($0.name) < sanitizedSwiftName($1.name) })

    let bodyComponents = [typealiassesString, varsString].filter { $0 != "" }
    let bodyString = indent(join("\n\n", bodyComponents))
    return "protocol \(type) {\n\(bodyString)\n}"
  }
}

struct Extension: Printable {
  let type: Type
  let functions: [Function]

  var description: String {
    let functionsString = join("\n\n", functions.sorted { sanitizedSwiftName($0.name) < sanitizedSwiftName($1.name) })

    let bodyComponents = [functionsString].filter { $0 != "" }
    let bodyString = indent(join("\n\n", bodyComponents))
    return "extension \(type) {\n\(bodyString)\n}"
  }
}

struct Struct: Printable {
  let type: Type
  let implements: [Type]
  let vars: [Var]
  let lets: [Let]
  let functions: [Function]
  let structs: [Struct]

  init(type: Type, lets: [Let], vars: [Var], functions: [Function], structs: [Struct]) {
    self.type = type
    self.implements = []
    self.lets = lets
    self.vars = vars
    self.functions = functions
    self.structs = structs
  }

  init(type: Type, implements: [Type], lets: [Let], vars: [Var], functions: [Function], structs: [Struct]) {
    self.type = type
    self.implements = implements
    self.vars = vars
    self.lets = lets
    self.functions = functions
    self.structs = structs
  }

  var description: String {
    let implementsString = implements.count > 0 ? ": " + join(", ", implements) : ""

    let letsString = join("\n", lets.sorted { sanitizedSwiftName($0.name) < sanitizedSwiftName($1.name) })
    let varsString = join("\n", vars.sorted { sanitizedSwiftName($0.name) < sanitizedSwiftName($1.name) })
    let functionsString = join("\n\n", functions.sorted { sanitizedSwiftName($0.name) < sanitizedSwiftName($1.name) })
    let structsString = join("\n\n", structs.sorted { $0.type.description < $1.type.description })

    let bodyComponents = [letsString, varsString, functionsString, structsString].filter { $0 != "" }
    let bodyString = indent(join("\n\n", bodyComponents))
    return "struct \(type)\(implementsString) {\n\(bodyString)\n}"
  }
}

/// MARK: Asset types

struct AssetFolder {
  let name: String
  let imageAssets: [String]

  init(url: NSURL, fileManager: NSFileManager) {
    name = url.filename!

    // Browse asset directory recursively and list only the assets folders
    var assets = [NSURL]()
    let enumerator = fileManager.enumeratorAtURL(url, includingPropertiesForKeys: nil, options: .SkipsHiddenFiles, errorHandler: nil)
    if let enumerator = enumerator {
      for file in enumerator {
        if let fileURL = file as? NSURL, pathExtension = fileURL.pathExtension where find(AssetExtensions, pathExtension) != nil {
          assets.append(fileURL)
        }
      }
    }
    
    imageAssets = assets.map { $0.filename! }
  }
}

struct Storyboard: ReusableContainer {
  let name: String
  let segues: [String]
  private let initialViewControllerIdentifier: String?
  let viewControllers: [ViewController]
  let usedImageIdentifiers: [String]
  let reusables: [Reusable]

  var initialViewController: ViewController? {
    return viewControllers.filter { $0.id == self.initialViewControllerIdentifier }.first
  }

  init(url: NSURL) {
    name = url.filename!

    let parserDelegate = StoryboardParserDelegate()

    let parser = NSXMLParser(contentsOfURL: url)!
    parser.delegate = parserDelegate
    parser.parse()

    segues = parserDelegate.segues
    initialViewControllerIdentifier = parserDelegate.initialViewControllerIdentifier
    viewControllers = parserDelegate.viewControllers
    usedImageIdentifiers = parserDelegate.usedImageIdentifiers
    reusables = parserDelegate.reusables
  }

  struct ViewController {
    let id: String
    let storyboardIdentifier: String?
    let type: Type
  }
}

struct Nib: ReusableContainer {
  let name: String
  let symbolName: String
  let rootViews: [Type]
  let reusables: [Reusable]

  init(url: NSURL) {
    name = url.filename!
    symbolName = name.stringByReplacingOccurrencesOfString(" ", withString: "", options: nil, range: nil)

    let parserDelegate = NibParserDelegate();

    let parser = NSXMLParser(contentsOfURL: url)!
    parser.delegate = parserDelegate
    parser.parse()

    rootViews = parserDelegate.rootViews
    reusables = parserDelegate.reusables
  }
}

/// MARK: Parsers

class StoryboardParserDelegate: NSObject, NSXMLParserDelegate {
  var initialViewControllerIdentifier: String?
  var segues: [String] = []
  var viewControllers: [Storyboard.ViewController] = []
  var usedImageIdentifiers: [String] = []
  var reusables: [Reusable] = []

  func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
    switch elementName {
    case "document":
      if let initialViewController = attributeDict["initialViewController"] as? String {
        initialViewControllerIdentifier = initialViewController
      }

    case "segue":
      if let segueIdentifier = attributeDict["identifier"] as? String {
        segues.append(segueIdentifier)
      }

    case "image":
      if let imageIdentifier = attributeDict["name"] as? String {
        usedImageIdentifiers.append(imageIdentifier)
      }

    default:
      if let viewController = viewControllerFromAttributes(attributeDict, elementName: elementName) {
        viewControllers.append(viewController)
      }

      if let reusable = reusableFromAttributes(attributeDict, elementName: elementName) {
        reusables.append(reusable)
      }
    }
  }

  func viewControllerFromAttributes(attributeDict: [NSObject : AnyObject], elementName: String) -> Storyboard.ViewController? {
    if attributeDict["sceneMemberID"] as? String == "viewController" {
        if let id = attributeDict["id"] as? String {
            let storyboardIdentifier = attributeDict["storyboardIdentifier"] as? String

            let customModule = attributeDict["customModule"] as? String
            let customClass = attributeDict["customClass"] as? String
            let customType = customClass.map { Type(module: customModule, name: $0, optional: false) }

            let type = customType ?? ElementNameToTypeMapping[elementName] ?? Type._UIViewController

            return Storyboard.ViewController(id: id, storyboardIdentifier: storyboardIdentifier, type: type)
        }
    }

    return nil
  }

  func reusableFromAttributes(attributeDict: [NSObject : AnyObject], elementName: String) -> Reusable? {
    if let reuseIdentifier = attributeDict["reuseIdentifier"] as? String {
      let customModule = attributeDict["customModule"] as? String
      let customClass = attributeDict["customClass"] as? String
      let customType = customClass.map { Type(module: customModule, name: $0, optional: false) }

      let type = customType ?? ElementNameToTypeMapping[elementName] ?? Type._UIView

      return Reusable(identifier: reuseIdentifier, type: type)
    }

    return nil
  }
}

class NibParserDelegate: NSObject, NSXMLParserDelegate {
  let ignoredRootViewElements = ["placeholder"]
  var rootViews: [Type] = []
  var reusables: [Reusable] = []

  // State
  var isObjectsTagOpened = false;
  var levelSinceObjectsTagOpened = 0;

  func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
    switch elementName {
    case "objects":
      isObjectsTagOpened = true;

    default:
      if isObjectsTagOpened {
        levelSinceObjectsTagOpened++;

        if levelSinceObjectsTagOpened == 1 && ignoredRootViewElements.filter({ $0 == elementName }).count == 0 {
          if let rootView = viewWithAttributes(attributeDict) {
            rootViews.append(rootView)
          }
        }
      }

      if let reusable = reusableFromAttributes(attributeDict, elementName: elementName) {
        reusables.append(reusable)
      }
    }
  }

  func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    switch elementName {
    case "objects":
      isObjectsTagOpened = false;

    default:
      if isObjectsTagOpened {
        levelSinceObjectsTagOpened--;
      }
    }
  }

  func viewWithAttributes(attributeDict: [NSObject : AnyObject]) -> Type? {
    let customModule = attributeDict["customModule"] as? String
    let customClass = (attributeDict["customClass"] as? String) ?? "UIView"
    
    return Type(module: customModule, name: customClass)
  }

  func reusableFromAttributes(attributeDict: [NSObject : AnyObject], elementName: String) -> Reusable? {
    if let reuseIdentifier = attributeDict["reuseIdentifier"] as? String {
      let customModule = attributeDict["customModule"] as? String
      let customClass = attributeDict["customClass"] as? String
      let customType = customClass.map { Type(module: customModule, name: $0, optional: false) }

      let type = customType ?? ElementNameToTypeMapping[elementName] ?? Type._UIView

      return Reusable(identifier: reuseIdentifier, type: type)
    }

    return nil
  }
}
