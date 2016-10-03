//
//  Font.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct FontGenerator: StructGenerator {
  private let fonts: [Font]

  init(fonts: [Font]) {
    self.fonts = fonts
  }

  func generateStruct(at externalAccessLevel: AccessModifier) -> Struct? {
    let groupedFonts = fonts.groupedBySwiftIdentifier { $0.name }
    groupedFonts.printWarningsForDuplicatesAndEmpties(source: "font resource", result: "file")

    let fontProperties: [Let] = groupedFonts.uniques.map {
      Let(
        comments: ["Font `\($0.name)`."],
        isStatic: true,
        name: SwiftIdentifier(name: $0.name),
        typeDefinition: .inferred(Type.FontResource),
        value: "Rswift.FontResource(fontName: \"\($0.name)\")"
      )
    }

    return Struct(
      comments: ["This `R.font` struct is generated, and contains static references to \(fonts.count) fonts."],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: "font"),
      implements: [],
      typealiasses: [],
      properties: fontProperties,
      functions: groupedFonts.uniques.map(fontFunction),
      structs: []
    )
  }

  private func fontFunction(from font: Font) -> Function {
    return Function(
      comments: ["`UIFont(name: \"\(font.name)\", size: ...)`"],
      isStatic: true,
      name: SwiftIdentifier(name: font.name),
      generics: nil,
      parameters: [
        Function.Parameter(name: "size", type: Type._CGFloat)
      ],
      doesThrow: false,
      returnType: Type._UIFont.asOptional(),
      body: "return UIKit.UIFont(resource: \(SwiftIdentifier(name: font.name)), size: size)"
    )
  }
}
