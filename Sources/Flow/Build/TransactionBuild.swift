//
//  File.swift
//
//
//  Created by lmcmz on 12/9/21.
//

import Foundation

protocol TransactionValue {
//    func build(into stream: Flow.Transaction)
}

func script(_ text: () -> String) -> Flow.Build.Script {
    return Flow.Build.Script(script: text())
}

extension Flow {
    class Build {
        struct Address: TransactionValue {
            let address: String
        }

        struct Script: TransactionValue {
            let script: String
        }
    }

    @resultBuilder
    struct TransactionBuilder {
        static func buildBlock() -> [TransactionValue] { [] }

        static func buildArray(_ components: [[TransactionValue]]) -> [TransactionValue] {
            return components.flatMap { $0 }
        }
    }
}

func buildTransaction(@Flow .TransactionBuilder _ content: () -> [TransactionValue]) -> [TransactionValue] {
    content()
}

extension Flow.TransactionBuilder {
    static func buildBlock(_ settings: TransactionValue...) -> [TransactionValue] {
        settings
    }
}
