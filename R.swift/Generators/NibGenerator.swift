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

func nibStructFromNibs(nibs: [Nib]) -> (intern: Struct, extern: Struct) {
  let groupedNibs = nibs.groupUniquesAndDuplicates { sanitizedSwiftName($0.name) }

  for duplicate in groupedNibs.duplicates {
    let names = duplicate.map { $0.name }.sort().joinWithSeparator(", ")
    warn("Skipping \(duplicate.count) xibs because symbol '\(sanitizedSwiftName(duplicate.first!.name))' would be generated for all of these xibs: \(names)")
  }

  return (
    intern: Struct(
      type: Type(name: "nib"),
      implements: [],
      typealiasses: [],
      vars: [],
      functions: [],
      structs: groupedNibs.uniques.map(nibStructForNib)
    ),
    extern: Struct(
      type: Type(name: "nib"),
      implements: [],
      typealiasses: [],
      vars: groupedNibs.uniques.map(nibVarForNib),
      functions: [],
      structs: []
    )
  )
}

private func nibVarForNib(nib: Nib) -> Var {
  let nibStructName = sanitizedSwiftName("_\(nib.name)")
  let structType = Type(name: "_R.nib.\(nibStructName)")
  return Var(isStatic: true, name: nib.name, type: structType, getter: "return \(structType)()")
}

private func nibStructForNib(nib: Nib) -> Struct {

  let instantiateParameters = [
    Function.Parameter(name: "ownerOrNil", type: Type._AnyObject.asOptional()),
    Function.Parameter(name: "options", localName: "optionsOrNil", type: Type(name: "[NSObject : AnyObject]", optional: true))
  ]

  let bundleVar = Var(
    isStatic: false,
    name: "bundle",
    type: Type._NSBundle.asOptional(),
    getter: "return _R.hostingBundle"
  )

  let nameVar = Var(
    isStatic: false,
    name: "name",
    type: Type._String,
    getter: "return \"\(nib.name)\""
  )

  let instanceVar = Var(
    isStatic: false,
    name: "instance",
    type: Type._UINib,
    getter: "return UINib.init(nibName: \"\(nib.name)\", bundle: _R.hostingBundle)"
  )

  let instantiateFunc = Function(
    isStatic: false,
    name: "instantiateWithOwner",
    generics: nil,
    parameters: instantiateParameters,
    returnType: Type(name: "[AnyObject]"),
    body: "return instance.instantiateWithOwner(ownerOrNil, options: optionsOrNil)"
  )

  let viewFuncs = zip(nib.rootViews, Ordinals)
    .map { (view: $0.0, ordinal: $0.1) }
    .map {
      Function(
        isStatic: false,
        name: "\($0.ordinal.word)View",
        generics: nil,
        parameters: instantiateParameters,
        returnType: $0.view.asOptional(),
        body: "return \(instantiateFunc.callName)(ownerOrNil, options: optionsOrNil)[\($0.ordinal.number - 1)] as? \($0.view)"
      )
  }

  let reuseIdentifierVars: [Var]
  let reuseProtocols: [Type]
  let reuseTypealiasses: [Typealias]
  if let reusable = nib.reusables.first where nib.rootViews.count == 1 && nib.reusables.count == 1 {
    reuseIdentifierVars = [Var(
      isStatic: false,
      name: "identifier",
      type: Type._String,
      getter: "return \"\(reusable.identifier)\""
      )]
    reuseTypealiasses = [Typealias(alias: Type(name: "ReusableType"), type: reusable.type)]
    reuseProtocols = [Type.ReuseIdentifierProtocol]
  } else {
    reuseIdentifierVars = []
    reuseTypealiasses = []
    reuseProtocols = []
  }

  let sanitizedName = sanitizedSwiftName(nib.name, lowercaseFirstCharacter: false)
  return Struct(
    type: Type(name: "_\(sanitizedName)"),
    implements: [Type.NibResourceProtocol] + reuseProtocols,
    typealiasses: reuseTypealiasses,
    vars: [bundleVar, nameVar, instanceVar] + reuseIdentifierVars,
    functions: [instantiateFunc] + viewFuncs,
    structs: []
  )
}
