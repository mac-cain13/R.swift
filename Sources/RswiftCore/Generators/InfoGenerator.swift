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
    guard let infoPlist = infoPlists.first else { return .empty }

    guard infoPlists.all(where: { $0.url == infoPlist.url }) else {
      let configs = infoPlists.map { $0.buildConfigurationName }
      warn("Build configrurations \(configs) use different Info.plist files, this is not yet supported")
      return .empty
    }

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

        case let dicts as [[String: Any]] where key == "UIApplicationShortcutItems":
          return applicationShortcutItems(key: key, dicts: dicts, at: externalAccessLevel)

        default:
          return nil
      }
    }
  }

  private func applicationShortcutItems(key: String, dicts: [[String: Any]], at externalAccessLevel: AccessLevel) -> Struct {
    let kvs = dicts.compactMap { dict -> (String, [String: Any])? in
      guard let type = dict["UIApplicationShortcutItemType"] as? String else { return nil }
      return (type, dict)
    }
    let contents = Dictionary(kvs, uniquingKeysWith: { (l, _) in l })
    return Struct(
      availables: [],
      comments: [],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: SwiftIdentifier(name: key)),
      implements: [],
      typealiasses: [],
      properties: [],
      functions: [],
      structs: structsFromInfoPlist(contents: contents, at: externalAccessLevel),
      classes: []
    )
  }
}
