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

import Foundation
import GRPC
import NIO

public extension Flow {
    /// The network client for access API
    /// More detail can be found here: https://docs.onflow.org/access-api
    final class AccessAPI: FlowAccessProtocol {
        internal var clientChannel: ClientConnection
        internal var accessClient: Flow_Access_AccessAPIClient

        init(chainID: ChainID) {
            let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
            let target = ConnectionTarget.hostAndPort(chainID.defaultNode.node, chainID.defaultNode.port)
            let config = ClientConnection.Configuration.default(target: target,
                                                                eventLoopGroup: eventLoopGroup)
            clientChannel = ClientConnection(configuration: config)
            accessClient = Flow_Access_AccessAPIClient(channel: clientChannel)
        }

        init(host: String, port: Int = 9000) {
            let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
            let config = ClientConnection.Configuration.default(target: ConnectionTarget.hostAndPort(host, port),
                                                                eventLoopGroup: eventLoopGroup)
            clientChannel = ClientConnection(configuration: config)
            accessClient = Flow_Access_AccessAPIClient(channel: clientChannel)
        }

        init(config: ClientConnection.Configuration) {
            clientChannel = ClientConnection(configuration: config)
            accessClient = Flow_Access_AccessAPIClient(channel: clientChannel)
        }

        // MARK: - Implementation

        /// Ping will return a successful response if the Access API is ready and available.
        /// - returns: A future result in `Bool` type
        public func ping() -> EventLoopFuture<Bool> {
            let request = Flow_Access_PingRequest()
            let promise = clientChannel.eventLoop.makePromise(of: Bool.self)
            accessClient.ping(request).response.whenComplete { result in
                switch result {
                case .success:
                    promise.succeed(true)
                case let .failure(error):
                    promise.fail(error)
                }
            }
            return promise.futureResult
        }

        /// Gets the latest block header.
        /// - returns: A future result in `Flow.BlockHeader` type
        public func getLatestBlockHeader() -> EventLoopFuture<Flow.BlockHeader> {
            let request = Flow_Access_GetLatestBlockRequest()
            let promise = clientChannel.eventLoop.makePromise(of: Flow.BlockHeader.self)
            accessClient.getLatestBlock(request).response.whenComplete { result in
                switch result {
                case let .success(response):
                    let entity = Flow.BlockHeader(value: response.block)
                    promise.succeed(entity)
                case let .failure(error):
                    promise.fail(error)
                }
            }
            return promise.futureResult
        }

        /// Gets a block header by ID.
        /// - parameters:
        ///     - id: The id for the block in `Flow.ID` type.
        /// - returns: A future result in `Flow.BlockHeader?` type
        /// - warning: If the response has no block, it will return nil
        public func getBlockHeaderById(id: Flow.ID) -> EventLoopFuture<Flow.BlockHeader?> {
            var request = Flow_Access_GetBlockByIDRequest()
            request.id = id.data
            let promise = clientChannel.eventLoop.makePromise(of: Flow.BlockHeader?.self)
            accessClient.getBlockByID(request).response.whenComplete { result in
                switch result {
                case let .success(response):
                    if response.hasBlock {
                        let entity = Flow.BlockHeader(value: response.block)
                        promise.succeed(entity)
                    } else {
                        promise.succeed(nil)
                    }
                case let .failure(error):
                    promise.fail(error)
                }
            }
            return promise.futureResult
        }

        /// Gets a block header by height.
        /// - parameters:
        ///     - height: The height for the block in `UInt64` type.
        /// - returns: A future result in `Flow.BlockHeader?` type
        /// - warning: If the response has no block, it will return nil
        public func getBlockHeaderByHeight(height: UInt64) -> EventLoopFuture<Flow.BlockHeader?> {
            var request = Flow_Access_GetBlockHeaderByHeightRequest()
            request.height = height
            let promise = clientChannel.eventLoop.makePromise(of: Flow.BlockHeader?.self)
            accessClient.getBlockHeaderByHeight(request).response.whenComplete { result in
                switch result {
                case let .success(response):
                    if response.hasBlock {
                        let entity = Flow.BlockHeader(value: response.block)
                        promise.succeed(entity)
                    } else {
                        promise.succeed(nil)
                    }
                case let .failure(error):
                    promise.fail(error)
                }
            }
            return promise.futureResult
        }

