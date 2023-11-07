import Foundation

struct XCString: Decodable {
    let sourceLanguage: String
    let strings: [String: XCStringString]
    let version: String
}

struct XCStringString: Decodable {
    let localizations: [String: XCLocalization]
}

struct XCLocalization: Decodable {
    let stringUnit: XCStringUnit?
    let variations: XCVariations?
    let substitutions: [String: XCSubstitution]?
}

struct XCVariations: Decodable {
    let plural: [String: XCPluralVariationsValue]?
    let device: [String: XCPluralVariationsValue]?
}

struct XCPluralVariationsValue: Decodable {
    let stringUnit: XCStringUnit?
    let variations: XCVariations?
}

struct XCStringUnit: Decodable {
    let value: String
}

struct XCSubstitution: Decodable {
    let argNum: Int?
    let formatSpecifier: String
    let variations: XCVariations
}
