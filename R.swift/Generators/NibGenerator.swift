//
//  Nib.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

private let Ordinals = [
  (number: 1, word: "first"),
  (number: 2, word: "second"),
  (number: 3, word: "third"),
  (number: 4, word: "fourth"),
  (number: 5, word: "fifth"),
  (number: 6, word: "sixth"),
  (number: 7, word: "seventh"),
  (number: 8, word: "eighth"),
  (number: 9, word: "ninth"),
  (number: 10, word: "tenth"),
  (number: 11, word: "eleventh"),
  (number: 12, word: "twelfth"),
  (number: 13, word: "thirteenth"),
  (number: 14, word: "fourteenth"),
  (number: 15, word: "fifteenth"),
  (number: 16, word: "sixteenth"),
  (number: 17, word: "seventeenth"),
  (number: 18, word: "eighteenth"),
  (number: 19, word: "nineteenth"),
  (number: 20, word: "twentieth"),
]

struct NibGenerator: Generator {
  let externalStruct: Struct?
  let internalStruct: Struct?

  init(nibs: [Nib]) {
    let groupedNibs = nibs.groupUniquesAndDuplicates { sanitizedSwiftName($0.name) }

    for duplicate in groupedNibs.duplicates {
      let names = duplicate.map { $0.name }.sort().joinWithSeparator(", ")
      warn("Skipping \(duplicate.count) xibs because symbol '\(sanitizedSwiftName(duplicate.first!.name))' would be generated for all of these xibs: \(names)")
    }

    internalStruct = Struct(
        type: Type(module: .Host, name: "nib"),
        implements: [],
        typealiasses: [],
        properties: [],
        functions: [],
        structs: groupedNibs
          .uniques
          .map(NibGenerator.nibStructForNib)
      )

    externalStruct = Struct(
        type: Type(module: .Host, name: "nib"),
        implements: [],
        typealiasses: [],
        properties: groupedNibs
          .uniques
          .map(NibGenerator.nibVarForNib),
        functions: [],
        structs: []
      )
  }

  private static func nibVarForNib(nib: Nib) -> Let {
    let nibStructName = sanitizedSwiftName("_\(nib.name)")
    let structType = Type(module: .Host, name: "_R.nib.\(nibStructName)")
    return Let(isStatic: true, name: nib.name, type: nil, value: "\(structType)()")
  }

  private static func nibStructForNib(nib: Nib) -> Struct {

    let instantiateParameters = [
      Function.Parameter(name: "ownerOrNil", type: Type._AnyObject.asOptional()),
      Function.Parameter(name: "options", localName: "optionsOrNil", type: Type(module: .StdLib, name: "[NSObject : AnyObject]", optional: true))
    ]

    let bundleLet: Property = Let(
      isStatic: false,
      name: "bundle",
      type: nil,
      value: "_R.hostingBundle"
    )

    let nameVar: Property = Let(
      isStatic: false,
      name: "name",
      type: nil,
      value: "\"\(nib.name)\""
    )

    let viewFuncs = zip(nib.rootViews, Ordinals)
      .map { (view: $0.0, ordinal: $0.1) }
      .map {
        Function(
          isStatic: false,
          name: "\($0.ordinal.word)View",
          generics: nil,
          parameters: instantiateParameters,
          doesThrow: false,
          returnType: $0.view.asOptional(),
          body: "return instantiateWithOwner(ownerOrNil, options: optionsOrNil)[\($0.ordinal.number - 1)] as? \($0.view)"
        )
      }

    let reuseIdentifierProperties: [Property]
    let reuseProtocols: [Type]
    let reuseTypealiasses: [Typealias]
    if let reusable = nib.reusables.first where nib.rootViews.count == 1 && nib.reusables.count == 1 {
      reuseIdentifierProperties = [Let(
        isStatic: false,
        name: "identifier",
        type: nil,
        value: "\"\(reusable.identifier)\""
        )]
      reuseTypealiasses = [Typealias(alias: "ReusableType", type: reusable.type)]
      reuseProtocols = [Type.ReuseIdentifierProtocol]
    } else {
      reuseIdentifierProperties = []
      reuseTypealiasses = []
      reuseProtocols = []
    }

    let sanitizedName = sanitizedSwiftName(nib.name, lowercaseFirstCharacter: false)
    return Struct(
        type: Type(module: .Host, name: "_\(sanitizedName)"),
        implements: [Type.NibResourceProtocol] + reuseProtocols,
        typealiasses: reuseTypealiasses,
        properties: [bundleLet, nameVar] + reuseIdentifierProperties,
        functions: viewFuncs,
        structs: []
      )
  }
}
