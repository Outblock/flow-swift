//
//  File.swift
//
//
//  Created by lmcmz on 12/9/21.
//

import BigInt
import Foundation

public protocol TransactionValue {}

public func cadence(text: () -> String) -> Flow.Build.Script {
    return Flow.Build.Script(script: text())
}

public func arguments(text: () -> [Flow.Argument]) -> Flow.Build.Argument {
    return Flow.Build.Argument(arguments: text())
}

public func arguments(text: () -> Flow.Argument...) -> Flow.Build.Argument {
    return Flow.Build.Argument(arguments: text.compactMap { $0() })
}

public func payer(text: () -> String) -> Flow.Build.Payer {
    return Flow.Build.Payer(address: Flow.Address(hex: text()))
}

public func payer(text: () -> Flow.Address) -> Flow.Build.Payer {
    return Flow.Build.Payer(address: text())
}

public func authorizers(text: () -> [Flow.Address]) -> Flow.Build.Authorizers {
    return Flow.Build.Authorizers(addresses: text())
}

public func authorizers(text: () -> Flow.Address...) -> Flow.Build.Authorizers {
    return Flow.Build.Authorizers(addresses: text.compactMap { $0() })
}

public func proposer(text: () -> Flow.Address) -> Flow.Build.Proposer {
    return Flow.Build.Proposer(proposalKey: Flow.TransactionProposalKey(address: text()))
}

public func proposer(text: () -> Flow.TransactionProposalKey) -> Flow.Build.Proposer {
    return Flow.Build.Proposer(proposalKey: text())
}

extension Flow {
    public class Build {
        public struct Address: TransactionValue {
            let address: String
        }

        public struct Script: TransactionValue {
            let script: String
        }

        public struct Argument: TransactionValue {
            let arguments: [Flow.Argument]
        }

        public struct Payer: TransactionValue {
            let address: Flow.Address
        }

        public struct Authorizers: TransactionValue {
            let addresses: [Flow.Address]
        }

        public struct Proposer: TransactionValue {
            let proposalKey: Flow.TransactionProposalKey
        }
    }

    @resultBuilder
    public class TransactionBuilder {
        static func buildBlock() -> [TransactionValue] { [] }

        static func buildArray(_ components: [[TransactionValue]]) -> [TransactionValue] {
            return components.flatMap { $0 }
        }
    }
}

extension Flow {
    public func buildTransaction(chainId: Flow.ChainId = .mainnet,
                                 gasLimit: BigUInt = BigUInt(100),
                                 @Flow .TransactionBuilder builder: () -> [TransactionValue]) throws -> Flow.Transaction? {
        var script: Flow.Script = .init(data: Data())
        var agrument: [Flow.Argument] = []
        var authorizers: [Flow.Address] = []
        var payerAddress: Flow.Address?
        var proposer: Flow.TransactionProposalKey?

        builder().forEach { txValue in
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

        guard var proposalKey = proposer else {
            throw Flow.FError.emptyProposer
        }

        guard let testnetAPI = Flow.shared.newAccessApi(chainId: chainId),
            let block = try? testnetAPI.getLatestBlock(sealed: true).wait(),
            let proposerAccount = try? testnetAPI.getAccountAtLatestBlock(address: proposalKey.address).wait(),
            let accountKey = proposerAccount.keys[safe: proposalKey.keyIndex] else {
            throw Flow.FError.preparingTransactionFailed
        }

        proposalKey.keyIndex = accountKey.id
        proposalKey.sequenceNumber = BigUInt(accountKey.sequenceNumber)

        return Flow.Transaction(script: script,
                                arguments: agrument,
                                referenceBlockId: block.id,
                                gasLimit: gasLimit,
                                proposalKey: proposalKey,
                                // If payer is empty, then use propser as payer
                                payerAddress: payerAddress ?? proposalKey.address,
                                authorizers: authorizers)
    }
}

extension Flow.TransactionBuilder {
    static func buildBlock(_ settings: TransactionValue...) -> [TransactionValue] {
        settings
    }
}

extension Array where Element == TransactionValue {
    func build() {}
}
