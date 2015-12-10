//
//  processing.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 06-09-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

func generateResourceStructsWithResources(resources: Resources, bundleIdentifier: String) -> (Struct, Struct) {
  // Generate resource file contents
  let storyboardStructAndFunction = storyboardStructAndFunctionFromStoryboards(resources.storyboards)

  let nibStructs = nibStructFromNibs(resources.nibs)

  let externalResourceStruct = Struct(
    type: Type(name: "R"),
    vars: [],
    functions: [
      storyboardStructAndFunction.1,
    ],
    structs: [
      imageStructFromAssetFolders(resources.assetFolders, andImages: resources.images),
      fontStructFromFonts(resources.fonts),
      segueStructFromStoryboards(resources.storyboards),
      storyboardStructAndFunction.0,
      nibStructs.extern,
      reuseIdentifierStructFromReusables(resources.reusables),
      resourceStructFromResourceFiles(resources.resourceFiles),
    ]
  )

  let internalResourceStruct = Struct(
    type: Type(name: "_R"),
    implements: [],
    vars: [
      Var(isStatic: true, name: "hostingBundle", type: Type._NSBundle.asOptional(), getter: "return NSBundle(identifier: \"\(bundleIdentifier)\")")
    ],
    functions: [],
    structs: [
      nibStructs.intern
    ]
  )

  return (internalResourceStruct, externalResourceStruct)
}
