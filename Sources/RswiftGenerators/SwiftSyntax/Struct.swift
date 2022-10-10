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

    public var allModuleReferences: Set<ModuleReference> {
        if let typeReference {
            return typeReference.allModuleReferences
        } else {
            return Set()
        }
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

public struct VarGetter {
    public let comments: [String]
    public var accessControl = AccessControl.none
    public let name: SwiftIdentifier
    public let typeReference: TypeReference
    public let valueCodeString: String

    public init(comments: [String] = [], accessControl: AccessControl = AccessControl.none, name: SwiftIdentifier, typeReference: TypeReference, valueCodeString: String) {
        self.comments = comments
        self.accessControl = accessControl
        self.name = name
        self.typeReference = typeReference
        self.valueCodeString = valueCodeString
    }

    public var allModuleReferences: Set<ModuleReference> {
        typeReference.allModuleReferences
    }

    func render(_ pp: inout PrettyPrinter) {
        let words: [String?] = [
            accessControl.code(),
            "var",
            "\(name.value):",
            typeReference.codeString(),
            "{",
            valueCodeString,
            "}"
        ]

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

    public init(comments: [String], accessControl: AccessControl = AccessControl.none, isStatic: Bool = false, name: SwiftIdentifier, params: [Parameter], returnType: TypeReference, valueCodeString: String) {
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

        public init(name: String, localName: String?, typeReference: TypeReference, defaultValue: String?) {
            self.name = name
            self.localName = localName
            self.typeReference = typeReference
            self.defaultValue = defaultValue
        }

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

    public var allModuleReferences: Set<ModuleReference> {
        Set(params.flatMap(\.typeReference.allModuleReferences))
            .union(returnType.allModuleReferences)
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


public struct Init {
    public let comments: [String]
    public var accessControl = AccessControl.none
    public let params: [Parameter]
    public let valueCodeString: String

    public init(comments: [String], accessControl: AccessControl = AccessControl.none, params: [Parameter], valueCodeString: String) {
        self.comments = comments
        self.accessControl = accessControl
        self.params = params
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

        var privateLetCodeString: String {
            let words: [String] = [
                "private",
                "let",
                "\(localName ?? name):",
                typeReference.codeString()
            ]

            return words.joined(separator: " ")
        }
    }

    public var allModuleReferences: Set<ModuleReference> {
        Set(params.flatMap(\.typeReference.allModuleReferences))
    }

    func render(_ pp: inout PrettyPrinter) {

        for param in params {
            pp.append(line: param.privateLetCodeString)
        }

        for c in comments {
            pp.append(words: ["///", c == "" ? nil : c])
        }

        let prs = params.map { $0.codeString() }.joined(separator: ", ")
        let words: [String?] = [
            accessControl.code(),
            "init(\(prs))",
            "{"
        ]

        pp.append(words: words)
        pp.indented { pp in
            pp.append(line: valueCodeString)
        }
        pp.append(line: "}")
    }

    public static var bundle: Init {
        Init(
            comments: [],
            params: [Parameter(name: "bundle", localName: "_bundle", typeReference: .bundle, defaultValue: nil),],
            valueCodeString: "self._bundle = _bundle"
        )
    }

    public static var bundleLocale: Init {
        Init(
            comments: [],
            params: [
                Parameter(name: "bundle", localName: "_bundle", typeReference: .bundle, defaultValue: nil),
                Parameter(name: "locale", localName: "_locale", typeReference: .locale, defaultValue: nil),
            ],
            valueCodeString: """
                self._bundle = _bundle
                self._locale = _locale
                """
        )
    }
}

public struct TypeAlias {
    public let comments: [String]
    public var accessControl = AccessControl.none
    public let name: String
    public let value: TypeReference

    public init(comments: [String] = [], accessControl: AccessControl = AccessControl.none, name: String, value: TypeReference) {
        self.comments = comments
        self.accessControl = accessControl
        self.name = name
        self.value = value
    }

    public var allModuleReferences: Set<ModuleReference> {
        value.allModuleReferences
    }

    func render(_ pp: inout PrettyPrinter) {

        for c in comments {
            pp.append(words: ["///", c == "" ? nil : c])
        }

        let words: [String?] = [
            accessControl.code(),
            "typealias",
            name,
            "=",
            value.codeString()
        ]

        pp.append(words: words)
    }
}

public struct Struct {
    public let comments: [String]
    public var accessControl = AccessControl.none
    public let name: SwiftIdentifier
    public var protocols: [TypeReference] = []
    public var lets: [LetBinding] = []
    public var vars: [VarGetter] = []
    public var inits: [Init] = []
    public var funcs: [Function] = []
    public var structs: [Struct] = []
    public var typealiasses: [TypeAlias] = []

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
        self.vars = members.vars
        self.inits = members.inits
        self.funcs = members.funcs
        self.structs = members.structs
        self.typealiasses = members.typealiasses
    }

    public var isEmpty: Bool {
        lets.isEmpty && vars.isEmpty && funcs.isEmpty && structs.isEmpty
    }

    public var allModuleReferences: Set<ModuleReference> {
        var result: Set<ModuleReference> = []
        result.formUnion(protocols.flatMap(\.allModuleReferences))
        result.formUnion(lets.flatMap(\.allModuleReferences))
        result.formUnion(vars.flatMap(\.allModuleReferences))
        result.formUnion(inits.flatMap(\.allModuleReferences))
        result.formUnion(funcs.flatMap(\.allModuleReferences))
        result.formUnion(structs.flatMap(\.allModuleReferences))
        result.formUnion(typealiasses.flatMap(\.allModuleReferences))

        return result
    }

    public mutating func setAccessControl(_ accessControl: AccessControl) {
        self.accessControl = accessControl
        for i in lets.indices {
            lets[i].accessControl = accessControl
        }
        for i in vars.indices {
            vars[i].accessControl = accessControl
        }
        for i in inits.indices {
            inits[i].accessControl = accessControl
        }
        for i in funcs.indices {
            funcs[i].accessControl = accessControl
        }
        for i in structs.indices {
            structs[i].setAccessControl(accessControl)
        }
        for i in typealiasses.indices {
            typealiasses[i].accessControl = accessControl
        }
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
        pp.append(words: [accessControl.code(), "struct", "\(name.value)\(implements)", "{"])

        pp.indented { pp in
            for talias in typealiasses {
                if !talias.comments.isEmpty {
                    pp.append(line: "")
                }
                talias.render(&pp)
            }
        }

        if !typealiasses.isEmpty && !inits.isEmpty {
            pp.append(line: "")
        }

        pp.indented { pp in
            for inib in inits {
                if !inib.comments.isEmpty {
                    pp.append(line: "")
                }
                inib.render(&pp)
            }
        }

        if !inits.isEmpty && !lets.isEmpty {
            pp.append(line: "")
        }

        pp.indented { pp in
            for letb in lets {
                if !letb.comments.isEmpty {
                    pp.append(line: "")
                }
                letb.render(&pp)
            }
        }

        if !lets.isEmpty && !vars.isEmpty {
            pp.append(line: "")
        }

        pp.indented { pp in
            for varb in vars {
                if !varb.comments.isEmpty {
                    pp.append(line: "")
                }
                varb.render(&pp)
            }
        }

        if !vars.isEmpty && !funcs.isEmpty {
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


extension Struct {
    public func generateLetBinding() -> LetBinding {
        LetBinding(
            name: name,
            valueCodeString: "\(name.value)()"
        )
    }

    public func generateBundleVarGetter(name: String) -> VarGetter {
        VarGetter(
            name: SwiftIdentifier(name: name),
            typeReference: TypeReference(module: .host, rawName: self.name.value),
            valueCodeString: ".init(bundle: _bundle)"
        )
    }

    public func generateBundleFunction(name: String) -> Function {
        Function(
            comments: [],
            name: SwiftIdentifier(name: name),
            params: [.init(name: "bundle", localName: nil, typeReference: .bundle, defaultValue: nil)],
            returnType: TypeReference(module: .host, rawName: self.name.value),
            valueCodeString: ".init(bundle: bundle)"
        )
    }
}
