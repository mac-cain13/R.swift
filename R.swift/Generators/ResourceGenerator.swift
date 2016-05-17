//
//  ResourceGenerator.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 06-09-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

protocol Generator {
  var externalStruct: Struct? { get }
  var internalStruct: Struct? { get }
}

private struct GeneratorResults {
  var externalStructs: [Struct] = []
  var internalStructs: [Struct] = []

  init() {}

  mutating func addGenerator(generator: Generator) {
    if let externalStruct = generator.externalStruct {
      externalStructs.append(externalStruct)
    }

    if let internalStruct = generator.internalStruct {
      internalStructs.append(internalStruct)
    }
  }
}

func generateResourceStructsWithResources(resources: Resources, bundleIdentifier: String) -> (Struct, Struct) {

  let generators: [Generator] = [
      ImageGenerator(assetFolders: resources.assetFolders, images: resources.images),
      ColorGenerator(colorPalettes: resources.colors),
      FontGenerator(fonts: resources.fonts),
      SegueGenerator(storyboards: resources.storyboards),
      StoryboardGenerator(storyboards: resources.storyboards),
      NibGenerator(nibs: resources.nibs),
      ReuseIdentifierGenerator(reusables: resources.reusables),
      ResourceFileGenerator(resourceFiles: resources.resourceFiles),
      StringsGenerator(localizableStrings: resources.localizableStrings),
    ]

  var generatorResults = GeneratorResults()
  generators.forEach { generatorResults.addGenerator($0) }

  let internalResourceStruct = Struct(
      type: Type(module: .Host, name: "_R"),
      implements: [],
      typealiasses: [],
      properties: [
        Let(isStatic: true, name: "hostingBundle", typeDefinition: .Inferred(Type._NSBundle), value: "NSBundle(identifier: \"\(bundleIdentifier)\") ?? NSBundle.mainBundle()"),
        Let(isStatic: true, name: "applicationLocale", typeDefinition: .Inferred(Type._NSLocale), value: "hostingBundle.preferredLocalizations.first.flatMap(NSLocale.init) ?? NSLocale.currentLocale()")
      ],
      functions: [],
      structs: generatorResults.internalStructs
    )
    .addChildStructValidationMethods()

  var externalStructs = generatorResults.externalStructs

  if internalResourceStruct.implements.map({ $0.type }).contains(Type.Validatable) {
    externalStructs.append(Struct(
        accessModifier: .Private,
        type: Type(module: .Host, name: "intern"),
        implements: [TypePrinter(type: Type.Validatable, style: .FullyQualified)],
        typealiasses: [],
        properties: [],
        functions: [
          Function(
            isStatic: true,
            name: "validate",
            generics: nil,
            parameters: [],
            doesThrow: true,
            returnType: Type._Void,
            body: "try \(internalResourceStruct.type).validate()"
          )
        ],
        structs: []
      )
    )
  }

  let externalResourceStruct = Struct(
      comments: ["This `R` struct is code generated, and contains references to static resources."],
      type: Type(module: .Host, name: "R"),
      implements: [],
      typealiasses: [],
      properties: [],
      functions: [],
      structs: externalStructs
    )
    .addChildStructValidationMethods()

  return (internalResourceStruct, externalResourceStruct)
}
