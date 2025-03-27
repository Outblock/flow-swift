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

        case error
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
        FlowLogger.shared.log(.debug, message: "Starting transaction build for chain: \(chainID)")
        
        var script: Flow.Script = .init(data: Data())
        var agrument: [Flow.Argument] = []
        var authorizers: [Flow.Address] = []
        var payer: Flow.Address?
        var proposer: Flow.TransactionProposalKey?
        var gasLimit = BigUInt(9999)
        var refBlock: Flow.ID?

        // Log initial transaction components
        builder().forEach { txValue in
            switch txValue {
            case let .script(value):
                script = value
                if let scriptString = String(data: value.data, encoding: .utf8) {
                    FlowLogger.shared.log(.debug, message: "Adding script: \(scriptString)")
                }
                
            case let .argument(value):
                agrument = value
                FlowLogger.shared.log(.debug, message: "Adding arguments: \(value.map { $0.jsonString ?? "invalid" })")
                
            case let .authorizers(value):
                authorizers = value
                FlowLogger.shared.log(.debug, message: "Adding authorizers: \(value.map { $0.hex })")
                
            case let .payer(value):
                payer = value
                FlowLogger.shared.log(.debug, message: "Setting payer: \(value.hex)")
                
            case let .proposer(value):
                proposer = value
                FlowLogger.shared.log(.debug, message: "Setting proposer: address=\(value.address.hex), keyIndex=\(value.keyIndex)")
                
            case let .gasLimit(value):
                gasLimit = value
                FlowLogger.shared.log(.debug, message: "Setting gas limit: \(value)")
                
            case let .refBlock(value):
                refBlock = value
                FlowLogger.shared.log(.debug, message: "Setting reference block: \(value?.hex ?? "latest")")
                
            case .error:
                FlowLogger.shared.log(.warning, message: "Encountered error case in transaction build")
                break
            }
        }

        guard var proposalKey = proposer else {
            FlowLogger.shared.log(.error, message: "Transaction build failed: Empty proposer")
            throw Flow.FError.emptyProposer
        }

        let api = flow.accessAPI
        
        // Log block resolution
        FlowLogger.shared.log(.debug, message: "Resolving reference block ID")
        let id = try await resolveBlockId(api: api, refBlock: refBlock)
        FlowLogger.shared.log(.debug, message: "Resolved block ID: \(id.hex)")
        
        // Log proposal key resolution
        FlowLogger.shared.log(.debug, message: "Resolving proposal key: address=\(proposalKey.address.hex), keyIndex=\(proposalKey.keyIndex)")
        let key = try await resolveProposalKey(api: api, proposalKey: proposalKey)
        FlowLogger.shared.log(.debug, message: "Resolved proposal key with sequence number: \(key.sequenceNumber)")
        proposalKey = key

        // Validate script
        guard !script.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            FlowLogger.shared.log(.error, message: "Transaction build failed: Invalid script format")
            throw Flow.FError.invalidScript
        }

        // Create transaction
        let transaction = Flow.Transaction(
            script: script,
            arguments: agrument,
            referenceBlockId: id,
            gasLimit: gasLimit,
            proposalKey: proposalKey,
            payer: payer ?? proposalKey.address,
            authorizers: authorizers
        )
        
        // Log final transaction details
        FlowLogger.shared.log(.info, message: """
            Transaction built successfully:
            - Script size: \(script.data.count) bytes
            - Arguments count: \(agrument.count)
            - Reference block: \(id.hex)
            - Gas limit: \(gasLimit)
            - Proposer: \(proposalKey.address.hex)
            - Payer: \((payer ?? proposalKey.address).hex)
            - Authorizers count: \(authorizers.count)
            """)
        
        return transaction
    }

    /// Build flow transaction using standard `Flow.Transaction` with async way
    /// - parameters:
    ///     - chainID: The chain id for the transaction, the default value is `flow.chainID`
    /// - returns: The type of `EventLoopFuture<Flow.Transaction>`
    func buildTransaction(chainID: Flow.ChainID = flow.chainID,
                          script: String,
                          agrument: [Flow.Argument] = [],
                          authorizer: [Flow.Address] = [],
                          payerAddress: Flow.Address,
                          proposerKey: Flow.TransactionProposalKey,
                          limit: BigUInt = BigUInt(9999),
                          blockID: Flow.ID?) async throws -> Flow.Transaction
    {
        return try await buildTransaction(chainID: chainID) {
            cadence {
                script
            }

            arguments {
                agrument
            }

            proposer {
                proposerKey
            }

            gasLimit {
                limit
            }

            authorizers {
                authorizer
            }

            payer {
                payerAddress
            }

            refBlock {
                blockID?.hex
            }
        }
    }

    /// Send signed Transaction to the network
    /// - parameters:
    ///     - chainID: The chain id for the transaction, the default value is `flow.chainID`
    ///     - signedTransaction: The signed Flow transaction
    /// - returns: A future value of transaction id
    func sendTransaction(chainID _: ChainID = flow.chainID, signedTransaction: Transaction) async throws -> Flow.ID {
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

    /// Build, sign and send transaction to the network
    /// - parameters:
    ///     - chainID: The chain id for the transaction, the default value is `flow.chainID`
    ///     - signers: A list of `FlowSigner`, which will sign the transaction
    /// - returns: The transaction id
    func sendTransaction(chainID: Flow.ChainID = flow.chainID,
                         signers: [FlowSigner],
                         script: String,
                         agrument: [Flow.Argument] = [],
                         authorizer: [Flow.Address] = [],
                         payerAddress: Flow.Address,
                         proposerKey: Flow.TransactionProposalKey,
                         limit: BigUInt = BigUInt(9999),
                         blockID: Flow.ID?) async throws -> Flow.ID
    {
        return try await sendTransaction(chainID: chainID, signers: signers) {
            cadence {
                script
            }

            arguments {
                agrument
            }

            proposer {
                proposerKey
            }

            gasLimit {
                limit
            }

            authorizers {
                authorizer
            }

            payer {
                payerAddress
            }

            refBlock {
                blockID?.hex
            }
        }
    }
}

