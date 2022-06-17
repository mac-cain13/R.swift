//
//  OSPrinter.swift
//  RswiftCore
//
//  Created by Lammert Westerhoff on 28/08/2018.
//

import Foundation

/// Prints the code wrapped inside #if os(...) / #endif preprocessors if the code is only supported by certain operating systems
struct OSPrinter: SwiftCodeConverible {
    let swiftCode: String

    init(code: String, supportedOS: [String]) {
        guard supportedOS.count > 0 else {
            swiftCode = code
            return
        }

        let preprocessorStartString = supportedOS.enumerated().reduce("") { result, item in
            let (index, os) = item
            var result = result
            if index == 0 {
                result += "#if "
            } else {
                result += " || "
            }
            return result + "os(\(os))"
        }
        swiftCode = "\(preprocessorStartString)\n\(code)\n#endif"
    }
}
