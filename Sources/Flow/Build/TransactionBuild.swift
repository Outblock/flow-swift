//
//  TransactionBuild
//
//  Copyright 2022 Outblock Pty Ltd
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import BigInt
import Combine
import Foundation

/// Build flow transaction with cadence code with `String` input.
/// - parameters:
///     - text: Cadence code in `String` type.
/// - returns: The type of `Flow.TransactionBuild.script`
public func cadence(text: () -> String) -> Flow.TransactionBuild {
    return Flow.TransactionBuild.script(Flow.Script(text: text()))
}

/// Build flow transaction with cadence code with `Flow.Script` input.
/// - parameters:
///     - text: Cadence code in `Flow.Script` type.
/// - returns: The type of `Flow.TransactionBuild.script`
public func cadence(text: () -> Flow.Script) -> Flow.TransactionBuild {
    return Flow.TransactionBuild.script(text())
}

/// Build flow transaction with arguments with a list of `Flow.Cadence.FValue` input.
/// - parameters:
///     - text: The list of `Flow.Cadence.FValue` type.
/// - returns: The type of `Flow.TransactionBuild.argument`
public func arguments(text: () -> [Flow.Cadence.FValue]) -> Flow.TransactionBuild {
    return Flow.TransactionBuild.argument(text().compactMap { Flow.Argument(value: $0) })
}

/// Build flow transaction with arguments with a list of `Flow.Argument` input.
/// - parameters:
///     - text: The list of `Flow.Argument` type.
/// - returns: The type of `Flow.TransactionBuild.argument`
public func arguments(text: () -> [Flow.Argument]) -> Flow.TransactionBuild {
    return Flow.TransactionBuild.argument(text())
}

/// Build flow transaction with arguments with a list of `Flow.Argument` input.
/// - parameters:
///     - text: The list of `Flow.Argument` type.
/// - returns: The type of `Flow.TransactionBuild.argument`
public func arguments(text: () -> Flow.Argument...) -> Flow.TransactionBuild {
    return Flow.TransactionBuild.argument(text.compactMap { $0() })
}

/// Build flow transaction with payer
/// - parameters:
///     - text: payer address in `String` type
/// - returns: The type of `Flow.TransactionBuild.payer`
public func payer(text: () -> String) -> Flow.TransactionBuild {
    return Flow.TransactionBuild.payer(Flow.Address(hex: text()))
}

/// Build flow transaction with payer
/// - parameters:
///     - text: payer address in `Flow.Address` type
/// - returns: The type of `Flow.TransactionBuild.payer`
public func payer(text: () -> Flow.Address) -> Flow.TransactionBuild {
    return Flow.TransactionBuild.payer(text())
}

/// Build flow transaction with authorizers
/// - parameters:
///     - text: A list of authorizer's account
/// - returns: The type of `Flow.TransactionBuild.authorizers`
public func authorizers(text: () -> [Flow.Address]) -> Flow.TransactionBuild {
    return Flow.TransactionBuild.authorizers(text())
}

/// Build flow transaction with authorizers
/// - parameters:
///     - text: A list of authorizer's account
/// - returns: The type of `Flow.TransactionBuild.authorizers`
public func authorizers(text: () -> Flow.Address...) -> Flow.TransactionBuild {
    return Flow.TransactionBuild.authorizers(text.compactMap { $0() })
}

/// Build flow transaction with proposer
/// - parameters:
///     - text: proposer key in `String` type
/// - returns: The type of `Flow.TransactionBuild.proposer`
/// -
/// The default proposal key will use key index 0,
/// and the sequence number will fetch from network
public func proposer(text: () -> String) -> Flow.TransactionBuild {
    let address = Flow.Address(hex: text())
    return Flow.TransactionBuild.proposer(Flow.TransactionProposalKey(address: address))
}

/// Build flow transaction with proposer
/// - parameters:
///     - text: proposer key in `Flow.Address` type
/// - returns: The type of `Flow.TransactionBuild.proposer`
/// -
/// The default proposal key will use key index 0,
/// and the sequence number will fetch from network
public func proposer(text: () -> Flow.Address) -> Flow.TransactionBuild {
    return Flow.TransactionBuild.proposer(Flow.TransactionProposalKey(address: text()))
}

/// Build flow transaction with proposer
/// - parameters:
///     - text: proposer key in `Flow.TransactionProposalKey` type
/// - returns: The type of `Flow.TransactionBuild.proposer`
public func proposer(text: () -> Flow.TransactionProposalKey) -> Flow.TransactionBuild {
    return Flow.TransactionBuild.proposer(text())
}

/// Build flow transaction with gas limit
/// - parameters:
///     - text: gas limit in `BigUInt` type
/// - returns: The type of `Flow.TransactionBuild.gasLimit`
public func gasLimit(text: () -> BigUInt) -> Flow.TransactionBuild {
    return Flow.TransactionBuild.gasLimit(text())
}

/// Build flow transaction with gas limit
/// - parameters:
///     - text: gas limit in `Int` type
/// - returns: The type of `Flow.TransactionBuild.gasLimit`
public func gasLimit(text: () -> Int) -> Flow.TransactionBuild {
    return Flow.TransactionBuild.gasLimit(BigUInt(text()))
}

