//
//  File.swift
//
//
//  Created by lmcmz on 12/9/21.
//

import BigInt
import Foundation

protocol TransactionValue {}

func cadence(text: () -> String) -> Flow.Build.Script {
    return Flow.Build.Script(script: text())
}

func arguments(text: () -> [Flow.Argument]) -> Flow.Build.Argument {
    return Flow.Build.Argument(arguments: text())
}

func arguments(text: () -> Flow.Argument...) -> Flow.Build.Argument {
    return Flow.Build.Argument(arguments: text.compactMap { $0() })
}

extension Flow {
    class Build {
        struct Address: TransactionValue {
            let address: String
        }

        struct Script: TransactionValue {
            let script: String
        }

        struct Argument: TransactionValue {
            let arguments: [Flow.Argument]
        }
    }

    @resultBuilder
    class TransactionBuilder {
        static func buildBlock() -> [TransactionValue] { [] }

        static func buildArray(_ components: [[TransactionValue]]) -> [TransactionValue] {
            return components.flatMap { $0 }
        }
    }
}

func buildTransaction(@Flow .TransactionBuilder _ content: () -> [TransactionValue]) -> [TransactionValue] {
    content().forEach { txValue in
        switch txValue {
        case let value as Flow.Build.Script:
            print(value.script)
        case let value as Flow.Build.Argument:
            print(value.arguments)
        default:
            return
        }
    }
    return content()
}

func buildSimpleTransaction(chainId: Flow.ChainId = .mainnet,
                            address: Flow.Address,
                            gasLimit: BigUInt = BigUInt(100),
                            keyIndex: Int = 0,
                            @Flow .TransactionBuilder _ content: () -> [TransactionValue]) throws -> Flow.Transaction? {
    guard let testnetAPI = Flow.shared.newAccessApi(chainId: chainId),
        let block = try? testnetAPI.getLatestBlock(sealed: true).wait(),
        let payerAccount = try? testnetAPI.getAccountAtLatestBlock(address: address).wait(),
        let accountKey = payerAccount.keys.first else {
        return nil
    }

    var script = Flow.Script(script: "")
    var agrument = [Flow.Argument]()

    content().forEach { txValue in
        switch txValue {
        case let value as Flow.Build.Script:
            script = Flow.Script(script: value.script)
        case let value as Flow.Build.Argument:
            agrument = value.arguments
        default:
            return
        }
    }

    return Flow.Transaction(script: script,
                            arguments: agrument,
                            referenceBlockId: block.id,
                            gasLimit: gasLimit,
                            proposalKey: Flow.TransactionProposalKey(address: address, keyIndex: accountKey.id, sequenceNumber: BigUInt(accountKey.sequenceNumber)),
                            payerAddress: address, authorizers: [address])
}

extension Flow.TransactionBuilder {
    static func buildBlock(_ settings: TransactionValue...) -> [TransactionValue] {
        settings
    }
}

extension Array where Element == TransactionValue {
    func build() {}
}
