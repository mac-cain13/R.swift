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
    let groupedStoryboards = storyboards.groupUniquesAndDuplicates { sanitizedSwiftName($0.name) }

    for duplicate in groupedStoryboards.duplicates {
      let names = duplicate.map { $0.name }.sort().joinWithSeparator(", ")
      warn("Skipping \(duplicate.count) storyboards because symbol '\(sanitizedSwiftName(duplicate.first!.name))' would be generated for all of these storyboards: \(names)")
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
    var properties: [Property] = [
      Let(isStatic: false, name: "name", typeDefinition: .Inferred(Type._String), value: "\"\(storyboard.name)\""),
      Let(isStatic: false, name: "bundle", typeDefinition: .Inferred(Type._NSBundle), value: "_R.hostingBundle")
    ]

    // Initial view controller
    if let initialViewController = storyboard.initialViewController {
      implements.append(TypePrinter(type: Type.StoryboardResourceWithInitialControllerType))
      typealiasses.append(Typealias(alias: "InitialController", type: initialViewController.type))
    } else {
      implements.append(TypePrinter(type: Type.StoryboardResourceType))
    }

    // View controllers with identifiers
    let groupedViewControllersWithIdentifier = storyboard.viewControllers
      .flatMap { (vc) -> (vc: Storyboard.ViewController, identifier: String)? in
        guard let storyboardIdentifier = vc.storyboardIdentifier else { return nil }
        return (vc, storyboardIdentifier)
      }
      .groupUniquesAndDuplicates { sanitizedSwiftName($0.identifier) }

    for duplicate in groupedViewControllersWithIdentifier.duplicates {
      let identifiers = duplicate.flatMap { $0.vc.storyboardIdentifier }.sort().joinWithSeparator(", ")
      warn("Skipping \(duplicate.count) view controllers from storyboard \"\(storyboard.name)\" because symbol '\(sanitizedSwiftName(duplicate.first!.identifier))' would be generated for all of these view controller identifiers: \(identifiers)")
    }

    let viewControllersWithResourceProperty = groupedViewControllersWithIdentifier.uniques
      .map { (vc, identifier) -> (Storyboard.ViewController, Property) in
        (
          vc,
          Let(
            isStatic: false,
            name: sanitizedSwiftName(identifier),
            typeDefinition: .Inferred(Type.StoryboardViewControllerResource),
            value:  "\(Type.StoryboardViewControllerResource.name)<\(vc.type)>(identifier: \"\(identifier)\")"
          )
        )
      }
    viewControllersWithResourceProperty
      .forEach { properties.append($0.1) }

    viewControllersWithResourceProperty
      .map { (vc, resource) in
        Function(
          isStatic: false,
          name: resource.name,
          generics: nil,
          parameters: [
            Function.Parameter(name: "_", type: Type._Void)
          ],
          doesThrow: false,
          returnType: vc.type.asOptional(),
          body: "return UIStoryboard(resource: self).instantiateViewController(\(resource.name))"
        )
      }
      .forEach { functions.append($0) }

    // Validation
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

    // Return
    return Struct(
      type: Type(module: .Host, name: sanitizedSwiftName(storyboard.name)),
      implements: implements,
      typealiasses: typealiasses,
      properties: properties,
      functions: functions,
      structs: []
    )
  }
}
