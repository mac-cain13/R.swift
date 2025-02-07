//
//  StringCatalog.swift
//  Rswift
//
//  Created by Mathijs Bernson on 15/01/2025.
//

import Foundation

public struct StringCatalog: Sendable, Decodable {
    public let sourceLanguage: String
    public let strings: [String : Translation]

    enum CodingKeys: CodingKey {
        case sourceLanguage
        case strings
        case version
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let version = try container.decode(String.self, forKey: .version)
        guard version == "1.0" else {
            throw DecodingError.dataCorruptedError(
                forKey: .version,
                in: container,
                debugDescription: "Unsupported version \(version). Expected version 1.0."
            )
        }

        self.sourceLanguage = try container.decode(String.self, forKey: .sourceLanguage)
        self.strings = try container.decode([String : Translation].self, forKey: .strings)
    }

    public typealias Key = String

    public struct Translation: Decodable, Sendable {
        public let localizations: [Key : Localization]
    }
    
    public struct Localization: Decodable, Sendable {
        public let stringUnit: StringUnit?
        public let variations: Variations?
    }
    
    public struct StringUnit: Decodable, Sendable {
        public let value: String
    }

    public struct Variations: Decodable, Sendable {
        public let plural: [String : Localization]?
        public let device: [String : Localization]?
    }
}
