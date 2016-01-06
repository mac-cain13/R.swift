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
  let internalStruct: Struct?

  init(fonts: [Font]) {
    let fontStructs = fonts.map(FontGenerator.fontStructFromFont)

    externalStruct = Struct(
      type: Type(module: .Host, name: "font"),
      implements: [],
      typealiasses: [],
      properties: fontStructs.map {
        Let(isStatic: true, name: $0.type.name, type: nil, value: "_R.font.\($0.type)()")
      },
      functions: fontStructs.map(FontGenerator.fontFunctionFromFontStruct),
      structs: []
    )

    internalStruct = Struct(
      type: Type(module: .Host, name: "font"),
      implements: [],
      typealiasses: [],
      properties: [],
      functions: [],
      structs: fontStructs
    )
  }

  private static func fontStructFromFont(font: Font) -> Struct {
    return Struct(
      type: Type(module: .Host, name: sanitizedSwiftName(font.name)),
      implements: [Type.FontResourceProtocol],
      typealiasses: [],
      properties: [
        Let(isStatic: false, name: "fontName", type: nil, value: "\"\(font.name)\"")
      ],
      functions: [],
      structs: []
    )
  }

  private static func fontFunctionFromFontStruct(fontStruct: Struct) -> Function {
    return Function(
      isStatic: true,
      name: fontStruct.type.name,
      generics: nil,
      parameters: [
        Function.Parameter(name: "size", localName: "size", type: Type._CGFloat)
      ],
      doesThrow: false,
      returnType: Type._UIFont.asOptional(),
      body: "return UIFont(font: \(fontStruct.type.name), size: size)"
    )
  }
}
