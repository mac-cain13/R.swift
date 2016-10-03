//
//  ResourceGenerator.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 06-09-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

protocol StructGenerator {
  func generateStruct(at externalAccessLevel: AccessModifier) -> Struct?
}

func anyGenerator(generator: StructGenerator) -> StructGenerator {
  return generator
}

func generateResourceStructs(with resources: Resources, at externalAccessLevel: AccessModifier, forBundleIdentifier bundleIdentifier: String) -> (Struct, Struct) {

  let generators: [StructGenerator] = [
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

  var structs = generators
    .flatMap { $0.generateStruct(at: externalAccessLevel) }

  let internalResourceStruct = Struct(
      comments: [],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: "_R"),
      implements: [],
      typealiasses: [],
      properties: [
        Let(
          isStatic: true,
          name: "hostingBundle",
          typeDefinition: .inferred(Type._Bundle),
          value: "Bundle(identifier: \"\(bundleIdentifier)\") ?? Bundle.main"),
        Let(
          isStatic: true,
          name: "applicationLocale",
          typeDefinition: .inferred(Type._Locale),
          value: "hostingBundle.preferredLocalizations.first.flatMap(Locale.init) ?? Locale.current")
      ],
      functions: [],
      structs: []// TODO: generatorResults.internalStructs
    )
    .addChildStructValidationMethods()

  if internalResourceStruct.implements.map({ $0.type }).contains(Type.Validatable) {
    structs.append(Struct(
        comments: [],
        accessModifier: .Private,
        type: Type(module: .host, name: "intern"),
        implements: [TypePrinter(type: Type.Validatable)],
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
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: "R"),
      implements: [],
      typealiasses: [],
      properties: [],
      functions: [],
      structs: structs
    )
    .addChildStructValidationMethods()

  return (internalResourceStruct, externalResourceStruct)
}
