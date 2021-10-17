//
//  File.swift
//
//
//  Created by lmcmz on 12/9/21.
//

import BigInt
import Foundation
import NIO

public func cadence(text: () -> String) -> Flow.TransactionBuild {
    return Flow.TransactionBuild.script(Flow.Script(script: text()))
}

public func cadence(text: () -> Flow.Script) -> Flow.TransactionBuild {
    return Flow.TransactionBuild.script(text())
}

public func arguments(text: () -> [Flow.Cadence.FValue]) -> Flow.TransactionBuild {
    return Flow.TransactionBuild.argument(text().compactMap { Flow.Argument(value: $0) })
}

public func arguments(text: () -> [Flow.Argument]) -> Flow.TransactionBuild {
    return Flow.TransactionBuild.argument(text())
}

public func arguments(text: () -> Flow.Argument...) -> Flow.TransactionBuild {
    return Flow.TransactionBuild.argument(text.compactMap { $0() })
}

public func payer(text: () -> String) -> Flow.TransactionBuild {
    return Flow.TransactionBuild.payer(Flow.Address(hex: text()))
}

public func payer(text: () -> Flow.Address) -> Flow.TransactionBuild {
    return Flow.TransactionBuild.payer(text())
}

public func authorizers(text: () -> [Flow.Address]) -> Flow.TransactionBuild {
    return Flow.TransactionBuild.authorizers(text())
}

public func authorizers(text: () -> Flow.Address...) -> Flow.TransactionBuild {
    return Flow.TransactionBuild.authorizers(text.compactMap { $0() })
}

public func proposer(text: () -> String) -> Flow.TransactionBuild {
    let address = Flow.Address(hex: text())
    return Flow.TransactionBuild.proposer(Flow.TransactionProposalKey(address: address))
}

public func proposer(text: () -> Flow.Address) -> Flow.TransactionBuild {
    return Flow.TransactionBuild.proposer(Flow.TransactionProposalKey(address: text()))
}

public func proposer(text: () -> Flow.TransactionProposalKey) -> Flow.TransactionBuild {
    return Flow.TransactionBuild.proposer(text())
}

public func gasLimit(text: () -> BigUInt) -> Flow.TransactionBuild {
    return Flow.TransactionBuild.gasLimit(text())
}

public func gasLimit(text: () -> Int) -> Flow.TransactionBuild {
    return Flow.TransactionBuild.gasLimit(BigUInt(text()))
}

public func refBlock(text: () -> String?) -> Flow.TransactionBuild {
    guard let blockId = text() else {
        return Flow.TransactionBuild.refBlock(nil)
    }
    return Flow.TransactionBuild.refBlock(Flow.ID(hex: blockId))
}

public func refBlock(text: () -> Flow.ID) -> Flow.TransactionBuild {
    return Flow.TransactionBuild.refBlock(text())
}

extension Flow {
    public enum TransactionBuild {
        case script(Flow.Script)
        case argument([Flow.Argument])
        case payer(Flow.Address)
        case authorizers([Flow.Address])
        case proposer(Flow.TransactionProposalKey)
        case gasLimit(BigUInt)
        case refBlock(Flow.ID?)
    }

    @resultBuilder
    public class TransactionBuilder {
        public static func buildBlock() -> [Flow.TransactionBuild] { [] }

        public static func buildArray(_ components: [[Flow.TransactionBuild]]) -> [Flow.TransactionBuild] {
            return components.flatMap { $0 }
        }

        public static func buildBlock(_ components: Flow.TransactionBuild...) -> [Flow.TransactionBuild] {
            components
        }
    }
}

extension Flow {
    public func buildTransaction(chainID: Flow.ChainID = flow.defaultChainID,
                                 fetchSequenceNumber: Bool = true,
                                 @Flow .TransactionBuilder builder: () -> [Flow.TransactionBuild]) throws -> Flow.Transaction {
        var script: Flow.Script = .init(data: Data())
        var agrument: [Flow.Argument] = []
        var authorizers: [Flow.Address] = []
        var payerAddress: Flow.Address?
        var proposer: Flow.TransactionProposalKey?
        var gasLimit = BigUInt(100)
        var refBlock: Flow.ID?

        builder().forEach { txValue in
            switch txValue {
            case let .script(value):
                script = value
            case let .argument(value):
                agrument = value
            case let .authorizers(value):
                authorizers = value
            case let .payer(value):
                payerAddress = value
            case let .proposer(value):
                proposer = value
            case let .gasLimit(value):
                gasLimit = value
            case let .refBlock(value):
                refBlock = value
            }
        }

        guard var proposalKey = proposer else {
            throw Flow.FError.emptyProposer
        }

        let api = Flow.shared.createAccessAPI(chainID: chainID)

        if refBlock == nil, let block = try? api.getLatestBlock(sealed: true).wait() {
            refBlock = block.id
        }

        guard let blockID = refBlock else {
            throw Flow.FError.preparingTransactionFailed
        }

        if fetchSequenceNumber {
            guard let proposerAccount = try? api.getAccountAtLatestBlock(address: proposalKey.address).wait(),
                let accountKey = proposerAccount.keys[safe: proposalKey.keyIndex] else {
                throw Flow.FError.preparingTransactionFailed
            }

            proposalKey.keyIndex = accountKey.id
            proposalKey.sequenceNumber = BigUInt(accountKey.sequenceNumber)
        }

        return Flow.Transaction(script: script,
                                arguments: agrument,
                                referenceBlockId: blockID,
                                gasLimit: gasLimit,
                                proposalKey: proposalKey,
                                // If payer is empty, then use propser as payer
                                payerAddress: payerAddress ?? proposalKey.address,
                                authorizers: authorizers)
    }

    public func sendTransaction(chainID: ChainID = .mainnet, signedTrnaction: Transaction) throws -> EventLoopFuture<Flow.ID> {
        let api = flow.createAccessAPI(chainID: chainID)
        return api.sendTransaction(transaction: signedTrnaction)
    }

    public func sendTransaction(chainID: Flow.ChainID = flow.defaultChainID,
                                signers: [FlowSigner],
                                @Flow .TransactionBuilder builder: () -> [Flow.TransactionBuild]) throws -> EventLoopFuture<Flow.ID> {
        let api = flow.createAccessAPI(chainID: chainID)
        let unsignedTx = try buildTransaction(chainID: chainID, builder: builder)
        let signedTx = try flow.signTransaction(unsignedTransaction: unsignedTx, signers: signers)

        return api.sendTransaction(transaction: signedTx)
    }

    public func sendTransaction(chainID: Flow.ChainID = flow.defaultChainID,
                                signers: [FlowSigner],
                                @Flow .TransactionBuilder builder: () -> [Flow.TransactionBuild],
                                completion: @escaping (Result<Flow.ID, Error>) -> Void) throws {
        let api = flow.createAccessAPI(chainID: chainID)
        let unsignedTx = try buildTransaction(chainID: chainID, builder: builder)
        let signedTx = try flow.signTransaction(unsignedTransaction: unsignedTx, signers: signers)
        let call = api.sendTransaction(transaction: signedTx)
        call.whenSuccess { completion(Result.success($0)) }
        call.whenFailure { completion(Result.failure($0)) }
    }
}
