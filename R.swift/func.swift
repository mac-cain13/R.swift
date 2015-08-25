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
  print("warning: [R.swift] \(warning)")
}

func fail(error: String) {
  print("error: [R.swift] \(error)")
}

func fail<T: ErrorType where T: CustomStringConvertible>(error: T) {
  fail("\(error)")
}

func inputDirectories(processInfo: NSProcessInfo) -> [NSURL] {
  return processInfo.arguments.skip(1).map { NSURL(fileURLWithPath: $0) }
}

func filterDirectoryContentsRecursively(fileManager: NSFileManager, filter: (NSURL) -> Bool)(url: NSURL) -> [NSURL] {
  var assetFolders = [NSURL]()

  let errorHandler: (NSURL!, NSError!) -> Bool = { url, error in
    fail(error)
    return true
  }

  if let enumerator = fileManager.enumeratorAtURL(url, includingPropertiesForKeys: [NSURLIsDirectoryKey], options: [NSDirectoryEnumerationOptions.SkipsHiddenFiles, NSDirectoryEnumerationOptions.SkipsPackageDescendants], errorHandler: errorHandler) {

    while let enumeratorItem: AnyObject = enumerator.nextObject() {
      if let url = enumeratorItem as? NSURL where filter(url) {
        assetFolders.append(url)
      }
    }

  }

  return assetFolders
}

func sanitizedSwiftName(name: String, lowercaseFirstCharacter: Bool = true) -> String {
  var components = name.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: " -"))
  let firstComponent = components.removeAtIndex(0)
  let swiftName = components.reduce(firstComponent) { $0 + $1.capitalizedString }
  let capitalizedSwiftName = lowercaseFirstCharacter ? swiftName.lowercaseFirstCharacter : swiftName

  return SwiftKeywords.contains(capitalizedSwiftName) ? "`\(capitalizedSwiftName)`" : capitalizedSwiftName
}

func writeResourceFile(code: String, toFolderURL folderURL: NSURL) {
  let outputURL = folderURL.URLByAppendingPathComponent(ResourceFilename)

  do {
    try code.writeToURL(outputURL, atomically: true, encoding: NSUTF8StringEncoding)
  } catch let error as NSError {
    fail(error)
  }
}

func readResourceFile(folderURL: NSURL) -> String? {
  let inputURL = folderURL.URLByAppendingPathComponent(ResourceFilename)

  do {
    let resourceFileString = try String(contentsOfURL: inputURL, encoding: NSUTF8StringEncoding)
    return resourceFileString
  } catch {
    return nil
  }
}

// MARK: Struct/function generators

// Image

func imageStructFromAssetFolders(assetFolders: [AssetFolder]) -> Struct {
  let vars = assetFolders
    .flatMap { $0.imageAssets }
    .map { Var(isStatic: true, name: $0, type: Type._UIImage.asOptional(), getter: "return UIImage(named: \"\($0)\")") }
    .groupUniquesAndDuplicates { $0.callName }

  for duplicate in vars.duplicates {
    let names = duplicate.map { $0.name }.joinWithSeparator(", ")
    warn("Skipping \(duplicate.count) images because symbol '\(duplicate.first!.callName)' would be generated for all of these images: \(names)")
  }

  return Struct(type: Type(name: "image"), lets: [], vars: vars.uniques, functions: [], structs: [])
}

// Segue

func segueStructFromStoryboards(storyboards: [Storyboard]) -> Struct {
  let vars = Array(Set(storyboards.flatMap { $0.segues }))
    .map { Var(isStatic: true, name: $0, type: Type._String, getter: "return \"\($0)\"") }

  return Struct(type: Type(name: "segue"), lets: [], vars: vars, functions: [], structs: [])
}

// Storyboard

