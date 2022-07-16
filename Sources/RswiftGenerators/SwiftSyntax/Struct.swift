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
    public var accessControl = AccessControl.none
    public let name: SwiftIdentifier
    public let typeReference: TypeReference

    public init(accessControl: AccessControl = AccessControl.none, name: SwiftIdentifier, typeReference: TypeReference) {
        self.accessControl = accessControl
        self.name = name
        self.typeReference = typeReference
    }

    func render(_ pp: inout PrettyPrinter) {
        pp.append(words: [accessControl.code(), "let", "\(name.value):", typeReference.rawName])
    }
}


public typealias StructMembers = ([LetBinding], [Struct])

@resultBuilder
public struct StructMembersBuilder {
    public static func buildExpression(_ expression: LetBinding) -> StructMembers {
        ([expression], [])
    }
    public static func buildExpression(_ expression: Struct) -> StructMembers {
        ([], [expression])
    }

    public static func buildBlock(_ members: StructMembers...) -> StructMembers {
        (members.flatMap(\.0), members.flatMap(\.1))
    }
}

public struct Struct {
    public var accessControl = AccessControl.none
    public let name: SwiftIdentifier
    public var lets: [LetBinding] = []
    public var structs: [Struct] = []

    public init(accessControl: AccessControl = AccessControl.none, name: SwiftIdentifier, lets: [LetBinding]) {
        self.accessControl = accessControl
        self.name = name
        self.lets = lets
    }

    public init(accessControl: AccessControl = AccessControl.none, _ rawName: String, @StructMembersBuilder membersBuilder: () -> StructMembers) {
        self.accessControl = accessControl
        self.name = SwiftIdentifier(rawValue: rawName)
        (self.lets, self.structs) = membersBuilder()
    }

    public func prettyPrint() -> String {
//        render().joined(separator: "\n")
        var pp = PrettyPrinter()
        render(&pp)
        return pp.render()
    }

    func render() -> [String] {
        var ls: [String] = []
        ls.append("struct \(name.value) {")
//        ls.append(contentsOf: lets.map { "  \($0.render())" })
        if !lets.isEmpty && !structs.isEmpty {
            ls.append("")
        }
        ls.append(contentsOf: structs.flatMap { $0.render().map { "  \($0)" } })
        ls.append("}")
        return ls
    }

    func render(_ pp: inout PrettyPrinter) {
        pp.append(line: "struct \(name.value) {")
        pp.increment()
        for letb in lets {
            letb.render(&pp)
        }
        pp.decrement()

        if !lets.isEmpty && !structs.isEmpty {
            pp.append(line: "")
        }

        pp.increment()
        for st in structs {
            st.render(&pp)
        }
        pp.decrement()

        pp.append(line: "}")
    }
}

struct PrettyPrinter {
    private var indent = 0
    private var lines: [(Int, String)] = []

    mutating func increment() {
        indent += 1
    }

    mutating func decrement() {
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
