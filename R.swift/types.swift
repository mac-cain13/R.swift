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

/// MARK: Swift types

typealias TypeVar = String

struct Type: CustomStringConvertible, Equatable, Hashable {
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
  static let _UIStoryboardSegue = Type(name: "UIStoryboardSegue")
  static let _UICollectionView = Type(name: "UICollectionView")
  static let _UICollectionViewCell = Type(name: "UICollectionViewCell")
  static let _UICollectionReusableView = Type(name: "UICollectionReusableView")
  static let _UIViewController = Type(name: "UIViewController")
  static let _UIFont = Type(name: "UIFont")
  static let _CGFloat = Type(name: "CGFloat")

  let module: String?
  let name: String
  let genericArgs: [TypeVar]
  let optional: Bool

  var fullyQualifiedName: String {
    let optionalString = optional ? "?" : ""

    if genericArgs.count > 0 {
      let args = genericArgs.joinWithSeparator(", ")
      return "\(fullName)<\(args)>\(optionalString)"
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

  var hashValue: Int {
    let optionalString = optional ? "?" : ""
    return "\(fullName)\(optionalString)".hashValue
  }

  init(name: String, genericArgs: [TypeVar] = [], optional: Bool = false) {
    self.module = nil
    self.name = name
    self.genericArgs = genericArgs
    self.optional = optional
  }

  init(module: String?, name: String, genericArgs: [TypeVar] = [], optional: Bool = false) {
    self.module = module
    self.name = name
    self.genericArgs = genericArgs
    self.optional = optional
  }

  func asOptional() -> Type {
    return Type(module: module, name: name, genericArgs: genericArgs, optional: true)
  }

  func asNonOptional() -> Type {
    return Type(module: module, name: name, genericArgs: genericArgs, optional: false)
  }

  func withGenericArgs(genericArgs: [TypeVar]) -> Type {
    return Type(module: module, name: name, genericArgs: genericArgs, optional: optional)
  }
}

func ==(lhs: Type, rhs: Type) -> Bool {
  return (lhs.hashValue == rhs.hashValue)
}

struct Typealias: CustomStringConvertible {
  let alias: Type
  let type: Type?

  var description: String {
    let typeString = type.map { " = \($0)" } ?? ""

    return "typealias \(alias)\(typeString)"
  }
}

struct Var: CustomStringConvertible {
  let isStatic: Bool
  let name: String
  let type: Type
  let getter: String

  var callName: String {
    return sanitizedSwiftName(name, lowercaseFirstCharacter: true)
  }

  var description: String {
    let staticString = isStatic ? "static " : ""
    return "\(staticString)var \(callName): \(type) { \(getter) }"
  }
}

struct Let: CustomStringConvertible {
  let name: String
  let type: Type

  var callName: String {
    return sanitizedSwiftName(name, lowercaseFirstCharacter: true)
  }

  var description: String {
    return "let \(callName): \(type)"
  }
}

protocol Func: CustomStringConvertible {
  var callName: String { get }
}

struct Function: Func {
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
    let parameterString = parameters.joinWithSeparator(", ")
    let returnString = Type._Void == returnType ? "" : " -> \(returnType)"
    return "\(staticString)func \(callName)\(genericsString)(\(parameterString))\(returnString) {\n\(indent(body))\n}"
  }

  struct Parameter: CustomStringConvertible {
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

struct Initializer: Func {
  let type: Type
  let parameters: [Function.Parameter]
  let body: String

  let callName = "init"

  var description: String {
    let fullName = [type.description, callName].joinWithSeparator(" ")
    let parameterString = parameters.joinWithSeparator(", ")
    return "\(fullName)(\(parameterString)) {\n\(indent(body))\n}"
  }

  enum Type: CustomStringConvertible {
    case Designated
    case Required
    case Convenience

    var description: String {
      switch self {
      case .Designated: return ""
      case .Required: return "required"
      case .Convenience: return "convenience"
      }
    }
  }
}

struct Protocol: CustomStringConvertible {
  let type: Type
  let typealiasses: [Typealias]
  let vars: [Var]

  var description: String {
    let typealiassesString = typealiasses
      .sort { sanitizedSwiftName($0.alias.fullyQualifiedName) < sanitizedSwiftName($1.alias.fullyQualifiedName) }
      .joinWithSeparator("\n")
    let varsString = vars
      .sort { sanitizedSwiftName($0.name) < sanitizedSwiftName($1.name) }
      .joinWithSeparator("\n")

    let bodyComponents = [typealiassesString, varsString].filter { $0 != "" }
    let bodyString = indent(bodyComponents.joinWithSeparator("\n\n"))
    return "protocol \(type) {\n\(bodyString)\n}"
  }
}

struct Extension: CustomStringConvertible {
  let type: Type
  let functions: [Func]

  var description: String {
    let functionsString = functions
      .sort { $0.callName < $1.callName }
      .map { $0.description }
      .joinWithSeparator("\n\n")

    let bodyComponents = [functionsString].filter { $0 != "" }
    let bodyString = indent(bodyComponents.joinWithSeparator("\n\n"))
    return "extension \(type) {\n\(bodyString)\n}"
  }
}

struct Struct: CustomStringConvertible {
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
    let implementsString = implements.count > 0 ? ": " + implements.joinWithSeparator(", ") : ""

    let letsString = lets
      .sort { sanitizedSwiftName($0.name) < sanitizedSwiftName($1.name) }
      .joinWithSeparator("\n")
    let varsString = vars
      .sort { sanitizedSwiftName($0.name) < sanitizedSwiftName($1.name) }
      .joinWithSeparator("\n")
    let functionsString = functions
      .sort { sanitizedSwiftName($0.name) < sanitizedSwiftName($1.name) }
      .joinWithSeparator("\n\n")
    let structsString = structs
      .sort { $0.type.description < $1.type.description }
      .joinWithSeparator("\n\n")

    let bodyComponents = [letsString, varsString, functionsString, structsString].filter { $0 != "" }
    let bodyString = indent(bodyComponents.joinWithSeparator("\n\n"))
    return "struct \(type)\(implementsString) {\n\(bodyString)\n}"
  }
}

/// MARK: Resource types

enum ResourceParsingError: ErrorType {
  case UnsupportedExtension
  case ParsingFailed(String)
}

struct AssetFolder {
  let supportedExtensions = ["xcassets"]
  let name: String
  let imageAssets: [String]

  init(url: NSURL, fileManager: NSFileManager) throws {
    guard let pathExtension = url.pathExtension where supportedExtensions.contains(pathExtension) else {
      throw ResourceParsingError.UnsupportedExtension
    }

    name = url.filename!

    // Browse asset directory recursively and list only the assets folders
    var assets = [NSURL]()
    let enumerator = fileManager.enumeratorAtURL(url, includingPropertiesForKeys: nil, options: .SkipsHiddenFiles, errorHandler: nil)
    if let enumerator = enumerator {
      for file in enumerator {
        if let fileURL = file as? NSURL, pathExtension = fileURL.pathExtension where AssetExtensions.indexOf(pathExtension) != nil {
          assets.append(fileURL)
        }
      }
    }
    
    imageAssets = assets.map { $0.filename! }
  }
}

struct Font {
  let supportedExtensions = ["otf", "ttf"]
  let name: String

  init(url: NSURL) throws {
    guard let pathExtension = url.pathExtension where supportedExtensions.contains(pathExtension) else {
      throw ResourceParsingError.UnsupportedExtension
    }

    let dataProvider = CGDataProviderCreateWithURL(url)
    let font = CGFontCreateWithDataProvider(dataProvider)

    guard let postScriptName = CGFontCopyPostScriptName(font) else {
      throw ResourceParsingError.ParsingFailed("No postcriptName associated to font at \(url)")
    }

    name = postScriptName as String
  }
}

struct Storyboard: ReusableContainer {
  let supportedExtensions = ["storyboard"]
  let name: String
  private let initialViewControllerIdentifier: String?
  let viewControllers: [ViewController]
  let usedImageIdentifiers: [String]
  let reusables: [Reusable]

  var initialViewController: ViewController? {
    return viewControllers.filter { $0.id == self.initialViewControllerIdentifier }.first
  }

  init(url: NSURL) throws {
    guard let pathExtension = url.pathExtension where supportedExtensions.contains(pathExtension) else {
      throw ResourceParsingError.UnsupportedExtension
    }

    name = url.filename!

    let parserDelegate = StoryboardParserDelegate()

    let parser = NSXMLParser(contentsOfURL: url)!
    parser.delegate = parserDelegate
    parser.parse()

    initialViewControllerIdentifier = parserDelegate.initialViewControllerIdentifier
    viewControllers = parserDelegate.viewControllers
    usedImageIdentifiers = parserDelegate.usedImageIdentifiers
    reusables = parserDelegate.reusables
  }

  struct ViewController {
    let id: String
    let storyboardIdentifier: String?
    let type: Type
    private(set) var segues: [Segue]

    mutating func addSegue(segue: Segue) {
      segues.append(segue)
    }
  }

  struct Segue {
    let identifier: String
    let type: Type
    let destination: String
  }
}

struct Nib: ReusableContainer {
  let supportedExtensions = ["xib"]
  let name: String
  let rootViews: [Type]
  let reusables: [Reusable]

  init(url: NSURL) throws {
    guard let pathExtension = url.pathExtension where supportedExtensions.contains(pathExtension) else {
      throw ResourceParsingError.UnsupportedExtension
    }

    name = url.filename!

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
  var viewControllers: [Storyboard.ViewController] = []
  var usedImageIdentifiers: [String] = []
  var reusables: [Reusable] = []

  // State
  var currentViewController: (String, Storyboard.ViewController)?

  func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
    switch elementName {
    case "document":
      if let initialViewController = attributeDict["initialViewController"] {
        initialViewControllerIdentifier = initialViewController
      }

    case "segue":
      if let segueIdentifier = attributeDict["identifier"], segueDestination = attributeDict["destination"] {
        let customModule = attributeDict["customModule"]
        let customClass = attributeDict["customClass"]
        let customType = customClass.map { Type(module: customModule, name: $0, optional: false) }

        let type = customType ?? Type._UIStoryboardSegue

        let segue = Storyboard.Segue(identifier: segueIdentifier, type: type, destination: segueDestination)
        currentViewController!.1.addSegue(segue)
      }

    case "image":
      if let imageIdentifier = attributeDict["name"] {
        usedImageIdentifiers.append(imageIdentifier)
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

  func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if let currentViewController = currentViewController where elementName == currentViewController.0 {
      viewControllers.append(currentViewController.1)
      self.currentViewController = nil
    }
  }

  func viewControllerFromAttributes(attributeDict: [NSObject : AnyObject], elementName: String) -> Storyboard.ViewController? {
    guard let id = attributeDict["id"] as? String where attributeDict["sceneMemberID"] as? String == "viewController" else {
      return nil
    }

    let storyboardIdentifier = attributeDict["storyboardIdentifier"] as? String

    let customModule = attributeDict["customModule"] as? String
    let customClass = attributeDict["customClass"] as? String
    let customType = customClass.map { Type(module: customModule, name: $0, optional: false) }

    let type = customType ?? ElementNameToTypeMapping[elementName] ?? Type._UIViewController

    return Storyboard.ViewController(id: id, storyboardIdentifier: storyboardIdentifier, type: type, segues: [])
  }

  func reusableFromAttributes(attributeDict: [NSObject : AnyObject], elementName: String) -> Reusable? {
    guard let reuseIdentifier = attributeDict["reuseIdentifier"] as? String else {
      return nil
    }

    let customModule = attributeDict["customModule"] as? String
    let customClass = attributeDict["customClass"] as? String
    let customType = customClass.map { Type(module: customModule, name: $0, optional: false) }

    let type = customType ?? ElementNameToTypeMapping[elementName] ?? Type._UIView

    return Reusable(identifier: reuseIdentifier, type: type)
  }
}

class NibParserDelegate: NSObject, NSXMLParserDelegate {
  let ignoredRootViewElements = ["placeholder"]
  var rootViews: [Type] = []
  var reusables: [Reusable] = []

  // State
  var isObjectsTagOpened = false;
  var levelSinceObjectsTagOpened = 0;

  func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
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
