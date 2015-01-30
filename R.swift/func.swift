//
//  func.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 14-12-14.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

// MARK: Values

let ResourceFilename = "R.generated.swift"
let Ordinals = [
  (number: 1, word: "first"),
  (number: 2, word: "second"),
  (number: 3, word: "third"),
  (number: 4, word: "fourth"),
  (number: 5, word: "fifth"),
  (number: 6, word: "sixth"),
  (number: 7, word: "seventh"),
  (number: 8, word: "eighth"),
  (number: 9, word: "ninth"),
  (number: 10, word: "tenth"),
  (number: 11, word: "eleventh"),
  (number: 12, word: "twelfth"),
  (number: 13, word: "thirteenth"),
  (number: 14, word: "fourteenth"),
  (number: 15, word: "fifteenth"),
  (number: 16, word: "sixteenth"),
  (number: 17, word: "seventeenth"),
  (number: 18, word: "eighteenth"),
  (number: 19, word: "nineteenth"),
  (number: 20, word: "twentieth"),
]

// MARK: Helper functions

let indent = indentWithString("  ")

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

func sanitizedSwiftName(name: String, lowercaseFirstCharacter: Bool = true) -> String {
  var components = name.componentsSeparatedByString("-")
  let firstComponent = components.removeAtIndex(0)
  let swiftName = components.reduce(firstComponent) { $0 + $1.capitalizedString }

  return lowercaseFirstCharacter ? swiftName.lowercaseFirstCharacter : swiftName
}

func writeResourceFile(code: String, toFolderURL folderURL: NSURL) {
  let outputURL = folderURL.URLByAppendingPathComponent(ResourceFilename)
  code.writeToURL(outputURL, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
}

// MARK: Code generator functions

func imageStructFromAssetFolders(assetFolders: [AssetFolder]) -> Struct {
  let vars = distinct(assetFolders.flatMap { $0.imageAssets })
    .map { Var(isStatic: true, name: $0, type: Type(className: "UIImage", optional: true), getter: "return UIImage(named: \"\($0)\")") }

  return Struct(name: "image", vars: vars, functions: [], structs: [])
}

func segueStructFromStoryboards(storyboards: [Storyboard]) -> Struct {
  let vars = distinct(storyboards.flatMap { $0.segues })
    .map { Var(isStatic: true, name: $0, type: Type(className: "String"), getter: "return \"\($0)\"") }

  return Struct(name: "segue", vars: vars, functions: [], structs: [])
}

func storyboardStructForStoryboard(storyboard: Storyboard) -> Struct {
  let instanceVars = [Var(isStatic: true, name: "instance", type: Type(className: "UIStoryboard"), getter: "return UIStoryboard(name: \"\(storyboard.name)\", bundle: nil)")]

  let viewControllerVars = storyboard.viewControllers
    .map { Var(isStatic: true, name: $0.storyboardIdentifier, type: $0.type.asOptional(), getter: "return instance.instantiateViewControllerWithIdentifier(\"\($0.storyboardIdentifier)\") as? \($0.type.asNonOptional())") }

  let validateImagesLines = distinct(storyboard.usedImageIdentifiers)
    .map { "assert(UIImage(named: \"\($0)\") != nil, \"[R.swift] Image named '\($0)' is used in storyboard '\(storyboard.name)', but couldn't be loaded.\")" }
  let validateImagesFunc = Function(isStatic: true, name: "validateImages", parameters: [], returnType: Type(className: "Void"), body: join("\n", validateImagesLines))

  let validateViewControllersLines = storyboard.viewControllers
    .map { "assert(\(sanitizedSwiftName($0.storyboardIdentifier)) != nil, \"[R.swift] ViewController with identifier '\(sanitizedSwiftName($0.storyboardIdentifier))' could not be loaded from storyboard '\(storyboard.name)' as '\($0.type)'.\")" }
  let validateViewControllersFunc = Function(isStatic: true, name: "validateViewControllers", parameters: [], returnType: Type(className: "Void"), body: join("\n", validateViewControllersLines))

  return Struct(name: storyboard.name, vars: instanceVars + viewControllerVars, functions: [validateImagesFunc, validateViewControllersFunc], structs: [])
}

func nibStructForNib(nib: Nib) -> Struct {
  let ownerOrNilParameter = Function.Parameter(name: "ownerOrNil", type: Type(className: "AnyObject", optional: true))
  let optionsOrNilParameter = Function.Parameter(name: "options", localName: "optionsOrNil", type: Type(className: "[NSObject : AnyObject]", optional: true))

  let instanceVars = [Var(isStatic: true, name: "instance", type: Type(className: "UINib"), getter: "return UINib.init(nibName: \"\(nib.name)\", bundle: nil)")]
  let instantiateFuncs = [Function(isStatic: true, name: "instantiateWithOwner", parameters: [ownerOrNilParameter, optionsOrNilParameter], returnType: Type(className: "[AnyObject]"), body: "return instance.instantiateWithOwner(ownerOrNil, options: optionsOrNil)")]

  let viewFuncs = zip(nib.rootViews, Ordinals)
    .map { (view: $0.0, ordinal: $0.1) }
    .map { Function(isStatic: true, name: "\($0.ordinal.word)View", parameters: [ownerOrNilParameter, optionsOrNilParameter], returnType: $0.view.asOptional(), body: "return instantiateWithOwner(ownerOrNil, options: optionsOrNil)[\($0.ordinal.number - 1)] as? \($0.view)") }

  return Struct(name: nib.name, vars: instanceVars, functions: instantiateFuncs + viewFuncs, structs: [])
}

func swiftCallStoryboardValidators(storyboard: Storyboard) -> String {
  return
    "storyboard.\(sanitizedSwiftName(storyboard.name)).validateImages()\n" +
    "storyboard.\(sanitizedSwiftName(storyboard.name)).validateViewControllers()"
}