/// Build flow transaction with reference block id
/// - parameters:
///     - text: block id in `String` type
/// - returns: The type of `Flow.TransactionBuild.refBlock`
public func refBlock(text: () -> String?) -> Flow.TransactionBuild {
    guard let blockId = text() else {
        return Flow.TransactionBuild.refBlock(nil)
    }
    return Flow.TransactionBuild.refBlock(Flow.ID(hex: blockId))
}

/// Build flow transaction with reference block id
/// - parameters:
///     - text: reference block id in `Flow.ID` type
/// - returns: The type of `Flow.TransactionBuild.refBlock`
public func refBlock(text: () -> Flow.ID) -> Flow.TransactionBuild {
    return Flow.TransactionBuild.refBlock(text())
}

public extension Flow {
    /// The list of all the acceptable property
    enum TransactionBuild {
        /// Cadence script
        case script(Flow.Script)

        /// Arguments for cadence script
        case argument([Flow.Argument])

        /// Payer address.
        /// If payer is same as proposer, then payer input is optional.
        case payer(Flow.Address)

        /// A list of address for authorizers
        case authorizers([Flow.Address])

        /// Proposer address
        case proposer(Flow.TransactionProposalKey)

        /// Gas limit (Optional)
        case gasLimit(BigUInt)

        /// Reference block id (Optional)
        case refBlock(Flow.ID?)
    }

    /// Use domain-specific language (DSL) to construct `Flow.Transaction`
    @resultBuilder
    enum TransactionBuilder {
        public static func buildBlock() -> [Flow.TransactionBuild] { [] }

        public static func buildArray(_ components: [[Flow.TransactionBuild]]) -> [Flow.TransactionBuild] {
            return components.flatMap { $0 }
        }

        public static func buildBlock(_ components: Flow.TransactionBuild...) -> [Flow.TransactionBuild] {
            components
        }
    }
}

public extension Flow {
    /// Build flow transaction using `TransactionBuilder` with async way
    /// - parameters:
    ///     - chainID: The chain id for the transaction, the default value is `flow.chainID`
    ///     - builder: The list of `Flow.TransactionBuild`
    /// - returns: The type of `EventLoopFuture<Flow.Transaction>`
    func buildTransaction(chainID: Flow.ChainID = flow.chainID,
                          @Flow.TransactionBuilder builder: () -> [Flow.TransactionBuild]) async throws -> Flow.Transaction
    {
        var script: Flow.Script = .init(data: Data())
        var agrument: [Flow.Argument] = []
        var authorizers: [Flow.Address] = []
        var payer: Flow.Address?
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
                payer = value
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

        func resolveBlockId(api: FlowAccessProtocol = flow.accessAPI, refBlock: Flow.ID?) async throws -> Flow.ID {
            if let blockID = refBlock {
                return blockID
            } else {
                let block = try await api.getLatestBlock(sealed: true)
                return block.id
            }
        }

        func resolveProposalKey(api: FlowAccessProtocol = flow.accessAPI, proposalKey: Flow.TransactionProposalKey) async throws -> Flow.TransactionProposalKey {
            if proposalKey.sequenceNumber == -1 {
                let account = try await api.getAccountAtLatestBlock(address: proposalKey.address)
                guard let accountKey = account.keys[safe: proposalKey.keyIndex] else {
                    throw Flow.FError.preparingTransactionFailed
                }
                return TransactionProposalKey(address: account.address,
                                              keyIndex: proposalKey.keyIndex,
                                              sequenceNumber: Int64(accountKey.sequenceNumber))
            }

            return proposalKey
        }

        let api = flow.accessAPI
        let id = try await resolveBlockId(api: api, refBlock: refBlock)
        let key = try await resolveProposalKey(api: api, proposalKey: proposalKey)
        proposalKey = key
        return Flow.Transaction(script: script,
                                arguments: agrument,
                                referenceBlockId: id,
                                gasLimit: gasLimit,
                                proposalKey: proposalKey,
                                // If payer is empty, then use propser as payer
                                payer: payer ?? proposalKey.address,
                                authorizers: authorizers)
    }

    /// Send signed Transaction to the network
    /// - parameters:
    ///     - chainID: The chain id for the transaction, the default value is `flow.chainID`
    ///     - signedTransaction: The signed Flow transaction
    /// - returns: A future value of transaction id
    func sendTransaction(chainID: ChainID = flow.chainID, signedTransaction: Transaction) async throws -> Flow.ID {
        let api = flow.accessAPI
        return try await api.sendTransaction(transaction: signedTransaction)
    }

    /// Build, sign and send transaction to the network
    /// - parameters:
    ///     - chainID: The chain id for the transaction, the default value is `flow.chainID`
    ///     - signers: A list of `FlowSigner`, which will sign the transaction
    ///     - builder: The list of `Flow.TransactionBuild`
    /// - returns: The transaction id
    func sendTransaction(chainID: Flow.ChainID = flow.chainID,
                         signers: [FlowSigner],
                         @Flow.TransactionBuilder builder: () -> [Flow.TransactionBuild]) async throws -> Flow.ID
    {
        let api = flow.accessAPI
        let unsignedTx = try await buildTransaction(chainID: chainID, builder: builder)
        let signedTx = try await flow.signTransaction(unsignedTransaction: unsignedTx, signers: signers)

        return try await api.sendTransaction(transaction: signedTx)
    }
}
