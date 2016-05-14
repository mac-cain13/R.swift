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
          comments: ["`UIImage(named: \"\($0)\", bundle: ..., traitCollection: ...)`"],
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
          comments: ["`UIImage(named: \"\($0.name)\", bundle: ..., traitCollection: ...)`"],
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
          body: "return \(Type._UIImage.name)(resource: R.image.\(sanitizedSwiftName($0.name))" + (withTrait ? ", compatibleWithTraitCollection: traitCollection)" : ")")
        )
      }

    let allFunctions = assetFolderImageFunctions + imageFunctions
    let groupedFunctions = allFunctions.groupBySwiftNames { $0.name }

    for (sanitizedName, duplicates) in groupedFunctions.duplicates {
      warn("Skipping \(duplicates.count) images because symbol '\(sanitizedName)' would be generated for all of these images: \(duplicates.joinWithSeparator(", "))")
    }

    let empties = groupedFunctions.empties
    if let empty = empties.first where empties.count == 1 {
      warn("Skipping 1 image because no swift identifier can be generated for image: \(empty)")
    }
    else if empties.count > 1 {
      warn("Skipping \(empties.count) images because no swift identifier can be generated for all of these images: \(empties.joinWithSeparator(", "))")
    }

    let imageLets = groupedFunctions
      .uniques
      .map {
        Let(
          comments: ["Image `\($0.name)`."],
          isStatic: true,
          name: $0.name,
          typeDefinition: .Inferred(Type.ImageResource),
          value: "\(Type.ImageResource.name)(bundle: _R.hostingBundle, name: \"\($0.name)\")"
        )
      }

    externalStruct = Struct(
      comments: ["This `R.image` struct is generated, and contains static references to \(imageLets.count) images."],
      type: Type(module: .Host, name: "image"),
      implements: [],
      typealiasses: [],
      properties: imageLets.map(anyProperty),
      functions: groupedFunctions.uniques,
      structs: []
    )
  }
}
