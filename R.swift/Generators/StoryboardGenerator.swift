//
//  StoryboardStructGenerator.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct StoryboardStructGenerator: StructGenerator {
  private let storyboards: [Storyboard]

  init(storyboards: [Storyboard]) {
    self.storyboards = storyboards
  }

  func generatedStructs(at externalAccessLevel: AccessLevel) -> StructGenerator.Result {
    let groupedStoryboards = storyboards.groupedBySwiftIdentifier { $0.name }
    groupedStoryboards.printWarningsForDuplicatesAndEmpties(source: "storyboard", result: "file")

    let storyboardStructs = groupedStoryboards
      .uniques
      .map { storyboardStruct(for: $0, at: externalAccessLevel) }

    let storyboardProperties: [Let] = groupedStoryboards
      .uniques
      .map { storyboard in
        let struct_ = storyboardStruct(for: storyboard, at: externalAccessLevel)

        return Let(
          comments: ["Storyboard `\(storyboard.name)`."],
          accessModifier: externalAccessLevel,
          isStatic: true,
          name: struct_.type.name,
          typeDefinition: .inferred(Type.StoryboardResourceType),
          value: "_R.storyboard.\(struct_.type.name)()"
        )
      }

    let storyboardFunctions: [Function] = groupedStoryboards
      .uniques
      .map { storyboard in
        let struct_ = storyboardStruct(for: storyboard, at: externalAccessLevel)

        return Function(
          comments: ["`UIStoryboard(name: \"\(storyboard.name)\", bundle: ...)`"],
          accessModifier: externalAccessLevel,
          isStatic: true,
          name: struct_.type.name,
          generics: nil,
          parameters: [
            Function.Parameter(name: "_", type: Type._Void, defaultValue: "()")
          ],
          doesThrow: false,
          returnType: Type._UIStoryboard,
          body: "return UIKit.UIStoryboard(resource: R.storyboard.\(struct_.type.name))"
        )
      }

    let externalStruct = Struct(
        comments: ["This `R.storyboard` struct is generated, and contains static references to \(storyboardProperties.count) storyboards."],
        accessModifier: externalAccessLevel,
        type: Type(module: .host, name: "storyboard"),
        implements: [],
        typealiasses: [],
        properties: storyboardProperties,
        functions: storyboardFunctions,
        structs: []
      )

    let internalStruct = Struct(
      comments: [],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: "storyboard"),
      implements: [],
      typealiasses: [],
      properties: [],
      functions: [],
      structs: storyboardStructs
    )

    return (
      externalStruct,
      internalStruct
    )
  }

  private func storyboardStruct(for storyboard: Storyboard, at externalAccessLevel: AccessLevel) -> Struct {
    var implements: [TypePrinter] = []
    var typealiasses: [Typealias] = []
    var functions: [Function] = []
    var properties: [Let] = [
      Let(comments: [], accessModifier: externalAccessLevel, isStatic: false, name: "name", typeDefinition: .inferred(Type._String), value: "\"\(storyboard.name)\""),
      Let(comments: [], accessModifier: externalAccessLevel, isStatic: false, name: "bundle", typeDefinition: .inferred(Type._Bundle), value: "R.hostingBundle")
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
      .groupedBySwiftIdentifier { $0.identifier }

    for (name, duplicates) in groupedViewControllersWithIdentifier.duplicates {
      warn("Skipping \(duplicates.count) view controllers because symbol '\(name)' would be generated for all of these view controller identifiers: \(duplicates.joined(separator: ", "))")
    }

    let viewControllersWithResourceProperty = groupedViewControllersWithIdentifier.uniques
      .map { (vc, identifier) -> (Storyboard.ViewController, Let) in
        (
          vc,
          Let(
            comments: [],
            accessModifier: externalAccessLevel,
            isStatic: false,
            name: SwiftIdentifier(name: identifier),
            typeDefinition: .inferred(Type.StoryboardViewControllerResource),
            value:  "\(Type.StoryboardViewControllerResource.name)<\(vc.type)>(identifier: \"\(identifier)\")"
          )
        )
      }
    viewControllersWithResourceProperty
      .forEach { properties.append($0.1) }

    viewControllersWithResourceProperty
      .map { (vc, resource) in
        Function(
          comments: [],
          accessModifier: externalAccessLevel,
          isStatic: false,
          name: resource.name,
          generics: nil,
          parameters: [
            Function.Parameter(name: "_", type: Type._Void, defaultValue: "()")
          ],
          doesThrow: false,
          returnType: vc.type.asOptional(),
          body: "return UIKit.UIStoryboard(resource: self).instantiateViewController(withResource: \(resource.name))"
        )
      }
      .forEach { functions.append($0) }

    // Validation
    let validateImagesLines = Set(storyboard.usedImageIdentifiers)
      .map {
        "if UIKit.UIImage(named: \"\($0)\") == nil { throw Rswift.ValidationError(description: \"[R.swift] Image named '\($0)' is used in storyboard '\(storyboard.name)', but couldn't be loaded.\") }"
      }
    let validateViewControllersLines = storyboard.viewControllers
      .flatMap { vc in
        vc.storyboardIdentifier.map {
          "if _R.storyboard.\(SwiftIdentifier(name: storyboard.name))().\(SwiftIdentifier(name: $0))() == nil { throw Rswift.ValidationError(description:\"[R.swift] ViewController with identifier '\(SwiftIdentifier(name: $0))' could not be loaded from storyboard '\(storyboard.name)' as '\(vc.type)'.\") }"
        }
      }
    let validateLines = validateImagesLines + validateViewControllersLines

    if validateLines.count > 0 {
      let validateFunction = Function(
        comments: [],
        accessModifier: externalAccessLevel,
        isStatic: true,
        name: "validate",
        generics: nil,
        parameters: [],
        doesThrow: true,
        returnType: Type._Void,
        body: validateLines.joined(separator: "\n")
      )
      functions.append(validateFunction)
      implements.append(TypePrinter(type: Type.Validatable))
    }

    // Return
    return Struct(
      comments: [],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: SwiftIdentifier(name: storyboard.name)),
      implements: implements,
      typealiasses: typealiasses,
      properties: properties,
      functions: functions,
      structs: []
    )
  }
}
