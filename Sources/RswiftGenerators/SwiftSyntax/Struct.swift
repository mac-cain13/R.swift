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


public struct StructMembers {
    var lets: [LetBinding] = []
    var structs: [Struct] = []

    func sorted() -> StructMembers {
        var new = self
        new.lets.sort { $0.name < $1.name }
        new.structs.sort { $0.name < $1.name }
        return new
    }
}

@resultBuilder
public struct StructMembersBuilder {
    public static func buildExpression(_ expression: LetBinding) -> StructMembers {
        StructMembers(lets: [expression])
    }

    public static func buildExpression(_ expressions: [LetBinding]) -> StructMembers {
        StructMembers(lets: expressions)
    }

    public static func buildExpression(_ expression: Struct) -> StructMembers {
        StructMembers(structs: [expression])
    }

    public static func buildExpression(_ expressions: [Struct]) -> StructMembers {
        StructMembers(structs: expressions)
    }

    public static func buildExpression(_ members: StructMembers) -> StructMembers {
        members
    }

    public static func buildExpression(_ members: Void) -> StructMembers {
        StructMembers()
    }

    public static func buildArray(_ members: [StructMembers]) -> StructMembers {
        StructMembers(lets: members.flatMap(\.lets), structs: members.flatMap(\.structs))
    }

    public static func buildEither(first component: StructMembers) -> StructMembers {
        component
    }

    public static func buildEither(second component: StructMembers) -> StructMembers {
        component
    }

    public static func buildOptional(_ component: StructMembers?) -> StructMembers {
        component ?? StructMembers()
    }

    public static func buildBlock(_ members: StructMembers...) -> StructMembers {
        StructMembers(lets: members.flatMap(\.lets), structs: members.flatMap(\.structs))
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

    public static var empty: Struct = Struct(name: SwiftIdentifier(name: "empty"), membersBuilder: {})

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
        let members = membersBuilder()
        self.lets = members.lets
        self.structs = members.structs
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
                if !st.comments.isEmpty {
                    pp.append(line: "")
                }
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
