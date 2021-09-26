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

func payer(text: () -> String) -> Flow.Build.Payer {
    return Flow.Build.Payer(address: Flow.Address(hex: text()))
}

func payer(text: () -> Flow.Address) -> Flow.Build.Payer {
    return Flow.Build.Payer(address: text())
}

func authorizers(text: () -> [Flow.Address]) -> Flow.Build.Authorizers {
    return Flow.Build.Authorizers(addresses: text())
}

func authorizers(text: () -> Flow.Address...) -> Flow.Build.Authorizers {
    return Flow.Build.Authorizers(addresses: text.compactMap { $0() })
}

func proposer(text: () -> Flow.Address) -> Flow.Build.Proposer {
    return Flow.Build.Proposer(proposalKey: Flow.TransactionProposalKey(address: text()))
}

func proposer(text: () -> Flow.TransactionProposalKey) -> Flow.Build.Proposer {
    return Flow.Build.Proposer(proposalKey: text())
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

        struct Payer: TransactionValue {
            let address: Flow.Address
        }

        struct Authorizers: TransactionValue {
            let addresses: [Flow.Address]
        }

        struct Proposer: TransactionValue {
            let proposalKey: Flow.TransactionProposalKey
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
                            gasLimit: BigUInt = BigUInt(100),
                            @Flow .TransactionBuilder _ content: () -> [TransactionValue]) throws -> Flow.Transaction? {
    var script = Flow.Script(script: "")
    var agrument = [Flow.Argument]()
    var authorizers = [Flow.Address]()
    var payerAddress = Flow.Address(hex: "")
    var proposer = Flow.TransactionProposalKey(address: Flow.Address(hex: ""))

    content().forEach { txValue in
        switch txValue {
        case let value as Flow.Build.Script:
            script = Flow.Script(script: value.script)
        case let value as Flow.Build.Argument:
            agrument = value.arguments
        case let value as Flow.Build.Authorizers:
            authorizers = value.addresses
        case let value as Flow.Build.Payer:
            payerAddress = value.address
        case let value as Flow.Build.Proposer:
            proposer = value.proposalKey
        default:
            return
        }
    }

    guard let testnetAPI = Flow.shared.newAccessApi(chainId: chainId),
        let block = try? testnetAPI.getLatestBlock(sealed: true).wait(),
        let proposerAccount = try? testnetAPI.getAccountAtLatestBlock(address: proposer.address).wait(),
        let accountKey = proposerAccount.keys[safe: proposer.keyIndex] else {
        return nil
    }

    proposer.keyIndex = accountKey.id
    proposer.sequenceNumber = BigUInt(accountKey.sequenceNumber)

    return Flow.Transaction(script: script,
                            arguments: agrument,
                            referenceBlockId: block.id,
                            gasLimit: gasLimit,
                            proposalKey: proposer,
                            payerAddress: payerAddress,
                            authorizers: authorizers)
}

extension Flow.TransactionBuilder {
    static func buildBlock(_ settings: TransactionValue...) -> [TransactionValue] {
        settings
    }
}

extension Array where Element == TransactionValue {
    func build() {}
}
