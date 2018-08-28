//
//  FontStructGenerator.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

struct FontStructGenerator: ExternalOnlyStructGenerator {
  private let fonts: [Font]

  init(fonts: [Font]) {
    self.fonts = fonts
  }

  func generatedStruct(at externalAccessLevel: AccessLevel, prefix: SwiftIdentifier) -> Struct {
    let structName: SwiftIdentifier = "font"
    let qualifiedName = prefix + structName

    let groupedFonts = fonts.grouped(bySwiftIdentifier: { $0.name })
    groupedFonts.printWarningsForDuplicatesAndEmpties(source: "font resource", result: "file")

    let fontTypes = groupedFonts.uniques.map { font -> (Let, Function, String) in
      let properties = Let(
        comments: ["Font `\(font.name)`."],
        accessModifier: externalAccessLevel,
        isStatic: true,
        name: SwiftIdentifier(name: font.name),
        typeDefinition: .inferred(Type.FontResource),
        value: "Rswift.FontResource(fontName: \"\(font.name)\")"
      )

      let function = Function(
        availables: [],
        comments: ["`UIFont(name: \"\(font.name)\", size: ...)`"],
        accessModifier: externalAccessLevel,
        isStatic: true,
        name: SwiftIdentifier(name: font.name),
        generics: nil,
        parameters: [
          Function.Parameter(name: "size", type: Type._CGFloat)
        ],
        doesThrow: false,
        returnType: Type._UIFont.asOptional(),
        body: "return UIKit.UIFont(resource: \(SwiftIdentifier(name: font.name)), size: size)",
        os: []
      )

      let fontName = qualifiedName + SwiftIdentifier(name: font.name)
      let validateLine = "if \(fontName)(size: 42) == nil { throw Rswift.ValidationError(description:\"[R.swift] Font '\(font.name)' could not be loaded, is '\(font.filename)' added to the UIAppFonts array in this targets Info.plist?\") }"

      return (properties, function, validateLine)
    }

    var implements: [TypePrinter] = []
    let properties = fontTypes.map { $0.0 }
    var functions = fontTypes.map { $0.1 }
    let validateLines = fontTypes.map { $0.2 }

    if validateLines.count > 0 {
      let validateFunction = Function(
        availables: [],
        comments: [],
        accessModifier: externalAccessLevel,
        isStatic: true,
        name: "validate",
        generics: nil,
        parameters: [],
        doesThrow: true,
        returnType: Type._Void,
        body: validateLines.joined(separator: "\n"),
        os: []
      )
      functions.append(validateFunction)
      implements.append(TypePrinter(type: Type.Validatable))
    }

    return Struct(
      availables: [],
      comments: ["This `R.font` struct is generated, and contains static references to \(fonts.count) fonts."],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: structName),
      implements: implements,
      typealiasses: [],
      properties: properties,
      functions: functions,
      structs: [],
      classes: []
    )
  }
}