        /// GetLatestBlock gets the full payload of the latest sealed or unsealed block.
        /// - parameters:
        ///     - sealed: The flag for the block is sealed or unsealed, default value is `true`.
        /// - returns: A future result in `Flow.Block?` type
        public func getLatestBlock(sealed: Bool = true) -> EventLoopFuture<Flow.Block> {
            var request = Flow_Access_GetLatestBlockRequest()
            request.isSealed = sealed
            let promise = clientChannel.eventLoop.makePromise(of: Flow.Block.self)
            accessClient.getLatestBlock(request).response.whenComplete { result in
                switch result {
                case let .success(response):
                    let entity = Flow.Block(value: response.block)
                    promise.succeed(entity)
                case let .failure(error):
                    promise.fail(error)
                }
            }
            return promise.futureResult
        }

        /// Gets a full block by ID.
        /// - parameters:
        ///     - id: The id for the block.
        /// - returns: A future result in `Flow.Block?` type
        /// - warning: If the response has no block, it will return nil
        public func getBlockById(id: Flow.ID) -> EventLoopFuture<Flow.Block?> {
            var request = Flow_Access_GetBlockByIDRequest()
            request.id = id.data
            let promise = clientChannel.eventLoop.makePromise(of: Flow.Block?.self)
            accessClient.getBlockByID(request).response.whenComplete { result in
                switch result {
                case let .success(response):
                    if response.hasBlock {
                        let entity = Flow.Block(value: response.block)
                        promise.succeed(entity)
                    } else {
                        promise.succeed(nil)
                    }
                case let .failure(error):
                    promise.fail(error)
                }
            }
            return promise.futureResult
        }

        /// Gets a full block by height.
        /// - parameters:
        ///     - height: The height for the block in `UInt64` type.
        /// - returns: A future result in `Flow.Block?` type
        /// - warning: If the response has no block, it will return nil
        public func getBlockByHeight(height: UInt64) -> EventLoopFuture<Flow.Block?> {
            var request = Flow_Access_GetBlockByHeightRequest()
            request.height = height
            let promise = clientChannel.eventLoop.makePromise(of: Flow.Block?.self)
            accessClient.getBlockByHeight(request).response.whenComplete { result in
                switch result {
                case let .success(response):
                    if response.hasBlock {
                        let entity = Flow.Block(value: response.block)
                        promise.succeed(entity)
                    } else {
                        promise.succeed(nil)
                    }
                case let .failure(error):
                    promise.fail(error)
                }
            }
            return promise.futureResult
        }

        /// Gets a collection by ID.
        /// - parameters:
        ///     - id: The id for the collection.
        /// - returns: A future result in `Flow.Collection?` type
        /// - warning: If the response has no collection, it will return nil
        public func getCollectionById(id: Flow.ID) -> EventLoopFuture<Flow.Collection?> {
            var request = Flow_Access_GetCollectionByIDRequest()
            request.id = id.data
            let promise = clientChannel.eventLoop.makePromise(of: Flow.Collection?.self)
            accessClient.getCollectionByID(request).response.whenComplete { result in
                switch result {
                case let .success(response):
                    if response.hasCollection {
                        let entity = Flow.Collection(value: response.collection)
                        promise.succeed(entity)
                    } else {
                        promise.succeed(nil)
                    }
                case let .failure(error):
                    promise.fail(error)
                }
            }
            return promise.futureResult
        }

        /// Submit a signed transaction to the network.
        /// - parameters:
        ///     - transaction: The signed transaction in `Flow.Transaction` type.
        /// - returns: A future result in `Flow.ID` type as transaction id.
        public func sendTransaction(transaction: Flow.Transaction) -> EventLoopFuture<Flow.ID> {
            var request = Flow_Access_SendTransactionRequest()
            request.transaction = transaction.toFlowEntity()
            let promise = clientChannel.eventLoop.makePromise(of: Flow.ID.self)
            accessClient.sendTransaction(request).response.whenComplete { result in
                switch result {
                case let .success(response):
                    let entity = Flow.ID(bytes: response.id.bytes)
                    promise.succeed(entity)
                case let .failure(error):
                    promise.fail(error)
                }
            }
            return promise.futureResult
        }

        /// Get a transaction by ID.
        /// - parameters:
        ///     - id: The id for the transaction.
        /// - returns: A future result in `Flow.Transaction?` type as transaction.
        /// - warning: If the response has no transaction, it will return nil
        public func getTransactionById(id: Flow.ID) -> EventLoopFuture<Flow.Transaction?> {
            var request = Flow_Access_GetTransactionRequest()
            request.id = id.data
            let promise = clientChannel.eventLoop.makePromise(of: Flow.Transaction?.self)
            accessClient.getTransaction(request).response.whenComplete { result in
                switch result {
                case let .success(response):
                    if response.hasTransaction {
                        let entity = Flow.Transaction(value: response.transaction)
                        promise.succeed(entity)
                    } else {
                        promise.succeed(nil)
                    }
                case let .failure(error):
                    promise.fail(error)
                }
            }
            return promise.futureResult
        }

