//
//  StructGenerator.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 06-09-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

protocol StructGenerator {
  typealias Result = (externalStruct: Struct, internalStruct: Struct?)

  func generatedStructs(at externalAccessLevel: AccessLevel) -> Result
}

protocol ExternalOnlyStructGenerator: StructGenerator {
  func generatedStruct(at externalAccessLevel: AccessLevel) -> Struct
}

extension ExternalOnlyStructGenerator {
  func generatedStructs(at externalAccessLevel: AccessLevel) -> StructGenerator.Result {
    return (
      generatedStruct(at: externalAccessLevel),
      nil
    )
  }
}

func generateResourceStructs(with resources: Resources, at externalAccessLevel: AccessLevel, forBundleIdentifier bundleIdentifier: String) -> StructGenerator.Result {

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

  let aggregatedResult = AggregatedStructGenerator(subgenerators: generators)
    .generatedStructs(at: externalAccessLevel)

  let aggregatedResultWithValidators = ValidatedStructGenerator(validationSubject: aggregatedResult)
    .generatedStructs(at: externalAccessLevel)

  let internalProperties = [
    Let(
      comments: [],
      accessModifier: .FilePrivate,
      isStatic: true,
      name: "hostingBundle",
      typeDefinition: .inferred(Type._Bundle),
      value: "Bundle(identifier: \"\(bundleIdentifier)\") ?? Bundle.main"),
    Let(
      comments: [],
      accessModifier: .FilePrivate,
      isStatic: true,
      name: "applicationLocale",
      typeDefinition: .inferred(Type._Locale),
      value: "hostingBundle.preferredLocalizations.first.flatMap(Locale.init) ?? Locale.current")
  ]

  var externalStruct = aggregatedResultWithValidators.externalStruct
  externalStruct.properties.append(contentsOf: internalProperties)

  return (externalStruct, aggregatedResultWithValidators.internalStruct)
}
