//
//  PropertyListGenerator.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2018-07-07.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

struct PropertyListGenerator: ExternalOnlyStructGenerator {
  private let name: SwiftIdentifier
  private let plists: [PropertyList]
  private let toplevelKeysWhitelist: [String]?

  init(name: SwiftIdentifier, plists: [PropertyList], toplevelKeysWhitelist: [String]?) {
    self.name = name
    self.plists = plists
    self.toplevelKeysWhitelist = toplevelKeysWhitelist
  }

  func generatedStruct(at externalAccessLevel: AccessLevel, prefix: SwiftIdentifier) -> Struct {
    guard let plist = plists.first else { return .empty }

    guard plists.all(where: { $0.url == plist.url }) else {
      let configs = plists.map { $0.buildConfigurationName }
      warn("Build configurations \(configs) use different \(name) files, this is not yet supported")
      return .empty
    }

    let contents: PropertyList.Contents
    if let whitelist = toplevelKeysWhitelist {
      contents = plist.contents.filter { (key, _) in whitelist.contains(key) }
    } else {
      contents = plist.contents
    }

    let qualifiedName = prefix + name

    return Struct(
      availables: [],
      comments: ["This `\(qualifiedName)` struct is generated, and contains static references to \(contents.count) properties."],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: name),
      implements: [],
      typealiasses: [],
      properties: propertiesFromInfoPlist(contents: contents, path: [], at: externalAccessLevel),
      functions: [],
      structs: structsFromInfoPlist(contents: contents, path: [], at: externalAccessLevel),
      classes: [],
      os: []
    )
  }

  private func propertiesFromInfoPlist(contents: [String: Any], path: [String], at externalAccessLevel: AccessLevel) -> [Let] {

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
          return propertyFromInfoString(key: key, value: value, path: path, at: externalAccessLevel)
        default:
          return nil
        }
      }
  }

  private func propertyFromInfoString(key: String, value: String, path: [String], at externalAccessLevel: AccessLevel) -> Let {

    let isKey = key == "_key"
    let letValue: String = isKey
      ? "\"\(value.escapedStringLiteral)\""
      : "_infoDictionary?[\"\(key)\"] as? String ?? \"\(value.escapedStringLiteral)\""

    return Let(
      comments: isKey ? [] : [value],
      accessModifier: externalAccessLevel,
      isStatic: true,
      name: SwiftIdentifier(name: key),
      typeDefinition: .inferred(Type._String),
      value: letValue
    )
  }

  private func structsFromInfoPlist(contents: [String: Any], path: [String], at externalAccessLevel: AccessLevel) -> [Struct] {

    return contents
      .compactMap { (key, value) -> Struct? in
        var ps = path
        ps.append(key)

        let info = path.reduce("hostingBundle.infoDictionary", { (source, step) in
          "(\(source)?[\"\(step)\"] as? [String: Any])"
        })
        let object = Let(
          comments: [],
          accessModifier: .privateLevel,
          isStatic: true,
          name: "_infoDictionary",
          typeDefinition: .inferred(nil),
          value: info
        )

        switch value {
        case let array as [String]:
          var props = array.map { item in
            propertyFromInfoString(key: item, value: item, path: ps, at: externalAccessLevel)
          }
          if !props.isEmpty {
            props.append(object)
          }

          return Struct(
            availables: [],
            comments: [],
            accessModifier: externalAccessLevel,
            type: Type(module: .host, name: SwiftIdentifier(name: key)),
            implements: [],
            typealiasses: [],
            properties: props,
            functions: [],
            structs: [],
            classes: [],
            os: []
          )

        case var dict as [String: Any]:
          dict["_key"] = key
          var props = propertiesFromInfoPlist(contents: dict, path: ps, at: externalAccessLevel)
          if !props.isEmpty {
            props.append(object)
          }

          return Struct(
            availables: [],
            comments: [],
            accessModifier: externalAccessLevel,
            type: Type(module: .host, name: SwiftIdentifier(name: key)),
            implements: [],
            typealiasses: [],
            properties: props,
            functions: [],
            structs: structsFromInfoPlist(contents: dict, path: ps, at: externalAccessLevel),
            classes: [],
            os: []
          )

        case let dicts as [[String: Any]] where arrayOfDictionariesPrimaryKeys.keys.contains(key):
          return structForArrayOfDictionaries(key: key, dicts: dicts, path: path, at: externalAccessLevel)

        default:
          return nil
      }
    }
  }

  // For arrays of dictionaries we need a primary key.
  // This key will be used as a name for the struct in the generated code.
  private let arrayOfDictionariesPrimaryKeys: [String: String] = [
    "UIWindowSceneSessionRoleExternalDisplay": "UISceneConfigurationName",
    "UIWindowSceneSessionRoleApplication": "UISceneConfigurationName",
    "UIApplicationShortcutItems": "UIApplicationShortcutItemType",
    "CFBundleDocumentTypes": "CFBundleTypeName",
    "CFBundleURLTypes": "CFBundleURLName"
  ]

  private func structForArrayOfDictionaries(key: String, dicts: [[String: Any]], path: [String], at externalAccessLevel: AccessLevel) -> Struct {
    let kvs = dicts.compactMap { dict -> (String, [String: Any])? in
      if
        let primaryKey = arrayOfDictionariesPrimaryKeys[key],
        let type = dict[primaryKey] as? String
      {
        return (type, dict)
      }

      return nil
    }

    var ps = path
    ps.append(key)

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
      structs: structsFromInfoPlist(contents: contents, path: ps, at: externalAccessLevel),
      classes: [],
      os: []
    )
  }
}
