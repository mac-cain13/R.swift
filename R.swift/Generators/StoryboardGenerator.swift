//
//  Storyboard.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct StoryboardGenerator: Generator {
  let usingModules: Set<Module>
  let externalFunction: Function?
  let externalStruct: Struct?
  let internalStruct: Struct? = nil

  init(storyboards: [Storyboard]) {
    let groupedStoryboards = storyboards.groupUniquesAndDuplicates { sanitizedSwiftName($0.name) }

    for duplicate in groupedStoryboards.duplicates {
      let names = duplicate.map { $0.name }.sort().joinWithSeparator(", ")
      warn("Skipping \(duplicate.count) storyboards because symbol '\(sanitizedSwiftName(duplicate.first!.name))' would be generated for all of these storyboards: \(names)")
    }

    usingModules = Set(storyboards.flatMap { $0.viewControllers.flatMap({ $0.type.module }) })
      .union(["UIKit"])

    externalFunction = StoryboardGenerator.validateAllFunctionWithStoryboards(groupedStoryboards.uniques)
    externalStruct = Struct(
        type: Type(module: .Host, name: "storyboard"),
        implements: [],
        typealiasses: [],
        vars: [],
        functions: [],
        structs: groupedStoryboards.uniques.map(StoryboardGenerator.storyboardStructForStoryboard)
      )
  }

  private static func storyboardStructForStoryboard(storyboard: Storyboard) -> Struct {

    let instanceFunction = Function(
      isStatic: true,
      name: "instantiate",
      generics: nil,
      parameters: [],
      returnType: Type._UIStoryboard,
      body: "return UIStoryboard(name: \"\(storyboard.name)\", bundle: _R.hostingBundle)"
    )

    let initialViewControllerFunction = storyboard.initialViewController
      .map { (vc) -> Function in
        let getterCast = (vc.type.asNonOptional() == Type._UIViewController) ? "" : " as? \(vc.type.asNonOptional())"
        return Function(
          isStatic: true,
          name: "initialViewController",
          generics: nil,
          parameters: [],
          returnType: vc.type.asOptional(),
          body: "return instantiate().instantiateInitialViewController()\(getterCast)"
        )
      }

    let instantiateViewControllerFunctions = storyboard.viewControllers
      .flatMap { (vc) -> Function? in
        let getterCast = (vc.type.asNonOptional() == Type._UIViewController) ? "" : " as? \(vc.type.asNonOptional())"
        return vc.storyboardIdentifier.map {
          Function(
            isStatic: true,
            name: $0,
            generics: nil,
            parameters: [],
            returnType: vc.type.asOptional(),
            body: "return instantiate().instantiateViewControllerWithIdentifier(\"\($0)\")\(getterCast)"
          )
        }
      }

    let validateImagesLines = Set(storyboard.usedImageIdentifiers)
      .map {
        "assert(UIImage(named: \"\($0)\") != nil, \"[R.swift] Image named '\($0)' is used in storyboard '\(storyboard.name)', but couldn't be loaded.\")"
      }
    let validateImagesFunction = Function(
      isStatic: true,
      name: "validateImages",
      generics: nil,
      parameters: [],
      returnType: Type._Void,
      body: validateImagesLines.joinWithSeparator("\n")
    )

    let validateViewControllersLines = storyboard.viewControllers
      .flatMap { vc in
        vc.storyboardIdentifier.map {
          "assert(\(sanitizedSwiftName($0))() != nil, \"[R.swift] ViewController with identifier '\(sanitizedSwiftName($0))' could not be loaded from storyboard '\(storyboard.name)' as '\(vc.type)'.\")"
        }
      }
    let validateViewControllersFunction = Function(
      isStatic: true,
      name: "validateViewControllers",
      generics: nil,
      parameters: [],
      returnType: Type._Void,
      body: validateViewControllersLines.joinWithSeparator("\n")
    )

    return Struct(
      type: Type(module: .Host, name: sanitizedSwiftName(storyboard.name)),
      implements: [],
      typealiasses: [],
      vars: [],
      functions: [
        instanceFunction,
        initialViewControllerFunction,
        validateImagesFunction,
        validateViewControllersFunction
        ].flatMap{$0} + instantiateViewControllerFunctions,
      structs: []
    )
  }

  private static func validateAllFunctionWithStoryboards(storyboards: [Storyboard]) -> Function {
    return Function(isStatic: true, name: "validate", generics: nil, parameters: [], returnType: Type._Void, body: storyboards.map(swiftCallStoryboardValidators).joinWithSeparator("\n"))
  }

  private static func swiftCallStoryboardValidators(storyboard: Storyboard) -> String {
    return
      "storyboard.\(sanitizedSwiftName(storyboard.name)).validateImages()\n" +
    "storyboard.\(sanitizedSwiftName(storyboard.name)).validateViewControllers()"
  }
}
