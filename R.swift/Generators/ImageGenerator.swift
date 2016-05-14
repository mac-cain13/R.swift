//
//  Image.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct ImageGenerator: Generator {
  let externalStruct: Struct?
  let internalStruct: Struct? = nil

  init(assetFolders: [AssetFolder], images: [Image], withTrait: Bool) {
    let assetFolderImageFunctions = assetFolders
      .flatMap { $0.imageAssets }
      .map {
        Function(
          isStatic: true,
          name: $0,
          generics: nil,
          parameters: withTrait ? [
            Function.Parameter(
              name: "compatibleWithTraitCollection",
              localName: "traitCollection",
              type: Type._UITraitCollection.asOptional(),
              defaultValue: "nil"
              )
          ] : [Function.Parameter(name: "_", type: Type._Void)],
          doesThrow: false,
          returnType: Type._UIImage.asOptional(),
          body: "return UIImage(resource: R.image.\(sanitizedSwiftName($0))" + (withTrait ? ", compatibleWithTraitCollection: traitCollection)" : ")")
        )
      }

    let uniqueImages = images
      .groupBy { $0.name }
      .values
      .flatMap { $0.first }

    let imageFunctions = uniqueImages
      .map {
        Function(
          isStatic: true,
          name: $0.name,
          generics: nil,
          parameters: withTrait ? [
            Function.Parameter(
              name: "compatibleWithTraitCollection",
              localName: "traitCollection",
              type: Type._UITraitCollection.asOptional(),
              defaultValue: "nil"
            )
          ] : [Function.Parameter(name: "_", type: Type._Void)],
          doesThrow: false,
          returnType: Type._UIImage.asOptional(),
          body: "return UIImage(resource: R.image.\(sanitizedSwiftName($0.name))" + (withTrait ? ", compatibleWithTraitCollection: traitCollection)" : ")")
        )
      }

    let functions = (assetFolderImageFunctions + imageFunctions)
      .groupUniquesAndDuplicates { $0.callName }

    for duplicate in functions.duplicates {
      let names = duplicate.map { $0.name }.sort().joinWithSeparator(", ")
      warn("Skipping \(duplicate.count) images because symbol '\(duplicate.first!.callName)' would be generated for all of these images: \(names)")
    }

    let imageLets = functions.uniques
      .map {
        Let(
          isStatic: true,
          name: $0.name,
          typeDefinition: .Inferred(Type.ImageResource),
          value: "ImageResource(bundle: _R.hostingBundle, name: \"\($0.name)\")"
        )
    }

    externalStruct = Struct(
      type: Type(module: .Host, name: "image"),
      implements: [],
      typealiasses: [],
      properties: imageLets.map(anyProperty),
      functions: functions.uniques,
      structs: []
    )
  }
}
