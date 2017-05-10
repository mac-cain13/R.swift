//
//  ImageStructGenerator.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

struct ImageStructGenerator: ExternalOnlyStructGenerator {
  private let assetFolders: [AssetFolder]
  private let images: [Image]

  init(assetFolders: [AssetFolder], images: [Image]) {
    self.assetFolders = assetFolders
    self.images = images
  }

  func generatedStruct(at externalAccessLevel: AccessLevel) -> Struct {
    let assetFolderImageNames = assetFolders
      .flatMap { $0.imageAssets }

    let imagesNames = images
      .grouped { $0.name }
      .values
      .flatMap { $0.first?.name }

    let allFunctions = assetFolderImageNames + imagesNames
    let groupedFunctions = allFunctions.groupedBySwiftIdentifier { $0 }

    let assetSubfolders = assetFolders
      .flatMap { $0.subfolders }
      .mergeDuplicates(recursive: true)
      .removeConflicting(with: allFunctions)

    let structs = assetSubfolders
      .map { $0.generatedStruct(at: externalAccessLevel) }

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
          value: "Rswift.ImageResource(bundle: R.hostingBundle, name: \"\(name)\")"
        )
      }

    return Struct(
      comments: ["This `R.image` struct is generated, and contains static references to \(imageLets.count) images."],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: "image"),
      implements: [],
      typealiasses: [],
      properties: imageLets,
      functions: groupedFunctions.uniques.map { imageFunction(for: $0, at: externalAccessLevel) },
      structs: structs,
      classes: []
    )
  }

  private func imageFunction(for name: String, at externalAccessLevel: AccessLevel) -> Function {
    return Function(
      comments: ["`UIImage(named: \"\(name)\", bundle: ..., traitCollection: ...)`"],
      accessModifier: externalAccessLevel,
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

fileprivate extension Array where Element: NamespacedAssetSubfolder {
    func mergeDuplicates(recursive: Bool) -> [Element] {
        var dict = [String: Element]()

        self.forEach { subfolder in
            if let duplicate = dict[subfolder.name], recursive {
                duplicate.subfolders = (duplicate.subfolders + subfolder.subfolders).mergeDuplicates(recursive: true)
            } else if let duplicate = dict[subfolder.name] {
                duplicate.subfolders = duplicate.subfolders + subfolder.subfolders
            } else {
                dict[subfolder.name] = subfolder
            }
        }

        return dict.values.map { $0 }
    }

    func removeConflicting(with allFunctions: [String]) -> [Element] {
        let uniques = self.filter { !allFunctions.contains($0.name)  }
        let duplicates = self.filter { allFunctions.contains($0.name)  }

        for subfolder in duplicates {
            warn("Skipping asset subfolder because symbol '\(subfolder.name)' would conflict with image: \(subfolder.name)")
        }

        return uniques
    }
}

