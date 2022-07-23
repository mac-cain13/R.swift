//
//  Struct.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-16.
//

import Foundation
import RswiftResources

public enum AccessControl {
    case none
    case `public`

    func code() -> String? {
        switch self {
        case .none:
            return nil
        case .public:
            return "public"
        }
    }
}

public struct LetBinding {
    public let comments: [String]
    public var accessControl = AccessControl.none
    public let isStatic: Bool
    public let name: SwiftIdentifier
    public let typeReference: TypeReference?
    public let valueCodeString: String?

    public init(comments: [String] = [], accessControl: AccessControl = AccessControl.none, isStatic: Bool = false, name: SwiftIdentifier, typeReference: TypeReference, valueCodeString: String?) {
        self.comments = comments
        self.accessControl = accessControl
        self.isStatic = isStatic
        self.name = name
        self.typeReference = typeReference
        self.valueCodeString = valueCodeString
    }

    public init(comments: [String] = [], accessControl: AccessControl = AccessControl.none, isStatic: Bool = false, name: SwiftIdentifier, valueCodeString: String) {
        self.comments = comments
        self.accessControl = accessControl
        self.isStatic = isStatic
        self.name = name
        self.typeReference = nil
        self.valueCodeString = valueCodeString
    }

    func render(_ pp: inout PrettyPrinter) {
        var words: [String?] = [
            accessControl.code(),
            isStatic ? "static" : nil,
            "let",
            typeReference == nil ? name.value : "\(name.value):",
            typeReference?.rawName
        ]
        if let valueCodeString = valueCodeString {
            words.append("=")
            words.append(valueCodeString)
        }

        for c in comments {
            pp.append(words: ["///", c == "" ? nil : c])
        }
        pp.append(words: words)
    }
}


public typealias StructMembers = ([LetBinding], [Struct])

@resultBuilder
public struct StructMembersBuilder {
    public static func buildExpression(_ expression: LetBinding) -> StructMembers {
        ([expression], [])
    }

    public static func buildExpression(_ expressions: [LetBinding]) -> StructMembers {
        (expressions, [])
    }

    public static func buildExpression(_ expression: Struct) -> StructMembers {
        ([], [expression])
    }

    public static func buildExpression(_ expressions: [Struct]) -> StructMembers {
        ([], expressions)
    }

    public static func buildArray(_ members: [StructMembers]) -> StructMembers {
        (members.flatMap(\.0), members.flatMap(\.1))
    }

    public static func buildBlock(_ members: StructMembers...) -> StructMembers {
        (members.flatMap(\.0), members.flatMap(\.1))
    }
}

public struct Struct {
    public let comments: [String]
    public var accessControl = AccessControl.none
    public let name: SwiftIdentifier
    public var protocols: [TypeReference] = []
    public var lets: [LetBinding] = []
    public var structs: [Struct] = []

    public var isEmpty: Bool { lets.isEmpty && structs.isEmpty }

    public init(
        comments: [String] = [],
        accessControl: AccessControl = AccessControl.none,
        name: SwiftIdentifier,
        protocols: [TypeReference] = [],
        @StructMembersBuilder membersBuilder: () -> StructMembers
    ) {
        self.comments = comments
        self.accessControl = accessControl
        self.name = name
        self.protocols = protocols
        (self.lets, self.structs) = membersBuilder()
    }

    public func prettyPrint() -> String {
        var pp = PrettyPrinter()
        render(&pp)
        return pp.render()
    }

    func render(_ pp: inout PrettyPrinter) {
        for c in comments {
            pp.append(words: ["///", c == "" ? nil : c])
        }

        let ps = protocols.map(\.rawName).joined(separator: ", ")
        let implements = ps.isEmpty ? "" : ": \(ps)"
        pp.append(line: "struct \(name.value)\(implements) {")

        pp.indented { pp in
            for letb in lets {
                if !letb.comments.isEmpty {
                    pp.append(line: "")
                }
                letb.render(&pp)
            }
        }

        if !lets.isEmpty && !structs.isEmpty {
            pp.append(line: "")
        }

        pp.indented { pp in
            for st in structs {
                st.render(&pp)
            }
        }

        pp.append(line: "}")
    }
}

struct PrettyPrinter {
    private var indent = 0
    private var lines: [(Int, String)] = []

    mutating func indented(perform: (inout PrettyPrinter) -> Void) {
        indent += 1
        perform(&self)
        indent -= 1
    }

    mutating func append(line: String) {
        lines.append((indent, line))
    }

    mutating func append(words: [String?]) {
        let ws = words.compactMap { $0 }
        if ws.isEmpty { return }

        append(line: ws.joined(separator: " "))
    }

    func render() -> String {
        let ls = lines.map { (indent, line) in
            String(repeating: "  ", count: indent) + line
        }
        return ls.joined(separator: "\n")
    }
}
