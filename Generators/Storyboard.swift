//
//  Storyboard.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

func storyboardStructAndFunctionFromStoryboards(storyboards: [Storyboard]) -> (Struct, Function) {
  let groupedStoryboards = storyboards.groupUniquesAndDuplicates { sanitizedSwiftName($0.name) }

  for duplicate in groupedStoryboards.duplicates {
    let names = duplicate.map { $0.name }.sort().joinWithSeparator(", ")
    warn("Skipping \(duplicate.count) storyboards because symbol '\(sanitizedSwiftName(duplicate.first!.name))' would be generated for all of these storyboards: \(names)")
  }

  return (
    Struct(
      type: Type(name: "storyboard"),
      implements: [],
      typealiasses: [],
      vars: [],
      functions: [],
      structs: groupedStoryboards.uniques.map(storyboardStructForStoryboard)
    ),
    validateAllFunctionWithStoryboards(groupedStoryboards.uniques)
  )
}

func storyboardStructForStoryboard(storyboard: Storyboard) -> Struct {
  let instanceVars = [Var(isStatic: true, name: "instance", type: Type._UIStoryboard, getter: "return UIStoryboard(name: \"\(storyboard.name)\", bundle: _R.hostingBundle)")]

  let initialViewControllerVar = [storyboard.initialViewController
    .map { (vc) -> Var in
      let getterCast = (vc.type.asNonOptional() == Type._UIViewController) ? "" : " as? \(vc.type.asNonOptional())"
      return Var(isStatic: true, name: "initialViewController", type: vc.type.asOptional(), getter: "return instance.instantiateInitialViewController()\(getterCast)")
    }
    ].flatMap { $0 }

  let viewControllerVars = storyboard.viewControllers
    .flatMap { (vc) -> Var? in
      let getterCast = (vc.type.asNonOptional() == Type._UIViewController) ? "" : " as? \(vc.type.asNonOptional())"
      return vc.storyboardIdentifier.map {
        return Var(isStatic: true, name: $0, type: vc.type.asOptional(), getter: "return instance.instantiateViewControllerWithIdentifier(\"\($0)\")\(getterCast)")
      }
  }

  let validateImagesLines = Array(Set(storyboard.usedImageIdentifiers))
    .map { "assert(UIImage(named: \"\($0)\") != nil, \"[R.swift] Image named '\($0)' is used in storyboard '\(storyboard.name)', but couldn't be loaded.\")" }
  let validateImagesFunc = Function(isStatic: true, name: "validateImages", generics: nil, parameters: [], returnType: Type._Void, body: validateImagesLines.joinWithSeparator("\n"))

  let validateViewControllersLines = storyboard.viewControllers
    .flatMap { vc in
      vc.storyboardIdentifier.map {
        "assert(\(sanitizedSwiftName($0)) != nil, \"[R.swift] ViewController with identifier '\(sanitizedSwiftName($0))' could not be loaded from storyboard '\(storyboard.name)' as '\(vc.type)'.\")"
      }
  }
  let validateViewControllersFunc = Function(isStatic: true, name: "validateViewControllers", generics: nil, parameters: [], returnType: Type._Void, body: validateViewControllersLines.joinWithSeparator("\n"))

  return Struct(
    type: Type(name: sanitizedSwiftName(storyboard.name)),
    implements: [],
    typealiasses: [],
    vars: instanceVars + initialViewControllerVar + viewControllerVars,
    functions: [validateImagesFunc, validateViewControllersFunc],
    structs: []
  )
}

func validateAllFunctionWithStoryboards(storyboards: [Storyboard]) -> Function {
  return Function(isStatic: true, name: "validate", generics: nil, parameters: [], returnType: Type._Void, body: storyboards.map(swiftCallStoryboardValidators).joinWithSeparator("\n"))
}

func swiftCallStoryboardValidators(storyboard: Storyboard) -> String {
  return
    "storyboard.\(sanitizedSwiftName(storyboard.name)).validateImages()\n" +
  "storyboard.\(sanitizedSwiftName(storyboard.name)).validateViewControllers()"
}
