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
    let groupedPalettes = palettes.groupBySwiftIdentifiers { $0.filename }
    groupedPalettes.printWarningsForDuplicatesAndEmpties(source: "color palette", result: "file")

    externalStruct = Struct(
      comments: ["This `R.color` struct is generated, and contains static references to \(palettes.count) color palettes."],
      type: Type(module: .Host, name: "color"),
      implements: [],
      typealiasses: [],
      properties: [],
      functions: [],
      structs: groupedPalettes.uniques.flatMap(ColorGenerator.colorStructFromPalette)
    )
  }

  private static func colorStructFromPalette(palette: ColorPalette) -> Struct? {
    if palette.colors.isEmpty { return nil }

    let name = SwiftIdentifier(name: palette.filename)
    let groupedColors = palette.colors.groupBySwiftIdentifiers { $0.0 }

    groupedColors.printWarningsForDuplicatesAndEmpties(source: "color", container: "in palette '\(palette.filename)'", result: "color")

    return Struct(
      comments: ["This `R.color.\(name)` struct is generated, and contains static references to \(groupedColors.uniques.count) colors."],
      type: Type(module: .Host, name: name),
      implements: [],
      typealiasses: [],
      properties: groupedColors.uniques.map(ColorGenerator.colorLet),
      functions: groupedColors.uniques.map(ColorGenerator.colorFunction),
      structs: []
    )
  }

  private static func colorLet(name: String, color: NSColor) -> Let {
    return Let(
      comments: [
        "<span style='background-color: #\(color.hexString); color: #\(color.opposite.hexString); padding: 1px 3px;'>#\(color.hexString)</span> \(name)"
      ],
      isStatic: true,
      name: SwiftIdentifier(name: name),
      typeDefinition: .Inferred(Type.ColorResource),
      value: "ColorResource(name: \"\(name)\", red: \(color.redComponent), green: \(color.greenComponent), blue: \(color.blueComponent), alpha: \(color.alphaComponent))"
    )
  }

  private static func colorFunction(name: String, color: NSColor) -> Function {
    return Function(
      comments: [
        "<span style='background-color: #\(color.hexString); color: #\(color.opposite.hexString); padding: 1px 3px;'>#\(color.hexString)</span> \(name)",
        "",
        "UIColor(red: \(color.redComponent), green: \(color.greenComponent), blue: \(color.blueComponent), alpha: \(color.alphaComponent))"
      ],
      isStatic: true,
      name: SwiftIdentifier(name: name),
      generics: nil,
      parameters: [
        Function.Parameter(name: "_", type: Type._Void, defaultValue: "()")
      ],
      doesThrow: false,
      returnType: Type._UIColor,
      body: "return UIColor(red: \(color.redComponent), green: \(color.greenComponent), blue: \(color.blueComponent), alpha: \(color.alphaComponent))"
    )
  }
}

private extension NSColor {
  var hexString: String {
    let red = UInt(roundf(Float(redComponent) * 255.0))
    let green = UInt(roundf(Float(greenComponent) * 255.0))
    let blue = UInt(roundf(Float(blueComponent) * 255.0))
    let alpha = UInt(roundf(Float(alphaComponent) * 255.0))

    if alphaComponent == 1 {
      let hex = (red << 16) | (green << 8) | (blue)

      return String(format:"%06X", hex)
    }
    else {
      let hex = (red << 24) | (green << 16) | (blue << 8) | (alpha)

      return String(format:"%08X", hex)
    }
  }

  var opposite: NSColor {
    return NSColor.init(calibratedRed: 1 - redComponent, green: 1 - greenComponent, blue: 1 - blueComponent, alpha: 1)
  }
}
