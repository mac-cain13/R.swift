//
//  ColorGenerator.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2016-03-13.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation
import AppKit.NSColor

struct ColorGenerator: ExternalOnlyStructGenerator {
  private let palettes: [ColorPalette]

  init(colorPalettes palettes: [ColorPalette]) {
    self.palettes = palettes
  }

  func generatedStruct(at externalAccessLevel: AccessLevel) -> Struct {
    let groupedPalettes = palettes.groupedBySwiftIdentifier { $0.filename }
    groupedPalettes.printWarningsForDuplicatesAndEmpties(source: "color palette", result: "file")

    return Struct(
      comments: ["This `R.color` struct is generated, and contains static references to \(palettes.count) color palettes."],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: "color"),
      implements: [],
      typealiasses: [],
      properties: [],
      functions: [],
      structs: groupedPalettes.uniques.flatMap { colorStruct(from: $0, at: externalAccessLevel) }
    )
  }

  private func colorStruct(from palette: ColorPalette, at externalAccessLevel: AccessLevel) -> Struct? {
    if palette.colors.isEmpty { return nil }

    let name = SwiftIdentifier(name: palette.filename)
    let groupedColors = palette.colors.groupedBySwiftIdentifier { $0.0 }

    groupedColors.printWarningsForDuplicatesAndEmpties(source: "color", container: "in palette '\(palette.filename)'", result: "color")

    return Struct(
      comments: ["This `R.color.\(name)` struct is generated, and contains static references to \(groupedColors.uniques.count) colors."],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: name),
      implements: [],
      typealiasses: [],
      properties: groupedColors.uniques.map { colorLet($0, color: $1, at: externalAccessLevel) },
      functions: groupedColors.uniques.map { colorFunction($0, color: $1, at: externalAccessLevel) },
      structs: []
    )
  }

  private func colorLet(_ name: String, color: NSColor, at externalAccessLevel: AccessLevel) -> Let {
    return Let(
      comments: [
        "<span style='background-color: #\(color.hexString); color: #\(color.opposite.hexString); padding: 1px 3px;'>#\(color.hexString)</span> \(name)"
      ],
      accessModifier: externalAccessLevel,
      isStatic: true,
      name: SwiftIdentifier(name: name),
      typeDefinition: .inferred(Type.ColorResource),
      value: "Rswift.ColorResource(name: \"\(name)\", red: \(color.redComponent), green: \(color.greenComponent), blue: \(color.blueComponent), alpha: \(color.alphaComponent))"
    )
  }

  private func colorFunction(_ name: String, color: NSColor, at externalAccessLevel: AccessLevel) -> Function {
    return Function(
      comments: [
        "<span style='background-color: #\(color.hexString); color: #\(color.opposite.hexString); padding: 1px 3px;'>#\(color.hexString)</span> \(name)",
        "",
        "UIColor(red: \(color.redComponent), green: \(color.greenComponent), blue: \(color.blueComponent), alpha: \(color.alphaComponent))"
      ],
      accessModifier: externalAccessLevel,
      isStatic: true,
      name: SwiftIdentifier(name: name),
      generics: nil,
      parameters: [
        Function.Parameter(name: "_", type: Type._Void, defaultValue: "()")
      ],
      doesThrow: false,
      returnType: Type._UIColor,
      body: "return UIKit.UIColor(red: \(color.redComponent), green: \(color.greenComponent), blue: \(color.blueComponent), alpha: \(color.alphaComponent))"
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
