//
//  StoryboardStructGenerator.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

struct StoryboardStructGenerator: StructGenerator {
  private let storyboards: [Storyboard]

  init(storyboards: [Storyboard]) {
    self.storyboards = storyboards
  }

  func generatedStructs(at externalAccessLevel: AccessLevel, prefix: SwiftIdentifier) -> StructGenerator.Result {
    let structName: SwiftIdentifier = "storyboard"
    let qualifiedName = prefix + structName
    let groupedStoryboards = storyboards.grouped(bySwiftIdentifier: { $0.name })
    groupedStoryboards.printWarningsForDuplicatesAndEmpties(source: "storyboard", result: "file")

    let storyboardTypes = groupedStoryboards
      .uniques
      .map { storyboard -> (Struct, Let, Function) in
        let _struct = storyboardStruct(for: storyboard, at: externalAccessLevel, prefix: qualifiedName)
        let _storyboardName = qualifiedName + _struct.type.name

        let _property = Let(
          comments: ["Storyboard `\(storyboard.name)`."],
          accessModifier: externalAccessLevel,
          isStatic: true,
          name: _struct.type.name,
          typeDefinition: .inferred(Type.StoryboardResourceType),
          value: "_\(_storyboardName)()"
        )

        let _function = Function(
          availables: [],
          comments: ["`UIStoryboard(name: \"\(storyboard.name)\", bundle: ...)`"],
          accessModifier: externalAccessLevel,
          isStatic: true,
          name: _struct.type.name,
          generics: nil,
          parameters: [
            Function.Parameter(name: "_", type: Type._Void, defaultValue: "()")
          ],
          doesThrow: false,
          returnType: Type._UIStoryboard,
          body: "return UIKit.UIStoryboard(resource: R.storyboard.\(_struct.type.name))"
        )

        return (_struct, _property, _function)
      }

    let externalStruct = Struct(
      availables: [],
      comments: ["This `\(qualifiedName)` struct is generated, and contains static references to \(storyboardTypes.count) storyboards."],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: structName),
      implements: [],
      typealiasses: [],
      properties: storyboardTypes.map { $0.1 },
      functions: storyboardTypes.map { $0.2 },
      structs: [],
      classes: []
    )

    let internalStruct = Struct(
      availables: [],
      comments: [],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: structName),
      implements: [],
      typealiasses: [],
      properties: [],
      functions: [],
      structs: storyboardTypes.map { $0.0 },
      classes: []
    )

    return (
      externalStruct,
      internalStruct
    )
  }

  private func storyboardStruct(for storyboard: Storyboard, at externalAccessLevel: AccessLevel, prefix: SwiftIdentifier) -> Struct {
    let structName = SwiftIdentifier(name: storyboard.name)
    let qualifiedName = prefix + structName

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
      typealiasses.append(Typealias(accessModifier: externalAccessLevel, alias: "InitialController", type: initialViewController.type))
    } else {
      implements.append(TypePrinter(type: Type.StoryboardResourceType))
    }

    // View controllers with identifiers
    let groupedViewControllersWithIdentifier = storyboard.viewControllers
      .compactMap { (vc) -> (vc: Storyboard.ViewController, identifier: String)? in
        guard let storyboardIdentifier = vc.storyboardIdentifier else { return nil }
        return (vc, storyboardIdentifier)
      }
      .grouped(bySwiftIdentifier: { $0.identifier })

    for (name, duplicates) in groupedViewControllersWithIdentifier.duplicates {
      warn("Skipping \(duplicates.count) view controllers because symbol '\(name)' would be generated for all of these view controller identifiers: \(duplicates.joined(separator: ", "))")
    }

    let viewControllersWithResourceProperty = groupedViewControllersWithIdentifier.uniques
      .map { arg -> (Storyboard.ViewController, Let) in
        let (viewController, identifier) = arg
        return (
          viewController,
          Let(
            comments: [],
            accessModifier: externalAccessLevel,
            isStatic: false,
            name: SwiftIdentifier(name: identifier),
            typeDefinition: .inferred(Type.StoryboardViewControllerResource),
            value:  "\(Type.StoryboardViewControllerResource.name)<\(viewController.type)>(identifier: \"\(identifier)\")"
          )
        )
      }
    viewControllersWithResourceProperty
      .forEach { properties.append($0.1) }

    viewControllersWithResourceProperty
      .map { arg in
        let (vc, resource) = arg
        return Function(
          availables: [],
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
    let validateImagesLines = storyboard.usedImageIdentifiers.uniqueAndSorted()
      .map {
        "if UIKit.UIImage(named: \"\($0)\") == nil { throw Rswift.ValidationError(description: \"[R.swift] Image named '\($0)' is used in storyboard '\(storyboard.name)', but couldn't be loaded.\") }"
      }
    let validateColorLines = storyboard.usedColorResources.uniqueAndSorted()
      .map {
        "if UIKit.UIColor(named: \"\($0)\") == nil { throw Rswift.ValidationError(description: \"[R.swift] Color named '\($0)' is used in storyboard '\(storyboard.name)', but couldn't be loaded.\") }"
      }
    let validateColorLinesWithAvailableIf = ["if #available(iOS 11.0, *) {"] +
      validateColorLines.map { $0.indent(with: "  ") } +
      ["}"]
    let validateViewControllersLines = groupedViewControllersWithIdentifier.uniques
      .compactMap { arg -> String? in
        let (vc, _) = arg
        guard let storyboardName = vc.storyboardIdentifier else { return nil }
        let storyboardIdentifier = SwiftIdentifier(name: storyboardName)
        return "if _\(qualifiedName)().\(storyboardIdentifier)() == nil { throw Rswift.ValidationError(description:\"[R.swift] ViewController with identifier '\(storyboardIdentifier)' could not be loaded from storyboard '\(storyboard.name)' as '\(vc.type)'.\") }"
      }
    let validateLines = validateImagesLines + validateColorLinesWithAvailableIf + validateViewControllersLines

    if validateLines.count > 0 {
      let validateFunction = Function(
        availables: [],
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
      availables: [],
      comments: [],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: structName),
      implements: implements,
      typealiasses: typealiasses,
      properties: properties,
      functions: functions,
      structs: [],
      classes: []
    )
  }
}
