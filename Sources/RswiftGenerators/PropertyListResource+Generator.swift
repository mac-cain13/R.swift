//
//  PropertyListResource+Generator.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-23.
//

import Foundation
import RswiftResources

extension PropertyListResource {
    public static func generateStruct(resourceName: String, plists: [PropertyListResource], toplevelKeysWhitelist: [String]?, prefix: SwiftIdentifier) -> Struct {
        let structName = SwiftIdentifier(name: resourceName)
        let qualifiedName = prefix + structName
        let warning: (String) -> Void = { print("warning:", $0) }

        guard let plist = plists.first else { return .empty }

        guard plists.allSatisfy({ $0.url == plist.url }) else {
            let configs = plists.map { $0.buildConfigurationName }
            warning("Build configurations \(configs) use different \(resourceName) files, this is not yet supported")
            return .empty
        }

        let contents: PropertyListResource.Contents
        if let whitelist = toplevelKeysWhitelist {
            contents = plist.contents.filter { (key, _) in whitelist.contains(key) }
        } else {
            contents = plist.contents
        }

        let members = contents.generateMembers(resourceName: resourceName, path: [], warning: warning)
            .sorted()
        let comments = ["This `\(qualifiedName.value)` struct is generated, and contains static references to \(members.structs.count) properties."]

        return Struct(comments: comments, name: structName) {
            members
        }
    }
}

extension PropertyListResource.Contents {
    @StructMembersBuilder func generateMembers(resourceName: String, path: [String], warning: (String) -> Void) -> StructMembers {
        let groupedContents = self.grouped(bySwiftIdentifier: { $0.key })
        groupedContents.reportWarningsForDuplicatesAndEmpties(source: resourceName, result: resourceName, warning: warning)

        for (key, value) in groupedContents.uniques {
            let newPath = path + [key]

            switch value {
            case let value as Bool:
                LetBinding(
                    isStatic: true,
                    name: SwiftIdentifier(name: key),
                    valueCodeString: "\(value)"
                )

              case let value as String:
                let keyPath = (path + [key.escapedStringLiteral]).joined(separator: ".")
                LetBinding(
                    isStatic: true,
                    name: SwiftIdentifier(name: key),
                    valueCodeString: "\"\(value.escapedStringLiteral)\"" // "NSDictionary().value(forKeyPath: \"\(keyPath)\") ?? \"\(value.escapedStringLiteral)\""
                )

            case let duplicateArray as [String]:
                let groupedArray = duplicateArray.grouped(bySwiftIdentifier: { $0 })
                groupedArray.reportWarningsForDuplicatesAndEmpties(source: resourceName, result: resourceName, warning: warning)
                let dicts = Dictionary(groupedArray.uniques.map { ($0, $0) }, uniquingKeysWith: { l, r in l })

                Struct(name: SwiftIdentifier(name: key)) {
                    dicts
                        .generateMembers(resourceName: resourceName, path: newPath, warning: warning)
                        .sorted()
                }

            case var dict as [String: Any]:
                dict["_key"] = key

                Struct(name: SwiftIdentifier(name: key)) {
                    dict.generateMembers(resourceName: resourceName, path: newPath, warning: warning)
                        .sorted()
                }

            case let dicts as [[String: Any]] where arrayOfDictionariesPrimaryKeys.keys.contains(key):

                Struct(name: SwiftIdentifier(name: key)) {
                    for dict in dicts {
                        if let primaryKey = arrayOfDictionariesPrimaryKeys[key],
                           let primary = dict[primaryKey] as? String {
                            Struct(name: SwiftIdentifier(name: primary)) {
                                dict.generateMembers(resourceName: resourceName, path: path, warning: warning)
                                    .sorted()
                            }
                        }
                    }
                }

            default:
                do {}
            }
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
