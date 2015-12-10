//
//  Font.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  Copyright © 2015 Mathijs Kadijk. All rights reserved.
//

import Foundation

func fontStructFromFonts(fonts: [Font]) -> Struct {
  return Struct(
    type: Type(name: "font"),
    implements: [],
    typealiasses: [],
    vars: [],
    functions: fonts.map(fontFunctionFromFont),
    structs: []
  )
}

func fontFunctionFromFont(font: Font) -> Function {
  return Function(
    isStatic: true,
    name: font.name,
    generics: nil,
    parameters: [
      Function.Parameter(name: "size", localName: "size", type: Type._CGFloat)
    ],
    returnType: Type._UIFont.asOptional(),
    body:"return UIFont(name: \"\(font.name)\", size: size)"
  )
}
