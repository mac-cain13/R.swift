//
//  Storyboard.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct StoryboardGenerator: Generator {
  let externalStruct: Struct?
  let internalStruct: Struct?

  init(storyboards: [Storyboard]) {
    let groupedStoryboards = storyboards.groupBySwiftNames { $0.name }

    for (name, duplicates) in groupedStoryboards.duplicates {
      warn("Skipping \(duplicates.count) storyboards because symbol '\(name)' would be generated for all of these storyboards: \(duplicates.joinWithSeparator(", "))")
    }

    let empties = groupedStoryboards.empties
    if let empty = empties.first where empties.count == 1 {
      warn("Skipping 1 storyboard because no swift identifier can be generated for storyboard: \(empty)")
    }
    else if empties.count > 1 {
      warn("Skipping \(empties.count) storyboards because no swift identifier can be generated for all of these storyboards: \(empties.joinWithSeparator(", "))")
    }

    let storyboardStructs = groupedStoryboards
      .uniques
      .map(StoryboardGenerator.storyboardStructForStoryboard)

    externalStruct = Struct(
        type: Type(module: .Host, name: "storyboard"),
        implements: [],
        typealiasses: [],
        properties: storyboardStructs.map {
          Let(isStatic: true, name: $0.type.name, typeDefinition: .Inferred(Type.StoryboardResourceType), value: "_R.storyboard.\($0.type.name)()")
        },
        functions: storyboardStructs.map {
          Function(
            isStatic: true,
            name: $0.type.name,
            generics: nil,
            parameters: [
              Function.Parameter(name: "_", type: Type._Void)
            ],
            doesThrow: false,
            returnType: Type._UIStoryboard,
            body: "return UIStoryboard(resource: R.storyboard.\($0.type.name))"
          )
        },
        structs: []
      )

    internalStruct = Struct(
      type: Type(module: .Host, name: "storyboard"),
      implements: [],
      typealiasses: [],
      properties: [],
      functions: [],
      structs: storyboardStructs
    )
  }

  private static func storyboardStructForStoryboard(storyboard: Storyboard) -> Struct {

    var implements: [TypePrinter] = []
    var typealiasses: [Typealias] = []
    var functions: [Function] = []

    if let initialViewController = storyboard.initialViewController {
      implements.append(TypePrinter(type: Type.StoryboardResourceWithInitialControllerType))
      typealiasses.append(Typealias(alias: "InitialController", type: initialViewController.type))
    } else {
      implements.append(TypePrinter(type: Type.StoryboardResourceType))
    }

    storyboard.viewControllers
      .flatMap { (vc) -> Function? in
        let getterCast = (vc.type.asNonOptional() == Type._UIViewController) ? "" : " as? \(vc.type.asNonOptional())"
        return vc.storyboardIdentifier.map {
          Function(
            isStatic: false,
            name: $0,
            generics: nil,
            parameters: [],
            doesThrow: false,
            returnType: vc.type.asOptional(),
            body: "return UIStoryboard(resource: self).instantiateViewControllerWithIdentifier(\"\($0)\")\(getterCast)"
          )
        }
      }
      .forEach { functions.append($0) }

    let validateImagesLines = Set(storyboard.usedImageIdentifiers)
      .map {
        "if UIImage(named: \"\($0)\") == nil { throw ValidationError(description: \"[R.swift] Image named '\($0)' is used in storyboard '\(storyboard.name)', but couldn't be loaded.\") }"
      }
    let validateViewControllersLines = storyboard.viewControllers
      .flatMap { vc in
        vc.storyboardIdentifier.map {
          "if _R.storyboard.\(sanitizedSwiftName(storyboard.name))().\(sanitizedSwiftName($0))() == nil { throw ValidationError(description:\"[R.swift] ViewController with identifier '\(sanitizedSwiftName($0))' could not be loaded from storyboard '\(storyboard.name)' as '\(vc.type)'.\") }"
        }
      }
    let validateLines = validateImagesLines + validateViewControllersLines

    if validateLines.count > 0 {
      let validateFunction = Function(
        isStatic: true,
        name: "validate",
        generics: nil,
        parameters: [],
        doesThrow: true,
        returnType: Type._Void,
        body: validateLines.joinWithSeparator("\n")
      )
      functions.append(validateFunction)
      implements.append(TypePrinter(type: Type.Validatable, style: .FullyQualified))
    }

    return Struct(
      type: Type(module: .Host, name: sanitizedSwiftName(storyboard.name)),
      implements: implements,
      typealiasses: typealiasses,
      properties: [
        Let(isStatic: false, name: "name", typeDefinition: .Inferred(Type._String), value: "\"\(storyboard.name)\""),
        Let(isStatic: false, name: "bundle", typeDefinition: .Inferred(Type._NSBundle), value: "_R.hostingBundle"),
      ],
      functions: functions,
      structs: []
    )
  }
}
