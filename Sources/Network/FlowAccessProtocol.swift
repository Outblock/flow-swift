//
//  CadenceTypeTest
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

import Foundation

/// Flow Access API Protocol
///
/// Defines the interface for interacting with Flow blockchain nodes.
/// Provides methods for querying blockchain state and submitting transactions.
///
/// This protocol supports:
/// - Block queries
/// - Account information
/// - Transaction submission
/// - Script execution
/// - Event querying
///
/// Implementation examples:
/// - HTTP API client
/// - gRPC client
/// - Mock client for testing

public protocol FlowAccessProtocol {
    /// Check node connectivity
    /// - Returns: True if node is accessible
    func ping() async throws -> Bool

    /// Get latest block header
    /// - Returns: Most recent block header
    func getLatestBlockHeader(blockStatus: Flow.BlockStatus) async throws -> Flow.BlockHeader

    /// Get block header by ID
    /// - Parameter id: Block identifier
    /// - Returns: Block header for specified ID
    func getBlockHeaderById(id: Flow.ID) async throws -> Flow.BlockHeader

    func getBlockHeaderByHeight(height: UInt64) async throws -> Flow.BlockHeader

    func getLatestBlock(blockStatus: Flow.BlockStatus) async throws -> Flow.Block

    func getBlockById(id: Flow.ID) async throws -> Flow.Block

    func getBlockByHeight(height: UInt64) async throws -> Flow.Block

    func getCollectionById(id: Flow.ID) async throws -> Flow.Collection

    func sendTransaction(transaction: Flow.Transaction) async throws -> Flow.ID

    func getTransactionById(id: Flow.ID) async throws -> Flow.Transaction

    func getTransactionResultById(id: Flow.ID) async throws -> Flow.TransactionResult

    func getAccountAtLatestBlock(address: Flow.Address, blockStatus: Flow.BlockStatus) async throws -> Flow.Account

    func getAccountByBlockHeight(address: Flow.Address, height: UInt64) async throws -> Flow.Account

    func executeScriptAtLatestBlock(script: Flow.Script, arguments: [Flow.Argument], blockStatus: Flow.BlockStatus) async throws -> Flow.ScriptResponse

    func executeScriptAtLatestBlock(script: Flow.Script, arguments: [Flow.Cadence.FValue], blockStatus: Flow.BlockStatus) async throws -> Flow.ScriptResponse

    func executeScriptAtBlockId(script: Flow.Script, blockId: Flow.ID, arguments: [Flow.Argument]) async throws -> Flow.ScriptResponse

    func executeScriptAtBlockId(script: Flow.Script, blockId: Flow.ID, arguments: [Flow.Cadence.FValue]) async throws -> Flow.ScriptResponse

    func executeScriptAtBlockHeight(script: Flow.Script, height: UInt64, arguments: [Flow.Argument]) async throws -> Flow.ScriptResponse

    func executeScriptAtBlockHeight(script: Flow.Script, height: UInt64, arguments: [Flow.Cadence.FValue]) async throws -> Flow.ScriptResponse

    func getEventsForHeightRange(type: String, range: ClosedRange<UInt64>) async throws -> [Flow.Event.Result]

    func getEventsForBlockIds(type: String, ids: Set<Flow.ID>) async throws -> [Flow.Event.Result]

    func getNetworkParameters() async throws -> Flow.ChainID

//    func getLatestProtocolStateSnapshot() async throws -> Flow.Snapshot
}

public extension FlowAccessProtocol {
    
    func getLatestBlockHeader(blockStatus: Flow.BlockStatus = .final) async throws -> Flow.BlockHeader {
        return try await getLatestBlockHeader(blockStatus: blockStatus)
    }
    
    func getAccountAtLatestBlock(address: Flow.Address, blockStatus: Flow.BlockStatus = .final) async throws -> Flow.Account {
        return try await getAccountAtLatestBlock(address: address, blockStatus: blockStatus)
    }
    
    func getAccountAtLatestBlock(address: String, blockStatus: Flow.BlockStatus = .final) async throws -> Flow.Account {
        return try await getAccountAtLatestBlock(address: .init(hex: address.addHexPrefix()), blockStatus: blockStatus)
    }

    func getTransactionById(id: String) async throws -> Flow.Transaction {
        return try await getTransactionById(id: .init(hex: id))
    }

    func getTransactionResultById(id: String) async throws -> Flow.TransactionResult {
        return try await getTransactionResultById(id: .init(hex: id))
    }

    func getLatestBlock(sealed: Bool = true) async throws -> Flow.Block {
        return try await getLatestBlock(blockStatus: .final)
    }

    func executeScriptAtLatestBlock(cadence: String, arguments: [Flow.Argument] = [], blockStatus: Flow.BlockStatus = .final) async throws -> Flow.ScriptResponse {
        return try await executeScriptAtLatestBlock(script: .init(text: cadence), arguments: arguments, blockStatus: blockStatus)
    }

    func executeScriptAtLatestBlock(cadence: String, arguments: [Flow.Cadence.FValue] = [], blockStatus: Flow.BlockStatus = .final) async throws -> Flow.ScriptResponse {
        return try await executeScriptAtLatestBlock(script: .init(text: cadence), arguments: arguments, blockStatus: blockStatus)
    }

    func executeScriptAtLatestBlock(script: Flow.Script, blockStatus: Flow.BlockStatus = .final) async throws -> Flow.ScriptResponse {
        let list: [Flow.Argument] = []
        return try await executeScriptAtLatestBlock(script: script, arguments: list, blockStatus: blockStatus)
    }
    
    func executeScriptAtLatestBlock(script: Flow.Script, arguments: [Flow.Argument], blockStatus: Flow.BlockStatus = .final) async throws -> Flow.ScriptResponse {
        return try await executeScriptAtLatestBlock(script: script, arguments: arguments, blockStatus: blockStatus)
    }

    func executeScriptAtLatestBlock(script: Flow.Script, arguments: [Flow.Cadence.FValue], blockStatus: Flow.BlockStatus = .final) async throws -> Flow.ScriptResponse {
        return try await executeScriptAtLatestBlock(script: script, arguments: arguments.map { $0.toArgument() }, blockStatus: blockStatus)
    }

    func executeScriptAtBlockId(script: Flow.Script, blockId: Flow.ID, arguments: [Flow.Argument] = []) async throws -> Flow.ScriptResponse {
        return try await executeScriptAtBlockId(script: script, blockId: blockId, arguments: arguments)
    }

    func executeScriptAtBlockId(script: Flow.Script, blockId: Flow.ID, arguments: [Flow.Cadence.FValue]) async throws -> Flow.ScriptResponse {
        return try await executeScriptAtBlockId(script: script, blockId: blockId, arguments: arguments.map { $0.toArgument() })
    }

    func executeScriptAtBlockHeight(script: Flow.Script, height: UInt64, arguments: [Flow.Argument] = []) async throws -> Flow.ScriptResponse {
        return try await executeScriptAtBlockHeight(script: script, height: height, arguments: arguments)
    }

    func executeScriptAtBlockHeight(script: Flow.Script, height: UInt64, arguments: [Flow.Cadence.FValue]) async throws -> Flow.ScriptResponse {
        return try await executeScriptAtBlockHeight(script: script, height: height, arguments: arguments.map { $0.toArgument() })
    }
}
