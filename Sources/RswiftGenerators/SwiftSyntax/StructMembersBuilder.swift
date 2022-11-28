//
//  StructMembersBuilder.swift
//  
//
//  Created by Tom Lokhorst on 2022-07-29.
//

import Foundation

public struct StructMembers {
    var lets: [LetBinding] = []
    var vars: [VarGetter] = []
    var inits: [Init] = []
    var funcs: [Function] = []
    var structs: [Struct] = []
    var typealiasses: [TypeAlias] = []

    func sorted() -> StructMembers {
        var new = self
        new.lets.sort { $0.name < $1.name }
        new.vars.sort { $0.name < $1.name }
        new.funcs.sort { $0.name < $1.name }
        new.structs.sort { $0.name < $1.name }
        new.typealiasses.sort { $0.name < $1.name }
        return new
    }
}

@resultBuilder
public struct StructMembersBuilder {
    public static func buildExpression(_ members: Void) -> StructMembers {
        StructMembers()
    }

    public static func buildExpression(_ expression: LetBinding) -> StructMembers {
        StructMembers(lets: [expression])
    }

    public static func buildExpression(_ expressions: [LetBinding]) -> StructMembers {
        StructMembers(lets: expressions)
    }

    public static func buildExpression(_ expression: VarGetter) -> StructMembers {
        StructMembers(vars: [expression])
    }

    public static func buildExpression(_ expressions: [VarGetter]) -> StructMembers {
        StructMembers(vars: expressions)
    }

    public static func buildExpression(_ expression: Init) -> StructMembers {
        StructMembers(inits: [expression])
    }

    public static func buildExpression(_ expressions: [Init]) -> StructMembers {
        StructMembers(inits: expressions)
    }

    public static func buildExpression(_ expression: Function) -> StructMembers {
        StructMembers(funcs: [expression])
    }

    public static func buildExpression(_ expressions: [Function]) -> StructMembers {
        StructMembers(funcs: expressions)
    }

    public static func buildExpression(_ expression: Struct) -> StructMembers {
        StructMembers(structs: [expression])
    }

    public static func buildExpression(_ expressions: [Struct]) -> StructMembers {
        StructMembers(structs: expressions)
    }

    public static func buildExpression(_ expression: TypeAlias) -> StructMembers {
        StructMembers(typealiasses: [expression])
    }

    public static func buildExpression(_ expressions: [TypeAlias]) -> StructMembers {
        StructMembers(typealiasses: expressions)
    }

    public static func buildExpression(_ members: StructMembers) -> StructMembers {
        members
    }

    public static func buildArray(_ members: [StructMembers]) -> StructMembers {
        StructMembers(
            lets: members.flatMap(\.lets),
            vars: members.flatMap(\.vars),
            inits: members.flatMap(\.inits),
            funcs: members.flatMap(\.funcs),
            structs: members.flatMap(\.structs),
            typealiasses: members.flatMap(\.typealiasses)
        )
    }

    public static func buildBlock(_ members: StructMembers...) -> StructMembers {
        StructMembers(
            lets: members.flatMap(\.lets),
            vars: members.flatMap(\.vars),
            inits: members.flatMap(\.inits),
            funcs: members.flatMap(\.funcs),
            structs: members.flatMap(\.structs),
            typealiasses: members.flatMap(\.typealiasses)
        )
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
}
