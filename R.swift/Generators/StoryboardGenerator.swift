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
    let groupedStoryboards = storyboards.groupBySwiftIdentifiers { $0.name }
    groupedStoryboards.printWarningsForDuplicatesAndEmpties(source: "storyboard", result: "file")

    let storyboardStructs = groupedStoryboards
      .uniques
      .map(StoryboardGenerator.storyboardStructForStoryboard)

    let storyboardProperties: [Property] = groupedStoryboards
      .uniques
      .map { storyboard in
        let struct_ = StoryboardGenerator.storyboardStructForStoryboard(storyboard)

        return Let(
          comments: ["Storyboard `\(storyboard.name)`."],
          isStatic: true,
          name: struct_.type.name,
          typeDefinition: .Inferred(Type.StoryboardResourceType),
          value: "_R.storyboard.\(struct_.type.name)()"
        )
      }

    let storyboardFunctions: [Function] = groupedStoryboards
      .uniques
      .map { storyboard in
        let struct_ = StoryboardGenerator.storyboardStructForStoryboard(storyboard)

        return Function(
          comments: ["`UIStoryboard(name: \"\(storyboard.name)\", bundle: ...)`"],
          isStatic: true,
          name: struct_.type.name,
          generics: nil,
          parameters: [
            Function.Parameter(name: "_", type: Type._Void)
          ],
          doesThrow: false,
          returnType: Type._UIStoryboard,
          body: "return UIStoryboard(resource: R.storyboard.\(struct_.type.name))"
        )
      }

    externalStruct = Struct(
      comments: ["This `R.storyboard` struct is generated, and contains static references to \(storyboardProperties.count) storyboards."],
        type: Type(module: .Host, name: "storyboard"),
        implements: [],
        typealiasses: [],
        properties: storyboardProperties,
        functions: storyboardFunctions,
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
      .groupBySwiftIdentifiers { $0.identifier }

    for (name, duplicates) in groupedViewControllersWithIdentifier.duplicates {
      warn("Skipping \(duplicates.count) view controllers because symbol '\(name)' would be generated for all of these view controller identifiers: \(duplicates.joinWithSeparator(", "))")
    }

    let viewControllersWithResourceProperty = groupedViewControllersWithIdentifier.uniques
      .map { (vc, identifier) -> (Storyboard.ViewController, Property) in
        (
          vc,
          Let(
            isStatic: false,
            name: SwiftIdentifier(name: identifier),
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
          "if _R.storyboard.\(SwiftIdentifier(name: storyboard.name))().\(SwiftIdentifier(name: $0))() == nil { throw ValidationError(description:\"[R.swift] ViewController with identifier '\(SwiftIdentifier(name: $0))' could not be loaded from storyboard '\(storyboard.name)' as '\(vc.type)'.\") }"
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
      type: Type(module: .Host, name: SwiftIdentifier(name: storyboard.name)),
      implements: implements,
      typealiasses: typealiasses,
      properties: properties,
      functions: functions,
      structs: []
    )
  }
}
