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
            typeReference?.codeString()
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


public struct Function {
    public let comments: [String]
    public var accessControl = AccessControl.none
    public let isStatic: Bool
    public let name: SwiftIdentifier
    public let params: [Parameter]
    public let returnType: TypeReference
    public let valueCodeString: String

    public init(comments: [String], accessControl: AccessControl = AccessControl.none, isStatic: Bool, name: SwiftIdentifier, params: [Parameter], returnType: TypeReference, valueCodeString: String) {
        self.comments = comments
        self.accessControl = accessControl
        self.isStatic = isStatic
        self.name = name
        self.params = params
        self.returnType = returnType
        self.valueCodeString = valueCodeString
    }

    public struct Parameter {
        public let name: String
        public let localName: String?
        public let typeReference: TypeReference
        public let defaultValue: String?

        func codeString() -> String {
            var result = name
            if let localName {
                result += " \(localName)"
            }
            result += ": \(typeReference.codeString())"
            if let defaultValue {
                result += " = \(defaultValue)"
            }

            return result
        }
    }

    func render(_ pp: inout PrettyPrinter) {
        let prs = params.map { $0.codeString() }.joined(separator: ", ")
        let words: [String?] = [
            accessControl.code(),
            isStatic ? "static" : nil,
            "func",
            "\(name.value)(\(prs))",
            "->",
            returnType.codeString(),
            "{"
        ]

        for c in comments {
            pp.append(words: ["///", c == "" ? nil : c])
        }
        pp.append(words: words)
        pp.indented { pp in
            pp.append(line: valueCodeString)
        }
        pp.append(line: "}")
    }
}

public struct Struct {
    public let comments: [String]
    public var accessControl = AccessControl.none
    public let name: SwiftIdentifier
    public var protocols: [TypeReference] = []
    public var lets: [LetBinding] = []
    public var funcs: [Function] = []
    public var structs: [Struct] = []

    public var isEmpty: Bool { lets.isEmpty && funcs.isEmpty && structs.isEmpty }

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
        self.funcs = members.funcs
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

        let ps = protocols.map { $0.codeString() }.joined(separator: ", ")
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

        if !lets.isEmpty && !funcs.isEmpty {
            pp.append(line: "")
        }

        pp.indented { pp in
            for fun in funcs {
                if !fun.comments.isEmpty {
                    pp.append(line: "")
                }
                fun.render(&pp)
            }
        }

        if !funcs.isEmpty && !structs.isEmpty {
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

    mutating func append(line str: String) {
        if str.isEmpty {
            lines.append((indent, ""))
        }
        for line in str.split(separator: "\n") {
            lines.append((indent, String(line)))
        }
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