        /// Get a transaction result by ID.
        /// - parameters:
        ///     - id: The id for the transaction.
        /// - returns: A future result in `Flow.TransactionResult` type
        public func getTransactionResultById(id: Flow.ID) -> EventLoopFuture<Flow.TransactionResult> {
            var request = Flow_Access_GetTransactionRequest()
            request.id = id.data
            let promise = clientChannel.eventLoop.makePromise(of: Flow.TransactionResult.self)
            accessClient.getTransactionResult(request).response.whenComplete { result in
                switch result {
                case let .success(response):
                    let entity = Flow.TransactionResult(value: response)
                    promise.succeed(entity)
                case let .failure(error):
                    promise.fail(error)
                }
            }

            return promise.futureResult
        }

        /// Get an account result at lastest block.
        /// - parameters:
        ///     - address: The address of account.
        /// - returns: A future result in `Flow.Account?` type
        /// - warning: If the response has no account, it will return nil
        public func getAccountAtLatestBlock(address: Flow.Address) -> EventLoopFuture<Flow.Account?> {
            var request = Flow_Access_GetAccountAtLatestBlockRequest()
            request.address = address.data
            let promise = clientChannel.eventLoop.makePromise(of: Flow.Account?.self)
            accessClient.getAccountAtLatestBlock(request).response.whenComplete { result in
                switch result {
                case let .success(response):
                    if response.hasAccount {
                        let entity = Flow.Account(value: response.account)
                        promise.succeed(entity)
                    } else {
                        promise.succeed(nil)
                    }
                case let .failure(error):
                    promise.fail(error)
                }
            }
            return promise.futureResult
        }

        /// Get an account result by height.
        /// - parameters:
        ///     - address: The address of account.
        ///     - height: The height of flow block.
        /// - returns: A future result in `Flow.Account?` type
        /// - warning: If the response has no account, it will return nil
        public func getAccountByBlockHeight(address: Flow.Address, height: UInt64) -> EventLoopFuture<Flow.Account?> {
            var request = Flow_Access_GetAccountAtBlockHeightRequest()
            request.address = address.data
            request.blockHeight = height
            let promise = clientChannel.eventLoop.makePromise(of: Flow.Account?.self)
            accessClient.getAccountAtBlockHeight(request).response.whenComplete { result in
                switch result {
                case let .success(response):
                    if response.hasAccount {
                        let entity = Flow.Account(value: response.account)
                        promise.succeed(entity)
                    } else {
                        promise.succeed(nil)
                    }
                case let .failure(error):
                    promise.fail(error)
                }
            }
            return promise.futureResult
        }

        /// Executes a read-only Cadence script against the latest sealed execution state.
        /// - parameters:
        ///     - script: The script content cadence code.
        ///     - arguments: The arguments for the cadence code.
        /// - returns: A future result in `Flow.ScriptResponse` type
        public func executeScriptAtLatestBlock(script: Flow.Script, arguments: [Flow.Argument] = []) -> EventLoopFuture<Flow.ScriptResponse> {
            var request = Flow_Access_ExecuteScriptAtLatestBlockRequest()
            request.script = script.data
            request.arguments = arguments.compactMap { $0.jsonData }
            let promise = clientChannel.eventLoop.makePromise(of: Flow.ScriptResponse.self)
            accessClient.executeScriptAtLatestBlock(request).response.whenComplete { result in
                switch result {
                case let .success(response):
                    let entity = Flow.ScriptResponse(data: response.value)
                    promise.succeed(entity)
                case let .failure(error):
                    promise.fail(error)
                }
            }
            return promise.futureResult
        }

        /// Executes a ready-only Cadence script against the execution state at the block with the given ID.
        /// - parameters:
        ///     - script: The script content cadence code.
        ///     - blockId: The id of the block
        ///     - arguments: The arguments for the cadence code.
        /// - returns: A future result in `Flow.ScriptResponse` type
        public func executeScriptAtBlockId(script: Flow.Script, blockId: Flow.ID, arguments: [Flow.Argument] = []) -> EventLoopFuture<Flow.ScriptResponse> {
            var request = Flow_Access_ExecuteScriptAtBlockIDRequest()
            request.script = script.data
            request.blockID = blockId.data
            request.arguments = arguments.compactMap { $0.jsonData }
            let promise = clientChannel.eventLoop.makePromise(of: Flow.ScriptResponse.self)
            accessClient.executeScriptAtBlockID(request).response.whenComplete { result in
                switch result {
                case let .success(response):
                    let entity = Flow.ScriptResponse(data: response.value)
                    promise.succeed(entity)
                case let .failure(error):
                    promise.fail(error)
                }
            }
            return promise.futureResult
        }

