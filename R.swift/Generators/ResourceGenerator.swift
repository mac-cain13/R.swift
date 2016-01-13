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
      FontGenerator(fonts: resources.fonts),
      SegueGenerator(storyboards: resources.storyboards),
      StoryboardGenerator(storyboards: resources.storyboards),
      NibGenerator(nibs: resources.nibs),
      ReuseIdentifierGenerator(reusables: resources.reusables),
      ResourceFileGenerator(resourceFiles: resources.resourceFiles),
    ]

  var generatorResults = GeneratorResults()
  generators.forEach { generatorResults.addGenerator($0) }

  let internalResourceStruct = Struct(
      type: Type(module: .Host, name: "_R"),
      implements: [],
      typealiasses: [],
      properties: [
        Let(isStatic: true, name: "hostingBundle", type: nil, value: "NSBundle(identifier: \"\(bundleIdentifier)\")")
      ],
      functions: [],
      structs: generatorResults.internalStructs
    )
    .addChildStructValidationMethods()

  let privateValidationStruct = Struct(
    accessModifier: .Private,
    type: Type(module: .Host, name: "intern"),
    implements: [Type.Validatable],
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

  let externalResourceStruct = Struct(
      type: Type(module: .Host, name: "R"),
      implements: [],
      typealiasses: [],
      properties: [],
      functions: [],
      structs: generatorResults.externalStructs + [privateValidationStruct]
    )
    .addChildStructValidationMethods()

  return (internalResourceStruct, externalResourceStruct)
}
