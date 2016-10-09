//
//  NibStructGenerator.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
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

struct NibStructGenerator: StructGenerator {
  private let nibs: [Nib]

  init(nibs: [Nib]) {
    self.nibs = nibs
  }

  func generatedStructs(at externalAccessLevel: AccessLevel) -> StructGenerator.Result {
    let groupedNibs = nibs.groupedBySwiftIdentifier { $0.name }
    groupedNibs.printWarningsForDuplicatesAndEmpties(source: "xib", result: "file")

    let internalStruct = Struct(
      comments: [],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: "nib"),
      implements: [],
      typealiasses: [],
      properties: [],
      functions: [],
      structs: groupedNibs
        .uniques
        .map { nibStruct(for: $0, at: externalAccessLevel) }
    )

    let nibProperties: [Let] = groupedNibs
      .uniques
      .map { nibVar(for: $0, at: externalAccessLevel) }
    let nibFunctions: [Function] = groupedNibs
      .uniques
      .map { nibFunc(for: $0, at: externalAccessLevel) }

    let externalStruct = Struct(
      comments: ["This `R.nib` struct is generated, and contains static references to \(nibProperties.count) nibs."],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: "nib"),
      implements: [],
      typealiasses: [],
      properties: nibProperties,
      functions: nibFunctions,
      structs: []
    )

    return (
      externalStruct,
      internalStruct
    )
  }

  private func nibFunc(for nib: Nib, at externalAccessLevel: AccessLevel) -> Function {
    return Function(
      comments: ["`UINib(name: \"\(nib.name)\", in: bundle)`"],
      accessModifier: externalAccessLevel,
      isStatic: true,
      name: SwiftIdentifier(name: nib.name),
      generics: nil,
      parameters: [
        Function.Parameter(name: "_", type: Type._Void, defaultValue: "()")
      ],
      doesThrow: false,
      returnType: Type._UINib,
      body: "return UIKit.UINib(resource: R.nib.\(SwiftIdentifier(name: nib.name)))"
    )
  }

  private func nibVar(for nib: Nib, at externalAccessLevel: AccessLevel) -> Let {
    let nibStructName = SwiftIdentifier(name: "_\(nib.name)")
    let structType = Type(module: .host, name: SwiftIdentifier(rawValue: "_R.nib.\(nibStructName)"))
    return Let(
      comments: ["Nib `\(nib.name)`."],
      accessModifier: externalAccessLevel,
      isStatic: true,
      name: SwiftIdentifier(name: nib.name),
      typeDefinition: .inferred(structType),
      value: "\(structType)()"
    )
  }

  private func nibStruct(for nib: Nib, at externalAccessLevel: AccessLevel) -> Struct {
    let instantiateParameters = [
      Function.Parameter(name: "owner", localName: "ownerOrNil", type: Type._AnyObject.asOptional()),
      Function.Parameter(name: "options", localName: "optionsOrNil", type: Type(module: .stdLib, name: SwiftIdentifier(rawValue: "[NSObject : AnyObject]"), optional: true), defaultValue: "nil")
    ]

    let bundleLet = Let(
      comments: [],
      accessModifier: externalAccessLevel,
      isStatic: false,
      name: "bundle",
      typeDefinition: .inferred(Type._Bundle),
      value: "R.hostingBundle"
    )

    let nameVar = Let(
      comments: [],
      accessModifier: externalAccessLevel,
      isStatic: false,
      name: "name",
      typeDefinition: .inferred(Type._String),
      value: "\"\(nib.name)\""
    )

    let viewFuncs = zip(nib.rootViews, Ordinals)
      .map { (view: $0.0, ordinal: $0.1) }
      .map { viewInfo -> Function in
        let viewIndex = viewInfo.ordinal.number - 1
        let viewTypeString = viewInfo.view.description
        return Function(
          comments: [],
          accessModifier: externalAccessLevel,
          isStatic: false,
          name: SwiftIdentifier(name: "\(viewInfo.ordinal.word)View"),
          generics: nil,
          parameters: instantiateParameters,
          doesThrow: false,
          returnType: viewInfo.view.asOptional(),
          body: "return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[\(viewIndex)] as? \(viewTypeString)"
        )
      }

    let reuseIdentifierProperties: [Let]
    let reuseProtocols: [Type]
    let reuseTypealiasses: [Typealias]
    if let reusable = nib.reusables.first , nib.rootViews.count == 1 && nib.reusables.count == 1 {
      reuseIdentifierProperties = [Let(
        comments: [],
        accessModifier: externalAccessLevel,
        isStatic: false,
        name: "identifier",
        typeDefinition: .inferred(Type._String),
        value: "\"\(reusable.identifier)\""
        )]
      reuseTypealiasses = [Typealias(alias: "ReusableType", type: reusable.type)]
      reuseProtocols = [Type.ReuseIdentifierType]
    } else {
      reuseIdentifierProperties = []
      reuseTypealiasses = []
      reuseProtocols = []
    }

    // Validation
    let validateImagesLines = Set(nib.usedImageIdentifiers)
      .map {
        "if UIKit.UIImage(named: \"\($0)\") == nil { throw Rswift.ValidationError(description: \"[R.swift] Image named '\($0)' is used in nib '\(nib.name)', but couldn't be loaded.\") }"
    }

    var validateFunctions: [Function] = []
    var validateImplements: [Type] = []
    if validateImagesLines.count > 0 {
      let validateFunction = Function(
        comments: [],
        accessModifier: externalAccessLevel,
        isStatic: true,
        name: "validate",
        generics: nil,
        parameters: [],
        doesThrow: true,
        returnType: Type._Void,
        body: validateImagesLines.joined(separator: "\n")
      )
      validateFunctions.append(validateFunction)
      validateImplements.append(Type.Validatable)
    }

    let sanitizedName = SwiftIdentifier(name: nib.name, lowercaseFirstCharacter: false)
    return Struct(
      comments: [],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: SwiftIdentifier(name: "_\(sanitizedName)")),
      implements: ([Type.NibResourceType] + reuseProtocols + validateImplements).map(TypePrinter.init),
      typealiasses: reuseTypealiasses,
      properties: [bundleLet, nameVar] + reuseIdentifierProperties,
      functions: viewFuncs + validateFunctions,
      structs: []
    )
  }
}
