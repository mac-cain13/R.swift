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
  var usingModules: Set<Module> { get }
  var externalFunction: Function? { get }
  var externalStruct: Struct? { get }
  var internalStruct: Struct? { get }
}

private struct GeneratorResults {
  var usingModules: Set<Module> = []
  var externalFunctions: [Function] = []
  var externalStructs: [Struct] = []
  var internalStructs: [Struct] = []

  init() {}

  mutating func addGenerator(generator: Generator) {
    usingModules = usingModules.union(generator.usingModules)

    if let externalFunction = generator.externalFunction {
      externalFunctions.append(externalFunction)
    }

    if let externalStruct = generator.externalStruct {
      externalStructs.append(externalStruct)
    }

    if let internalStruct = generator.internalStruct {
      internalStructs.append(internalStruct)
    }
  }
}

func generateResourceStructsWithResources(resources: Resources, bundleIdentifier: String) -> (Set<Module>, Struct, Struct) {

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
    type: Type(name: "R"),
    implements: [],
    typealiasses: [],
    vars: [],
    functions: generatorResults.externalFunctions,
    structs: generatorResults.externalStructs
  )

  let internalResourceStruct = Struct(
    type: Type(name: "_R"),
    implements: [],
    typealiasses: [],
    vars: [
      Var(isStatic: true, name: "hostingBundle", type: Type._NSBundle.asOptional(), getter: "return NSBundle(identifier: \"\(bundleIdentifier)\")")
    ],
    functions: [],
    structs: generatorResults.internalStructs
  )

  return (generatorResults.usingModules, internalResourceStruct, externalResourceStruct)
}