// Add logging to helper functions
private func resolveBlockId(api: FlowAccessProtocol = flow.accessAPI, refBlock: Flow.ID?) async throws -> Flow.ID {
    if let blockID = refBlock {
        FlowLogger.shared.log(.debug, message: "Using provided block ID: \(blockID.hex)")
        return blockID
    } else {
        FlowLogger.shared.log(.debug, message: "Fetching latest sealed block")
        let block = try await api.getLatestBlock(sealed: true)
        FlowLogger.shared.log(.debug, message: "Using latest block ID: \(block.id.hex)")
        return block.id
    }
}

private func resolveProposalKey(api: FlowAccessProtocol = flow.accessAPI, proposalKey: Flow.TransactionProposalKey) async throws -> Flow.TransactionProposalKey {
    if proposalKey.sequenceNumber == -1 {
        FlowLogger.shared.log(.debug, message: "Fetching sequence number for account: \(proposalKey.address.hex)")
        let account = try await api.getAccountAtLatestBlock(address: proposalKey.address)
        
        guard let accountKey = account.keys[safe: proposalKey.keyIndex] else {
            FlowLogger.shared.log(.error, message: "Failed to get account key at index: \(proposalKey.keyIndex)")
            throw Flow.FError.preparingTransactionFailed
        }
        
        let newKey = Flow.TransactionProposalKey(
            address: account.address,
            keyIndex: proposalKey.keyIndex,
            sequenceNumber: Int64(accountKey.sequenceNumber)
        )
        
        FlowLogger.shared.log(.debug, message: "Resolved sequence number: \(accountKey.sequenceNumber)")
        return newKey
    }
    
    return proposalKey
}
