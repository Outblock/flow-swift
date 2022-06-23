//
//  FlowAccessAPI
//
//  Copyright 2021 Zed Labs Pty Ltd
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

import Flow
import Foundation
import GRPC
import NIO

public extension Flow {
    /// The network client for access API
    /// More detail can be found here: https://docs.onflow.org/access-api
    @available(iOS 13, *)
    final class GRPCAccessAPI: FlowAccessProtocol {
        public init(clientChannel: ClientConnection, accessClient: Flow_Access_AccessAPIClient) {
            self.clientChannel = clientChannel
            self.accessClient = accessClient
        }

        internal var clientChannel: ClientConnection
        internal var accessClient: Flow_Access_AccessAPIClient

        public convenience init?(chainID: Flow.ChainID) {
            guard let endpoint = chainID.defaultNode.gRPCEndpoint, let port = endpoint.port else {
                return nil
            }

            let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
            let target = ConnectionTarget.hostAndPort(endpoint.node, port)
            let config = ClientConnection.Configuration.default(target: target,
                                                                eventLoopGroup: eventLoopGroup)

            let clientChannel = ClientConnection(configuration: config)
            self.init(clientChannel: clientChannel,
                      accessClient: Flow_Access_AccessAPIClient(channel: clientChannel))
        }

        public init(host: String, port: Int = 9000) {
            let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
            let config = ClientConnection.Configuration.default(target: ConnectionTarget.hostAndPort(host, port),
                                                                eventLoopGroup: eventLoopGroup)
            clientChannel = ClientConnection(configuration: config)
            accessClient = Flow_Access_AccessAPIClient(channel: clientChannel)
        }

        public init(config: ClientConnection.Configuration) {
            clientChannel = ClientConnection(configuration: config)
            accessClient = Flow_Access_AccessAPIClient(channel: clientChannel)
        }

        // MARK: - Implementation

        /// Ping will return a successful response if the Access API is ready and available.
        /// - returns: A future result in `Bool` type
        public func ping() async throws -> Bool {
            let request = Flow_Access_PingRequest()
            do {
                _ = try await accessClient.ping(request).response.get()
            } catch {
                return false
            }
            return true
        }

        /// Gets the latest block header.
        /// - returns: A future result in `Flow.BlockHeader` type
        public func getLatestBlockHeader() async throws -> Flow.BlockHeader {
            let request = Flow_Access_GetLatestBlockRequest()
            let result = try await accessClient.getLatestBlock(request).response.get()
            return Flow.BlockHeader(value: result.block)
        }

        /// Gets a block header by ID.
        /// - parameters:
        ///     - id: The id for the block in `Flow.ID` type.
        /// - returns: A future result in `Flow.BlockHeader?` type
        /// - warning: If the response has no block, it will return nil
        public func getBlockHeaderById(id: Flow.ID) async throws -> Flow.BlockHeader {
            var request = Flow_Access_GetBlockByIDRequest()
            request.id = id.data
            let result = try await accessClient.getBlockByID(request).response.get()
            return Flow.BlockHeader(value: result.block)
        }

        /// Gets a block header by height.
        /// - parameters:
        ///     - height: The height for the block in `UInt64` type.
        /// - returns: A future result in `Flow.BlockHeader?` type
        /// - warning: If the response has no block, it will return nil
        public func getBlockHeaderByHeight(height: UInt64) async throws -> Flow.BlockHeader {
            var request = Flow_Access_GetBlockHeaderByHeightRequest()
            request.height = height
            let result = try await accessClient.getBlockHeaderByHeight(request).response.get()
            return Flow.BlockHeader(value: result.block)
        }

        /// GetLatestBlock gets the full payload of the latest sealed or unsealed block.
        /// - parameters:
        ///     - sealed: The flag for the block is sealed or unsealed, default value is `true`.
        /// - returns: A future result in `Flow.Block?` type
        public func getLatestBlock(sealed: Bool = true) async throws -> Flow.Block {
            var request = Flow_Access_GetLatestBlockRequest()
            request.isSealed = sealed
            let result = try await accessClient.getLatestBlock(request).response.get()
            return Flow.Block(value: result.block)
        }

