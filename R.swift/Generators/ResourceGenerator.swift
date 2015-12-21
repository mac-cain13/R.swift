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

  let externalResourceStruct = Struct(
    type: Type(module: .Host, name: "R"),
    implements: [],
    typealiasses: [],
    vars: [],
    functions: [],
    structs: generatorResults.externalStructs
  )

  let externalResourceStructWithValidation = addChildStructValidationMethods(externalResourceStruct)

  let internalResourceStruct = Struct(
    type: Type(module: .Host, name: "_R"),
    implements: [],
    typealiasses: [],
    vars: [
      Var(isStatic: true, name: "hostingBundle", type: Type._NSBundle.asOptional(), getter: "return NSBundle(identifier: \"\(bundleIdentifier)\")")
    ],
    functions: [],
    structs: generatorResults.internalStructs
  )

  return (internalResourceStruct, externalResourceStructWithValidation)
}

private func addChildStructValidationMethods(origStruct: Struct) -> Struct {
  if origStruct.implements.contains(Type.Validatable) {
    return origStruct
  }

  let innerStructs = origStruct.structs.map(addChildStructValidationMethods)

  let validatableStructs = innerStructs
    .filter{ $0.implements.contains(Type.Validatable) }

  var outputStruct = origStruct
  outputStruct.structs = innerStructs

  if validatableStructs.count > 0 {
    outputStruct.implements.append(Type.Validatable)
    outputStruct.functions.append(
      Function(
        isStatic: true,
        name: "validate",
        generics: nil,
        parameters: [],
        doesThrow: true,
        returnType: Type._Void,
        body: validatableStructs
          .map { "try \($0.type).validate()" }
          .joinWithSeparator("\n")
      )
    )
  }

  return outputStruct
}
