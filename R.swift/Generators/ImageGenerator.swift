//
//  Image.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct ImageGenerator: StructGenerator {
  private let assetFolders: [AssetFolder]
  private let images: [Image]

  init(assetFolders: [AssetFolder], images: [Image]) {
    self.assetFolders = assetFolders
    self.images = images
  }

  func generateStruct(at externalAccessLevel: AccessModifier) -> Struct? {
    let assetFolderImageNames = assetFolders
      .flatMap { $0.imageAssets }


    let imagesNames = images
      .groupBy { $0.name }
      .values
      .flatMap { $0.first?.name }

    let allFunctions = assetFolderImageNames + imagesNames
    let groupedFunctions = allFunctions.groupedBySwiftIdentifier { $0 }

    groupedFunctions.printWarningsForDuplicatesAndEmpties(source: "image", result: "image")

    let imageLets = groupedFunctions
      .uniques
      .map { name in
        Let(
          comments: ["Image `\(name)`."],
          accessModifier: externalAccessLevel,
          isStatic: true,
          name: SwiftIdentifier(name: name),
          typeDefinition: .inferred(Type.ImageResource),
          value: "Rswift.ImageResource(bundle: _R.hostingBundle, name: \"\(name)\")"
        )
      }

    return Struct(
      comments: ["This `R.image` struct is generated, and contains static references to \(imageLets.count) images."],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: "image"),
      implements: [],
      typealiasses: [],
      properties: imageLets,
      functions: groupedFunctions.uniques.map(imageFunction),
      structs: []
    )
  }

  private func imageFunction(for name: String) -> Function {
    return Function(
      comments: ["`UIImage(named: \"\(name)\", bundle: ..., traitCollection: ...)`"],
      isStatic: true,
      name: SwiftIdentifier(name: name),
      generics: nil,
      parameters: [
        Function.Parameter(
          name: "compatibleWith",
          localName: "traitCollection",
          type: Type._UITraitCollection.asOptional(),
          defaultValue: "nil"
        )
      ],
      doesThrow: false,
      returnType: Type._UIImage.asOptional(),
      body: "return UIKit.UIImage(resource: R.image.\(SwiftIdentifier(name: name)), compatibleWith: traitCollection)"
    )
  }
}