        /// Executes a ready-only Cadence script against the execution state at the block with the given block height.
        /// - parameters:
        ///     - script: The script content cadence code.
        ///     - height: The height of the block
        ///     - arguments: The arguments for the cadence code.
        /// - returns: A future result in `Flow.ScriptResponse` type
        public func executeScriptAtBlockHeight(script: Flow.Script, height: UInt64, arguments: [Flow.Argument] = []) -> EventLoopFuture<Flow.ScriptResponse> {
            var request = Flow_Access_ExecuteScriptAtBlockHeightRequest()
            request.script = script.data
            request.blockHeight = height
            request.arguments = arguments.compactMap { $0.jsonData }
            let promise = clientChannel.eventLoop.makePromise(of: Flow.ScriptResponse.self)
            accessClient.executeScriptAtBlockHeight(request).response.whenComplete { result in
                switch result {
                case let .success(response):
                    let entity = Flow.ScriptResponse(data: response.value)
                    promise.succeed(entity)
                case let .failure(error):
                    promise.fail(error)
                }
            }
            return promise.futureResult
        }

        /// Retrieves events emitted within the specified block range.
        /// - parameters:
        ///     - type: The type of event.
        ///     - range: The range of the block height
        /// - returns: A future result in `Flow.Event.Result` type
        public func getEventsForHeightRange(type: String, range: ClosedRange<UInt64>) -> EventLoopFuture<[Flow.Event.Result]> {
            var request = Flow_Access_GetEventsForHeightRangeRequest()
            request.type = type
            request.startHeight = range.lowerBound
            request.endHeight = range.upperBound
            let promise = clientChannel.eventLoop.makePromise(of: [Flow.Event.Result].self)
            accessClient.getEventsForHeightRange(request).response.whenComplete { result in
                switch result {
                case let .success(response):
                    let entity = response.results.compactMap { Flow.Event.Result(value: $0) }
                    promise.succeed(entity)
                case let .failure(error):
                    promise.fail(error)
                }
            }
            return promise.futureResult
        }

        /// Retrieves events for the specified block IDs and event type.
        /// - parameters:
        ///     - type: The type of event.
        ///     - ids: The list of the block id
        /// - returns: A future result in `Flow.Event.Result` type
        public func getEventsForBlockIds(type: String, ids: Set<Flow.ID>) -> EventLoopFuture<[Flow.Event.Result]> {
            var request = Flow_Access_GetEventsForBlockIDsRequest()
            request.type = type
            request.blockIds = ids.compactMap { $0.data }
            let promise = clientChannel.eventLoop.makePromise(of: [Flow.Event.Result].self)
            accessClient.getEventsForBlockIDs(request).response.whenComplete { result in
                switch result {
                case let .success(response):
                    let entity = response.results.compactMap { Flow.Event.Result(value: $0) }
                    promise.succeed(entity)
                case let .failure(error):
                    promise.fail(error)
                }
            }
            return promise.futureResult
        }

        /// Retrieves the Flow network details
        /// - returns: A future result in `Flow.ChainID` type
        public func getNetworkParameters() -> EventLoopFuture<Flow.ChainID> {
            let request = Flow_Access_GetNetworkParametersRequest()
            let promise = clientChannel.eventLoop.makePromise(of: Flow.ChainID.self)
            accessClient.getNetworkParameters(request).response.whenComplete { result in
                switch result {
                case let .success(response):
                    let entity = Flow.ChainID(name: response.ChainID)
                    promise.succeed(entity)
                case let .failure(error):
                    promise.fail(error)
                }
            }
            return promise.futureResult
        }

        /// Retrieves the latest sealed protocol state
        /// snapshot. Used by Flow nodes joining the network to bootstrap a
        /// space-efficient local state.
        /// - returns: A future result in `Flow.Snapshot` type
        public func getLatestProtocolStateSnapshot() -> EventLoopFuture<Flow.Snapshot> {
            let request = Flow_Access_GetLatestProtocolStateSnapshotRequest()
            let promise = clientChannel.eventLoop.makePromise(of: Flow.Snapshot.self)
            accessClient.getLatestProtocolStateSnapshot(request).response.whenComplete { result in
                switch result {
                case let .success(response):
                    let entity = Flow.Snapshot(data: response.serializedSnapshot)
                    promise.succeed(entity)
                case let .failure(error):
                    promise.fail(error)
                }
            }
            return promise.futureResult
        }
    }
}