func storyboardStructAndFunctionFromStoryboards(storyboards: [Storyboard]) -> (Struct, Function) {
  let groupedStoryboards = storyboards.groupUniquesAndDuplicates { sanitizedSwiftName($0.name) }

  for duplicate in groupedStoryboards.duplicates {
    let names = duplicate.map { $0.name }.joinWithSeparator(", ")
    warn("Skipping \(duplicate.count) storyboards because symbol '\(sanitizedSwiftName(duplicate.first!.name))' would be generated for all of these storyboards: \(names)")
  }

  return (
    Struct(type: Type(name: "storyboard"), lets: [], vars: [], functions: [], structs: groupedStoryboards.uniques.map(storyboardStructForStoryboard)),
    validateAllFunctionWithStoryboards(groupedStoryboards.uniques)
  )
}

func storyboardStructForStoryboard(storyboard: Storyboard) -> Struct {
  let instanceVars = [Var(isStatic: true, name: "instance", type: Type._UIStoryboard, getter: "return UIStoryboard(name: \"\(storyboard.name)\", bundle: nil)")]


  let initialViewControllerVar = catOptionals([storyboard.initialViewController.map { (vc) -> Var in
    let getterCast = (vc.type.asNonOptional() == Type._UIViewController) ? "" : " as? \(vc.type.asNonOptional())"
    return Var(isStatic: true, name: "initialViewController", type: vc.type.asOptional(), getter: "return instance.instantiateInitialViewController()\(getterCast)")
  }])

  let viewControllerVars = catOptionals(storyboard.viewControllers
    .map { (vc) -> Var? in
      let getterCast = (vc.type.asNonOptional() == Type._UIViewController) ? "" : " as? \(vc.type.asNonOptional())"
      return vc.storyboardIdentifier.map {
        return Var(isStatic: true, name: $0, type: vc.type.asOptional(), getter: "return instance.instantiateViewControllerWithIdentifier(\"\($0)\")\(getterCast)")
      }
    })

  let validateImagesLines = Array(Set(storyboard.usedImageIdentifiers))
    .map { "assert(UIImage(named: \"\($0)\") != nil, \"[R.swift] Image named '\($0)' is used in storyboard '\(storyboard.name)', but couldn't be loaded.\")" }
  let validateImagesFunc = Function(isStatic: true, name: "validateImages", generics: nil, parameters: [], returnType: Type._Void, body: validateImagesLines.joinWithSeparator("\n"))

  let validateViewControllersLines = catOptionals(storyboard.viewControllers
    .map { vc in
      vc.storyboardIdentifier.map {
        "assert(\(sanitizedSwiftName($0)) != nil, \"[R.swift] ViewController with identifier '\(sanitizedSwiftName($0))' could not be loaded from storyboard '\(storyboard.name)' as '\(vc.type)'.\")"
      }
    })
  let validateViewControllersFunc = Function(isStatic: true, name: "validateViewControllers", generics: nil, parameters: [], returnType: Type._Void, body: validateViewControllersLines.joinWithSeparator("\n"))

  return Struct(type: Type(name: sanitizedSwiftName(storyboard.name)), lets: [], vars: instanceVars + initialViewControllerVar + viewControllerVars, functions: [validateImagesFunc, validateViewControllersFunc], structs: [])
}

func validateAllFunctionWithStoryboards(storyboards: [Storyboard]) -> Function {
  return Function(isStatic: true, name: "validate", generics: nil, parameters: [], returnType: Type._Void, body: storyboards.map(swiftCallStoryboardValidators).joinWithSeparator("\n"))
}

func swiftCallStoryboardValidators(storyboard: Storyboard) -> String {
  return
    "storyboard.\(sanitizedSwiftName(storyboard.name)).validateImages()\n" +
    "storyboard.\(sanitizedSwiftName(storyboard.name)).validateViewControllers()"
}

// Nib

func nibStructFromNibs(nibs: [Nib]) -> (intern: Struct, extern: Struct) {
  let groupedNibs = nibs.groupUniquesAndDuplicates { sanitizedSwiftName($0.name) }

  for duplicate in groupedNibs.duplicates {
    let names = duplicate.map { $0.name }.joinWithSeparator(", ")
    warn("Skipping \(duplicate.count) xibs because symbol '\(sanitizedSwiftName(duplicate.first!.name))' would be generated for all of these xibs: \(names)")
  }

  return (
    intern: Struct(type: Type(name: "nib"), lets: [], vars: [], functions: [], structs: groupedNibs.uniques.map(nibStructForNib)),
    extern: Struct(type: Type(name: "nib"), lets: [], vars: groupedNibs.uniques.map(nibVarForNib), functions: [], structs: [])
  )
}

