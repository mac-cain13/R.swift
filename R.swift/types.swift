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

struct Type: CustomStringConvertible, Equatable, Hashable {
  static let _Void = Type(name: "Void")
  static let _AnyObject = Type(name: "AnyObject")
  static let _String = Type(name: "String")
  static let _NSURL = Type(name: "NSURL")
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
  static let _UIFont = Type(name: "UIFont")
  static let _CGFloat = Type(name: "CGFloat")

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

  var hashValue: Int {
    let optionalString = optional ? "?" : ""
    return "\(fullName)\(optionalString)".hashValue
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
  case UnsupportedExtension(givenExtension: String?, supportedExtensions: Set<String>)
  case ParsingFailed(String)
}

struct Xcodeproj {
  private let projectFile: XCProjectFile
  //let onDemandResourceTags: [String]

  init(url: NSURL) throws {
    // Parse project file
    guard let projectFile = try? XCProjectFile(xcodeprojURL: url) else {
      throw ResourceParsingError.ParsingFailed("Project file at '\(url)' could not be parsed, is this a valid Xcode project file ending in *.xcodeproj?")
    }

    self.projectFile = projectFile
  }

  func resourceURLsForTarget(targetName: String, pathResolver: Path -> NSURL) throws -> [NSURL] {
    // Look for target in project file
    let allTargets = projectFile.project.targets
    guard let target = allTargets.filter({ $0.name == targetName }).first else {
      let availableTargets = allTargets.map { $0.name }.joinWithSeparator(", ")
      throw ResourceParsingError.ParsingFailed("Target '\(targetName)' not found in project file, available targets are: \(availableTargets)")
    }

    let resourcesFileRefs = target.buildPhases
      .flatMap { $0 as? PBXResourcesBuildPhase }
      .flatMap { $0.files }
      .map { $0.fileRef }

    let fileRefPaths = resourcesFileRefs
      .flatMap { $0 as? PBXFileReference }
      .map { $0.fullPath }

    let variantGroupPaths = resourcesFileRefs
      .flatMap { $0 as? PBXVariantGroup }
      .flatMap { $0.fileRefs }
      .map { $0.fullPath }

    return (fileRefPaths + variantGroupPaths)
      .map(pathResolver)
  }
}

struct AssetFolder {
  let name: String
  let imageAssets: [String]

  init(url: NSURL, fileManager: NSFileManager) throws {
    guard let pathExtension = url.pathExtension where AssetFolderExtensions.contains(pathExtension) else {
      throw ResourceParsingError.UnsupportedExtension(givenExtension: url.pathExtension, supportedExtensions: AssetFolderExtensions)
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

struct Image {
  let name: String

  init(url: NSURL) throws {
    guard let pathExtension = url.pathExtension?.lowercaseString where ImageExtensions.contains(pathExtension) else {
      throw ResourceParsingError.UnsupportedExtension(givenExtension: url.pathExtension, supportedExtensions: ImageExtensions)
    }

    guard let filename = url.lastPathComponent else {
      throw ResourceParsingError.ParsingFailed("Filename could not be parsed from URL: \(url.absoluteString)")
    }

    let regex = try! NSRegularExpression(pattern: "(@[2,3]x)?\\.png$", options: .CaseInsensitive)
    let fullFileNameRange = NSRange(location: 0, length: filename.characters.count)
    name = regex.stringByReplacingMatchesInString(filename, options: NSMatchingOptions(rawValue: 0), range: fullFileNameRange, withTemplate: "")
  }
}

struct Font {
  let name: String

  init(url: NSURL) throws {
    guard let pathExtension = url.pathExtension where FontExtensions.contains(pathExtension) else {
      throw ResourceParsingError.UnsupportedExtension(givenExtension: url.pathExtension, supportedExtensions: FontExtensions)
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
  let name: String
  let segues: [String]
  private let initialViewControllerIdentifier: String?
  let viewControllers: [ViewController]
  let usedImageIdentifiers: [String]
  let reusables: [Reusable]

  var initialViewController: ViewController? {
    return viewControllers.filter { $0.id == self.initialViewControllerIdentifier }.first
  }

  init(url: NSURL) throws {
    guard let pathExtension = url.pathExtension where StoryboardExtensions.contains(pathExtension) else {
      throw ResourceParsingError.UnsupportedExtension(givenExtension: url.pathExtension, supportedExtensions: StoryboardExtensions)
    }

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
  let rootViews: [Type]
  let reusables: [Reusable]

  init(url: NSURL) throws {
    guard let pathExtension = url.pathExtension where NibExtensions.contains(pathExtension) else {
      throw ResourceParsingError.UnsupportedExtension(givenExtension: url.pathExtension, supportedExtensions: NibExtensions)
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

struct ResourceFile {
  let fullname: String
  let filename: String
  let pathExtension: String?

  init(url: NSURL) throws {
    if let pathExtension = url.pathExtension where CompiledResourcesExtensions.contains(pathExtension) {
        throw ResourceParsingError.UnsupportedExtension(givenExtension: pathExtension, supportedExtensions: ["*"])
    }

    guard let fullname = url.lastPathComponent, filename = url.filename else {
      throw ResourceParsingError.ParsingFailed("Couldn't extract filename without extension from URL: \(url)")
    }

    self.fullname = fullname
    self.filename = filename
    pathExtension = url.pathExtension
  }
}

/// MARK: Parsers

class StoryboardParserDelegate: NSObject, NSXMLParserDelegate {
  var initialViewControllerIdentifier: String?
  var segues: [String] = []
  var viewControllers: [Storyboard.ViewController] = []
  var usedImageIdentifiers: [String] = []
  var reusables: [Reusable] = []

  func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
    switch elementName {
    case "document":
      if let initialViewController = attributeDict["initialViewController"] {
        initialViewControllerIdentifier = initialViewController
      }

    case "segue":
      if let segueIdentifier = attributeDict["identifier"] {
        segues.append(segueIdentifier)
      }

    case "image":
      if let imageIdentifier = attributeDict["name"] {
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
    if let id = attributeDict["id"] as? String 
      where attributeDict["sceneMemberID"] as? String == "viewController" {
      let storyboardIdentifier = attributeDict["storyboardIdentifier"] as? String

      let customModule = attributeDict["customModule"] as? String
      let customClass = attributeDict["customClass"] as? String
      let customType = customClass.map { Type(module: customModule, name: $0, optional: false) }

      let type = customType ?? ElementNameToTypeMapping[elementName] ?? Type._UIViewController

      return Storyboard.ViewController(id: id, storyboardIdentifier: storyboardIdentifier, type: type)
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
