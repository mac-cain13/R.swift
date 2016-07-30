//
//  Font.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct FontGenerator: Generator {
  let externalStruct: Struct?
  let internalStruct: Struct? = nil

  init(fonts: [Font]) {
    let groupedFonts = fonts.groupBySwiftIdentifiers { $0.name }
    groupedFonts.printWarningsForDuplicatesAndEmpties(source: "font resource", result: "file")

    let fontProperties: [Property] = groupedFonts.uniques.map {
      Let(
        comments: ["Font `\($0.name)`."],
        isStatic: true,
        name: SwiftIdentifier(name: $0.name),
        typeDefinition: .Inferred(Type.FontResource),
        value: "FontResource(fontName: \"\($0.name)\")"
      )
    }

    externalStruct = Struct(
      comments: ["This `R.font` struct is generated, and contains static references to \(fonts.count) fonts."],
      type: Type(module: .Host, name: "font"),
      implements: [],
      typealiasses: [],
      properties: fontProperties,
      functions: groupedFonts.uniques.map(FontGenerator.fontFunctionFromFont),
      structs: []
    )
  }

  private static func fontFunctionFromFont(font: Font) -> Function {
    return Function(
      comments: ["`UIFont(name: \"\(font.name)\", size: ...)`"],
      isStatic: true,
      name: SwiftIdentifier(name: font.name),
      generics: nil,
      parameters: [
        Function.Parameter(name: "size", localName: "size", type: Type._CGFloat)
      ],
      doesThrow: false,
      returnType: Type._UIFont.asOptional(),
      body: "return UIFont(resource: \(SwiftIdentifier(name: font.name)), size: size)"
    )
  }
}
