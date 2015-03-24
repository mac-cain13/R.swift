//
//  func.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 14-12-14.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

// MARK: Helper functions

let indent = indentWithString(IndentationString)

func warn(warning: String) {
  println("warning: \(warning)")
}

func fail(error: String) {
  println("error: \(error)")
}

func failOnError(error: NSError?) {
  if let error = error {
    fail("\(error)")
  }
}

func inputDirectories(processInfo: NSProcessInfo) -> [NSURL] {
  return processInfo.arguments.skip(1).map { NSURL(fileURLWithPath: $0 as! String)! }
}

func filterDirectoryContentsRecursively(fileManager: NSFileManager, filter: (NSURL) -> Bool)(url: NSURL) -> [NSURL] {
  var assetFolders = [NSURL]()

  let errorHandler: (NSURL!, NSError!) -> Bool = { url, error in
    failOnError(error)
    return true
  }

  if let enumerator = fileManager.enumeratorAtURL(url, includingPropertiesForKeys: [NSURLIsDirectoryKey], options: NSDirectoryEnumerationOptions.SkipsHiddenFiles|NSDirectoryEnumerationOptions.SkipsPackageDescendants, errorHandler: errorHandler) {

    while let enumeratorItem: AnyObject = enumerator.nextObject() {
      if let url = enumeratorItem as? NSURL {
        if filter(url) {
          assetFolders.append(url)
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
  let capitalizedSwiftName = lowercaseFirstCharacter ? swiftName.lowercaseFirstCharacter : swiftName

  return contains(SwiftKeywords, capitalizedSwiftName) ? "`\(capitalizedSwiftName)`" : capitalizedSwiftName
}

func writeResourceFile(code: String, toFolderURL folderURL: NSURL) {
  let outputURL = folderURL.URLByAppendingPathComponent(ResourceFilename)

  var error: NSError?
  code.writeToURL(outputURL, atomically: true, encoding: NSUTF8StringEncoding, error: &error)

  failOnError(error)
}

func readResourceFile(folderURL: NSURL) -> String? {
  let inputURL = folderURL.URLByAppendingPathComponent(ResourceFilename)

  if let resourceFileString = String(contentsOfURL: inputURL, encoding: NSUTF8StringEncoding, error: nil) {
    return resourceFileString
  }

  return nil
}

// MARK: Struct/function generators

// Image

func imageStructFromAssetFolders(assetFolders: [AssetFolder]) -> Struct {
  let vars = distinct(assetFolders.flatMap { $0.imageAssets })
    .map { Var(name: $0, type: Type._UIImage.asOptional(), getter: "return UIImage(named: \"\($0)\")") }

  return Struct(name: "image", vars: vars, functions: [], structs: [])
}

// Segue

func segueStructFromStoryboards(storyboards: [Storyboard]) -> Struct {
  let vars = distinct(storyboards.flatMap { $0.segues })
    .map { Var(name: $0, type: Type._String, getter: "return \"\($0)\"") }

  return Struct(name: "segue", vars: vars, functions: [], structs: [])
}

// Storyboard

func storyboardStructFromStoryboards(storyboards: [Storyboard]) -> Struct {
  return Struct(name: "storyboard", vars: [], functions: [], structs: storyboards.map(storyboardStructForStoryboard))
}

func storyboardStructForStoryboard(storyboard: Storyboard) -> Struct {
  let instanceVars = [Var(name: "instance", type: Type._UIStoryboard, getter: "return UIStoryboard(name: \"\(storyboard.name)\", bundle: nil)")]


  let initialViewControllerVar = catOptionals([storyboard.initialViewController.map {
    Var(name: "initialViewController", type: $0.type.asOptional(), getter: "return instance.instantiateInitialViewController() as? \($0.type.asNonOptional())")
  }])

  let viewControllerVars = catOptionals(storyboard.viewControllers
    .map { vc in
      vc.storyboardIdentifier.map {
        return Var(name: $0, type: vc.type.asOptional(), getter: "return instance.instantiateViewControllerWithIdentifier(\"\($0)\") as? \(vc.type.asNonOptional())")
      }
    })

  let validateImagesLines = distinct(storyboard.usedImageIdentifiers)
    .map { "assert(UIImage(named: \"\($0)\") != nil, \"[R.swift] Image named '\($0)' is used in storyboard '\(storyboard.name)', but couldn't be loaded.\")" }
  let validateImagesFunc = Function(name: "validateImages", parameters: [], returnType: Type._Void, body: join("\n", validateImagesLines))

  let validateViewControllersLines = catOptionals(storyboard.viewControllers
    .map { vc in
      vc.storyboardIdentifier.map {
        "assert(\(sanitizedSwiftName($0)) != nil, \"[R.swift] ViewController with identifier '\(sanitizedSwiftName($0))' could not be loaded from storyboard '\(storyboard.name)' as '\(vc.type)'.\")"
      }
    })
  let validateViewControllersFunc = Function(name: "validateViewControllers", parameters: [], returnType: Type._Void, body: join("\n", validateViewControllersLines))

  return Struct(name: storyboard.name, vars: instanceVars + initialViewControllerVar + viewControllerVars, functions: [validateImagesFunc, validateViewControllersFunc], structs: [])
}

// Nib

func nibStructFromNibs(nibs: [Nib]) -> Struct {
  return Struct(name: "nib", vars: [], functions: [], structs: nibs.map(nibStructForNib))
}

func nibStructForNib(nib: Nib) -> Struct {
  let ownerOrNilParameter = Function.Parameter(name: "ownerOrNil", type: Type._AnyObject.asOptional())
  let optionsOrNilParameter = Function.Parameter(name: "options", localName: "optionsOrNil", type: Type(name: "[NSObject : AnyObject]", optional: true))

  let instanceVars = [Var(name: "instance", type: Type._UINib, getter: "return UINib.init(nibName: \"\(nib.name)\", bundle: nil)")]
  let instantiateFunc = Function(name: "instantiateWithOwner", parameters: [ownerOrNilParameter, optionsOrNilParameter], returnType: Type(name: "[AnyObject]"), body: "return instance.instantiateWithOwner(ownerOrNil, options: optionsOrNil)")

  let viewFuncs = zip(nib.rootViews, Ordinals)
    .map { (view: $0.0, ordinal: $0.1) }
    .map { Function(name: "\($0.ordinal.word)View", parameters: [ownerOrNilParameter, optionsOrNilParameter], returnType: $0.view.asOptional(), body: "return instantiateWithOwner(ownerOrNil, options: optionsOrNil)[\($0.ordinal.number - 1)] as? \($0.view)") }

  return Struct(name: nib.name, vars: instanceVars, functions: [instantiateFunc] + viewFuncs, structs: [])
}

// Reuse identifiers

func reuseIdentifierStructFromReusables(reusables: [Reusable]) -> Struct {
  let reuseIdentifierVars = reusables
    .map { Var(name: $0.identifier, type: Type(name: "ReuseIdentifier", genericType: $0.type, optional: false), getter: "return ReuseIdentifier(\"\($0.identifier)\")") }

  return Struct(name: "reuseIdentifier", vars: reuseIdentifierVars, functions: [], structs: [])
}

// Validation

func validateAllFunctionWithStoryboards(storyboards: [Storyboard]) -> Function {
  return Function(name: "validate", parameters: [], returnType: Type._Void, body: join("\n", storyboards.map(swiftCallStoryboardValidators)))
}

func swiftCallStoryboardValidators(storyboard: Storyboard) -> String {
  return
    "storyboard.\(sanitizedSwiftName(storyboard.name)).validateImages()\n" +
    "storyboard.\(sanitizedSwiftName(storyboard.name)).validateViewControllers()"
}
