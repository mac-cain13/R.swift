//
//  ColorGenerator.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2016-03-13.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation
import AppKit.NSColor

struct ColorGenerator: Generator {
  let externalStruct: Struct?
  let internalStruct: Struct? = nil

  init(colorPalettes palettes: [ColorPalette]) {
    externalStruct = Struct(
      type: Type(module: .Host, name: "color"),
      implements: [],
      typealiasses: [],
      properties: [],
      functions: [],
      structs: palettes.flatMap(ColorGenerator.colorStructFromPalette)
    )
  }

  private static func colorStructFromPalette(palette: ColorPalette) -> Struct? {
    if palette.colors.isEmpty { return nil }

    return Struct(
      type: Type(module: .Host, name: sanitizedSwiftName(palette.filename)),
      implements: [],
      typealiasses: [],
      properties: palette.colors.map(ColorGenerator.colorLet),
      functions: palette.colors.map(ColorGenerator.colorFunction),
      structs: []
    )
  }

  private static func colorLet(name: String, color: NSColor) -> Let {
    return Let(
      isStatic: true,
      name: name,
      typeDefinition: .Inferred(Type.ColorResource),
      value: "ColorResource(name: \"\(name)\", red: \(color.redComponent), green: \(color.greenComponent), blue: \(color.blueComponent), alpha: \(color.alphaComponent))"
    )
  }

  private static func colorFunction(name: String, color: NSColor) -> Function {
    return Function(
      isStatic: true,
      name: name,
      generics: nil,
      parameters: [
        Function.Parameter(name: "_", type: Type._Void)
      ],
      doesThrow: false,
      returnType: Type._UIColor,
      body: "return UIColor(red: \(color.redComponent), green: \(color.greenComponent), blue: \(color.blueComponent), alpha: \(color.alphaComponent))"
    )
  }
}