        /// Gets a full block by ID.
        /// - parameters:
        ///     - id: The id for the block.
        /// - returns: A future result in `Flow.Block?` type
        /// - warning: If the response has no block, it will return nil
        public func getBlockById(id: Flow.ID) async throws -> Flow.Block {
            var request = Flow_Access_GetBlockByIDRequest()
            request.id = id.data
            let result = try await accessClient.getBlockByID(request).response.get()
            return Flow.Block(value: result.block)
        }

        /// Gets a full block by height.
        /// - parameters:
        ///     - height: The height for the block in `UInt64` type.
        /// - returns: A future result in `Flow.Block?` type
        /// - warning: If the response has no block, it will return nil
        public func getBlockByHeight(height: UInt64) async throws -> Flow.Block {
            var request = Flow_Access_GetBlockByHeightRequest()
            request.height = height
            let result = try await accessClient.getBlockByHeight(request).response.get()
            return Flow.Block(value: result.block)
        }

        /// Gets a collection by ID.
        /// - parameters:
        ///     - id: The id for the collection.
        /// - returns: A future result in `Flow.Collection?` type
        /// - warning: If the response has no collection, it will return nil
        public func getCollectionById(id: Flow.ID) async throws -> Flow.Collection {
            var request = Flow_Access_GetCollectionByIDRequest()
            request.id = id.data
            let result = try await accessClient.getCollectionByID(request).response.get()
            return Flow.Collection(value: result.collection)
        }

        /// Submit a signed transaction to the network.
        /// - parameters:
        ///     - transaction: The signed transaction in `Flow.Transaction` type.
        /// - returns: A future result in `Flow.ID` type as transaction id.
        public func sendTransaction(transaction: Flow.Transaction) async throws -> Flow.ID {
            var request = Flow_Access_SendTransactionRequest()
            request.transaction = transaction.toFlowEntity()
            let result = try await accessClient.sendTransaction(request).response.get()
            return Flow.ID(data: result.id)
        }

        /// Get a transaction by ID.
        /// - parameters:
        ///     - id: The id for the transaction.
        /// - returns: A future result in `Flow.Transaction?` type as transaction.
        /// - warning: If the response has no transaction, it will return nil
        public func getTransactionById(id: Flow.ID) async throws -> Flow.Transaction {
            var request = Flow_Access_GetTransactionRequest()
            request.id = id.data
            let result = try await accessClient.getTransaction(request).response.get()
            return Flow.Transaction(value: result.transaction)
        }

        /// Get a transaction result by ID.
        /// - parameters:
        ///     - id: The id for the transaction.
        /// - returns: A future result in `Flow.TransactionResult` type
        public func getTransactionResultById(id: Flow.ID) async throws -> Flow.TransactionResult {
            var request = Flow_Access_GetTransactionRequest()
            request.id = id.data
            let result = try await accessClient.getTransactionResult(request).response.get()
            return Flow.TransactionResult(value: result)
        }

        /// Get an account result at lastest block.
        /// - parameters:
        ///     - address: The address of account.
        /// - returns: A future result in `Flow.Account?` type
        /// - warning: If the response has no account, it will return nil
        public func getAccountAtLatestBlock(address: Flow.Address) async throws -> Flow.Account {
            var request = Flow_Access_GetAccountAtLatestBlockRequest()
            request.address = address.data
            let result = try await accessClient.getAccountAtLatestBlock(request).response.get()
            return Flow.Account(value: result.account)
        }

        /// Get an account result by height.
        /// - parameters:
        ///     - address: The address of account.
        ///     - height: The height of flow block.
        /// - returns: A future result in `Flow.Account?` type
        /// - warning: If the response has no account, it will return nil
        public func getAccountByBlockHeight(address: Flow.Address, height: UInt64) async throws -> Flow.Account {
            var request = Flow_Access_GetAccountAtBlockHeightRequest()
            request.address = address.data
            request.blockHeight = height
            let result = try await accessClient.getAccountAtBlockHeight(request).response.get()
            return Flow.Account(value: result.account)
        }

