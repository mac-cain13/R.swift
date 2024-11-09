//
//  PropertyListResource+Generator.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-23.
//

import Foundation
import RswiftResources

extension PropertyListResource {
    public static func generateInfoStruct(resourceName: String, plists: [PropertyListResource], prefix: SwiftIdentifier) -> Struct {
        generateStruct(
            resourceName: resourceName,
            plists: plists,
            toplevelKeysWhitelist: ["UIApplicationShortcutItems", "UIApplicationSceneManifest", "NSUserActivityTypes", "NSExtension"],
            isInfoPlist: true,
            prefix: prefix
        )
    }

    public static func generateStruct(resourceName: String, plists: [PropertyListResource], toplevelKeysWhitelist: [String]? = nil, isInfoPlist: Bool = false, prefix: SwiftIdentifier) -> Struct {
        let structName = SwiftIdentifier(name: resourceName)
        let qualifiedName = prefix + structName
        let warning: (String) -> Void = { print("warning: [R.swift]", $0) }

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

        let members = contents.generateMembers(resourceName: resourceName, path: [], isInfoPlist: isInfoPlist, warning: warning)
            .sorted()
        let comments = ["This `\(qualifiedName.value)` struct is generated, and contains static references to \(members.structs.count) properties."]

        return Struct(comments: comments, name: structName) {
            if isInfoPlist {
                Init.bundle
            }
            members
        }
    }
}

protocol PlistPathComponent {
    typealias Key = String
    typealias Index = Int
}

extension PlistPathComponent.Key: PlistPathComponent {}
extension PlistPathComponent.Index: PlistPathComponent {}

extension PropertyListResource.Contents {
    @StructMembersBuilder func generateMembers(resourceName: String, path: [PlistPathComponent], includeKey: Bool = true, isInfoPlist: Bool, warning: (String) -> Void) -> StructMembers {
        let groupedContents = self.grouped(bySwiftIdentifier: { $0.key })
        groupedContents.reportWarningsForDuplicatesAndEmpties(source: resourceName, result: resourceName, warning: warning)

        for (key, value) in groupedContents.uniques {
            let newPath = path + [key]

            switch value {
            case let value as Bool:
                LetBinding(
                    name: SwiftIdentifier(name: key),
                    typeReference: .bool,
                    valueCodeString: "\(value)"
                )

              case let value as String:
                if isInfoPlist {
                    VarGetter(
                        name: SwiftIdentifier(name: key),
                        typeReference: .string,
                        valueCodeString: valueCodedString(path: path, includeKey: includeKey, key: key, value: value)
                    )
                } else {
                    LetBinding(
                        name: SwiftIdentifier(name: key),
                        typeReference: .string,
                        valueCodeString: "\"\(value.escapedStringLiteral)\""
                    )
                }

            case let duplicateArray as [String]:
                let groupedArray = duplicateArray.grouped(bySwiftIdentifier: { $0 })
                groupedArray.reportWarningsForDuplicatesAndEmpties(source: resourceName, result: resourceName, warning: warning)

                bundleStruct(name: key, usesBundle: isInfoPlist) {
                    for (index, value) in groupedArray.uniques.enumerated() {
                        [value: value]
                            .generateMembers(resourceName: resourceName, path: newPath + [index], includeKey: false, isInfoPlist: isInfoPlist, warning: warning)
                            .sorted()
                    }
                }


            case var dict as [String: Any]:
                dict["_key"] = key

                bundleStruct(name: key, usesBundle: isInfoPlist) {
                    dict.generateMembers(resourceName: resourceName, path: newPath, isInfoPlist: isInfoPlist, warning: warning)
                        .sorted()
                }

            case let dicts as [[String: Any]] where arrayOfDictionariesPrimaryKeys.keys.contains(key):
                bundleStruct(name: key, usesBundle: isInfoPlist) {
                    for (index, dict) in dicts.enumerated() {
                        if let primaryKey = arrayOfDictionariesPrimaryKeys[key],
                           let primary = dict[primaryKey] as? String {
                            bundleStruct(name: primary, usesBundle: isInfoPlist) {
                                dict.generateMembers(resourceName: resourceName, path: newPath + [index], isInfoPlist: isInfoPlist, warning: warning)
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
    
    private func valueCodedString(path: [PlistPathComponent], includeKey: Bool, key: String, value: String) -> String {
        var string = "bundle.infoDictionaryString(path: \(path)"

        if includeKey {
            string += ", key: \"\(key.escapedStringLiteral)\""
        }

        return string + ") ?? \"\(value.escapedStringLiteral)\""
    }
}

@StructMembersBuilder func bundleStruct(name: String, usesBundle: Bool, @StructMembersBuilder builder: () -> StructMembers) -> StructMembers {
    let str = Struct(name: SwiftIdentifier(name: name)) {
        if usesBundle {
            Init.bundle
        }
        builder()
    }

    if usesBundle {
        str.generateBundleVarGetter(name: name)
        str.generateBundleFunction(name: name)
    } else {
        str.generateLetBinding()
    }
    str
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
