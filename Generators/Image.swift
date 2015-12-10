//
//  Image.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

func imageStructFromAssetFolders(assetFolders: [AssetFolder], andImages images: [Image]) -> Struct {
  let assetFolderImageVars = assetFolders
    .flatMap { $0.imageAssets }
    .map { Var(isStatic: true, name: $0, type: Type._UIImage.asOptional(), getter: "return UIImage(named: \"\($0)\", inBundle: _R.hostingBundle, compatibleWithTraitCollection: nil)") }

  let uniqueImages = images
    .groupBy { $0.name }
    .values
    .flatMap { $0.first }

  let imageVars = uniqueImages
    .map { Var(isStatic: true, name: $0.name, type: Type._UIImage.asOptional(), getter: "return UIImage(named: \"\($0.name)\", inBundle: _R.hostingBundle, compatibleWithTraitCollection: nil)") }

  let vars = (assetFolderImageVars + imageVars)
    .groupUniquesAndDuplicates { $0.callName }

  for duplicate in vars.duplicates {
    let names = duplicate.map { $0.name }.sort().joinWithSeparator(", ")
    warn("Skipping \(duplicate.count) images because symbol '\(duplicate.first!.callName)' would be generated for all of these images: \(names)")
  }

  return Struct(
    type: Type(name: "image"),
    implements: [],
    typealiasses: [],
    vars: vars.uniques,
    functions: [],
    structs: []
  )
}