        /// Executes a read-only Cadence script against the latest sealed execution state.
        /// - parameters:
        ///     - script: The script content cadence code.
        ///     - arguments: The arguments for the cadence code.
        /// - returns: A future result in `Flow.ScriptResponse` type
        public func executeScriptAtLatestBlock(script: Flow.Script, arguments: [Flow.Argument] = []) async throws -> Flow.ScriptResponse {
            var request = Flow_Access_ExecuteScriptAtLatestBlockRequest()
            request.script = script.data
            request.arguments = arguments.compactMap { $0.jsonData }
            let result = try await accessClient.executeScriptAtLatestBlock(request).response.get()
            return Flow.ScriptResponse(data: result.value)
        }

        /// Executes a ready-only Cadence script against the execution state at the block with the given ID.
        /// - parameters:
        ///     - script: The script content cadence code.
        ///     - blockId: The id of the block
        ///     - arguments: The arguments for the cadence code.
        /// - returns: A future result in `Flow.ScriptResponse` type
        public func executeScriptAtBlockId(script: Flow.Script, blockId: Flow.ID, arguments: [Flow.Argument] = []) async throws -> Flow.ScriptResponse {
            var request = Flow_Access_ExecuteScriptAtBlockIDRequest()
            request.script = script.data
            request.blockID = blockId.data
            request.arguments = arguments.compactMap { $0.jsonData }
            let result = try await accessClient.executeScriptAtBlockID(request).response.get()
            return Flow.ScriptResponse(data: result.value)
        }

        /// Executes a ready-only Cadence script against the execution state at the block with the given block height.
        /// - parameters:
        ///     - script: The script content cadence code.
        ///     - height: The height of the block
        ///     - arguments: The arguments for the cadence code.
        /// - returns: A future result in `Flow.ScriptResponse` type
        public func executeScriptAtBlockHeight(script: Flow.Script, height: UInt64, arguments: [Flow.Argument] = []) async throws -> Flow.ScriptResponse {
            var request = Flow_Access_ExecuteScriptAtBlockHeightRequest()
            request.script = script.data
            request.blockHeight = height
            request.arguments = arguments.compactMap { $0.jsonData }
            let result = try await accessClient.executeScriptAtBlockHeight(request).response.get()

            return Flow.ScriptResponse(data: result.value)
        }

        /// Retrieves events emitted within the specified block range.
        /// - parameters:
        ///     - type: The type of event.
        ///     - range: The range of the block height
        /// - returns: A future result in `Flow.Event.Result` type
        public func getEventsForHeightRange(type: String, range: ClosedRange<UInt64>) async throws -> [Flow.Event.Result] {
            var request = Flow_Access_GetEventsForHeightRangeRequest()
            request.type = type
            request.startHeight = range.lowerBound
            request.endHeight = range.upperBound
            let result = try await accessClient.getEventsForHeightRange(request).response.get()
            return result.results.compactMap { Flow.Event.Result(value: $0) }
        }

        /// Retrieves events for the specified block IDs and event type.
        /// - parameters:
        ///     - type: The type of event.
        ///     - ids: The list of the block id
        /// - returns: A future result in `Flow.Event.Result` type
        public func getEventsForBlockIds(type: String, ids: Set<Flow.ID>) async throws -> [Flow.Event.Result] {
            var request = Flow_Access_GetEventsForBlockIDsRequest()
            request.type = type
            request.blockIds = ids.compactMap { $0.data }
            let result = try await accessClient.getEventsForBlockIDs(request).response.get()
            return result.results.compactMap { Flow.Event.Result(value: $0) }
        }

        /// Retrieves the Flow network details
        /// - returns: A future result in `Flow.ChainID` type
        public func getNetworkParameters() async throws -> Flow.ChainID {
            let request = Flow_Access_GetNetworkParametersRequest()
            let result = try await accessClient.getNetworkParameters(request).response.get()
            return Flow.ChainID(name: result.ChainID)
        }

        /// Retrieves the latest sealed protocol state
        /// snapshot. Used by Flow nodes joining the network to bootstrap a
        /// space-efficient local state.
        /// - returns: A future result in `Flow.Snapshot` type
        public func getLatestProtocolStateSnapshot() async throws -> Flow.Snapshot {
            let request = Flow_Access_GetLatestProtocolStateSnapshotRequest()
            let result = try await accessClient.getLatestProtocolStateSnapshot(request).response.get()
            return Flow.Snapshot(data: result.serializedSnapshot)
        }
    }
}