func nibVarForNib(nib: Nib) -> Var {
  let nibStructName = sanitizedSwiftName("_\(nib.name)")
  let structType = Type(name: "_R.nib.\(nibStructName)")
  return Var(isStatic: true, name: nib.name, type: structType, getter: "return \(structType)()")
}

func nibStructForNib(nib: Nib) -> Struct {

  let instantiateParameters = [
    Function.Parameter(name: "ownerOrNil", type: Type._AnyObject.asOptional()),
    Function.Parameter(name: "options", localName: "optionsOrNil", type: Type(name: "[NSObject : AnyObject]", optional: true))
  ]

  let nameVar = Var(
    isStatic: true,
    name: "name",
    type: Type._String,
    getter: "return \"\(nib.name)\""
  )

  let instanceVar = Var(
    isStatic: false,
    name: "instance",
    type: Type._UINib,
    getter: "return UINib.init(nibName: \"\(nib.name)\", bundle: nil)"
  )

  let instantiateFunc = Function(
    isStatic: false,
    name: "instantiateWithOwner",
    generics: nil,
    parameters: instantiateParameters,
    returnType: Type(name: "[AnyObject]"),
    body: "return instance.instantiateWithOwner(ownerOrNil, options: optionsOrNil)"
  )

  let viewFuncs = zip(nib.rootViews, Ordinals)
    .map { (view: $0.0, ordinal: $0.1) }
    .map {
      Function(
        isStatic: false,
        name: "\($0.ordinal.word)View",
        generics: nil,
        parameters: instantiateParameters,
        returnType: $0.view.asOptional(),
        body: "return \(instantiateFunc.callName)(ownerOrNil, options: optionsOrNil)[\($0.ordinal.number - 1)] as? \($0.view)"
      )
    }

  let reuseIdentifierVars: [Var]
  let reuseProtocols: [Type]
  if let reusable = nib.reusables.first where nib.rootViews.count == 1 && nib.reusables.count == 1 {
    let reusableVar = varFromReusable(reusable)
    reuseIdentifierVars = [Var(
      isStatic: false,
      name: "reuseIdentifier",
      type: reusableVar.type,
      getter: reusableVar.getter
    )]
    reuseProtocols = [ReusableProtocol.type]
  } else {
    reuseIdentifierVars = []
    reuseProtocols = []
  }

  let sanitizedName = sanitizedSwiftName(nib.name, lowercaseFirstCharacter: false)
  return Struct(
    type: Type(name: "_\(sanitizedName)"),
    implements: [NibResourceProtocol.type] + reuseProtocols,
    lets: [],
    vars: [nameVar, instanceVar] + reuseIdentifierVars,
    functions: [instantiateFunc] + viewFuncs,
    structs: []
  )
}

// Reuse identifiers

func reuseIdentifierStructFromReusables(reusables: [Reusable]) -> Struct {
  let groupedReusables = reusables.groupUniquesAndDuplicates { sanitizedSwiftName($0.identifier) }

  for duplicate in groupedReusables.duplicates {
    let names = duplicate.map { $0.identifier }.joinWithSeparator(", ")
    warn("Skipping \(duplicate.count) reuseIdentifiers because symbol '\(sanitizedSwiftName(duplicate.first!.identifier))' would be generated for all of these reuseIdentifiers: \(names)")
  }

  let reuseIdentifierVars = groupedReusables.uniques.map(varFromReusable)
  return Struct(type: Type(name: "reuseIdentifier"), lets: [], vars: reuseIdentifierVars, functions: [], structs: [])
}

func varFromReusable(reusable: Reusable) -> Var {
  return Var(
    isStatic: true,
    name: reusable.identifier,
    type: ReuseIdentifier.type.withGenericType(reusable.type),
    getter: "return \(ReuseIdentifier.type.name)(identifier: \"\(reusable.identifier)\")"
  )
}
