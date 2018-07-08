//
//  InfoGenerator.swift
//  Commander
//
//  Created by Tom Lokhorst on 2018-07-07.
//

import Foundation

struct InfoStructGenerator: ExternalOnlyStructGenerator {
  private let infoPlists: [InfoPlist]

  init(infoPlists: [InfoPlist]) {
    self.infoPlists = infoPlists
  }

  func generatedStruct(at externalAccessLevel: AccessLevel, prefix: SwiftIdentifier) -> Struct {
    let infoPlist = infoPlists.first! // TODO: Not this here, duh

    let structName: SwiftIdentifier = "info"
    let qualifiedName = prefix + structName

    return Struct(
      availables: [],
      comments: ["This `\(qualifiedName)` struct is generated, and contains static references to \(infoPlist.contents.count) properties."],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: structName),
      implements: [],
      typealiasses: [],
      properties: propertiesFromInfoPlist(contents: infoPlist.contents, at: externalAccessLevel),
      functions: [],
      structs: structsFromInfoPlist(contents: infoPlist.contents, at: externalAccessLevel),
      classes: []
    )
  }

  private func propertiesFromInfoPlist(contents: [String: Any], at externalAccessLevel: AccessLevel) -> [Let] {

    return contents
      .compactMap { (key, value) -> Let? in
        switch value {
        case let value as Bool:
          return Let(
            comments: [],
            accessModifier: externalAccessLevel,
            isStatic: true,
            name: SwiftIdentifier(name: key),
            typeDefinition: .inferred(Type._Bool),
            value: "\(value)"
          )
        case let value as String:
          return Let(
            comments: [],
            accessModifier: externalAccessLevel,
            isStatic: true,
            name: SwiftIdentifier(name: key),
            typeDefinition: .inferred(Type._Bool),
            value: "\"\(value.escapedStringLiteral)\""
          )
        default:
          return nil
        }
    }
  }

  private func structsFromInfoPlist(contents: [String: Any], at externalAccessLevel: AccessLevel) -> [Struct] {

    return contents
      .compactMap { (key, value) -> Struct? in
        switch value {
        case let array as [String]:
          return Struct(
            availables: [],
            comments: [],
            accessModifier: externalAccessLevel,
            type: Type(module: .host, name: SwiftIdentifier(name: key)),
            implements: [],
            typealiasses: [],
            properties: array.map { item in
              return Let(
                comments: [],
                accessModifier: externalAccessLevel,
                isStatic: true,
                name: SwiftIdentifier(name: item),
                typeDefinition: .inferred(Type._Bool),
                value: "\"\(item.escapedStringLiteral)\""
              )
            },
            functions: [],
            structs: [],
            classes: []
          )

        case let dict as [String: Any]:
          return Struct(
            availables: [],
            comments: [],
            accessModifier: externalAccessLevel,
            type: Type(module: .host, name: SwiftIdentifier(name: key)),
            implements: [],
            typealiasses: [],
            properties: propertiesFromInfoPlist(contents: dict, at: externalAccessLevel),
            functions: [],
            structs: structsFromInfoPlist(contents: dict, at: externalAccessLevel),
            classes: []
          )

        default:
          return nil
      }
    }
  }
}
