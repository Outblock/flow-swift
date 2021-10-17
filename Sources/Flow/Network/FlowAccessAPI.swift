//
//  File.swift
//
//
//  Created by lmcmz on 25/7/21.
//

import Foundation
import GRPC
import NIO

extension Flow {
    public final class AccessAPI: FlowAccessProtocol {
        private var clientChannel: ClientConnection
        private var accessClient: Flow_Access_AccessAPIClient

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

        public func getLatestBlock(sealed: Bool) -> EventLoopFuture<Flow.Block> {
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
        
        public func onceResultStatus(id: Flow.ID, status: Flow.Transaction.Status, delay: TimeInterval = 2, timeout: TimeInterval = 20) -> EventLoopFuture<Flow.TransactionResult> {
            let promise = clientChannel.eventLoop.makePromise(of: Flow.TransactionResult.self)
            let timeoutDate = Date(timeIntervalSinceNow: timeout)
            
            print("will start check transaction result, \(id.hex)")
            func makeResultCall() {
                let now = Date()
                if now > timeoutDate {
                    // timeout
                    promise.fail(FError.timeout)
                    return
                }
                
                let call = getTransactionResultById(id: id)
                call.whenSuccessBlocking(onto: .main) { result in
                    if result.status >= status {
                        // finished
                        promise.succeed(result)
                        return
                    }
                    
                    // continue loop
                    DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                        makeResultCall()
                    }
                }
                
                call.whenFailureBlocking(onto: .main) { error in
                    // error
                    promise.fail(error)
                }
            }
            
            DispatchQueue.global().async {
                makeResultCall()
            }
            
            return promise.futureResult
        }

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

        public func executeScriptAtLatestBlock(script: Flow.Script, arguments: [Flow.Argument]) -> EventLoopFuture<Flow.ScriptResponse> {
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

        public func executeScriptAtBlockId(script: Flow.Script, blockId _: Flow.ID, arguments: [Flow.Argument]) -> EventLoopFuture<Flow.ScriptResponse> {
            var request = Flow_Access_ExecuteScriptAtBlockIDRequest()
            request.script = script.data
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

        public func executeScriptAtBlockHeight(script: Flow.Script, height: UInt64, arguments: [Flow.Argument]) -> EventLoopFuture<Flow.ScriptResponse> {
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

        public func getEventsForHeightRange(type: String, range: ClosedRange<UInt64>) -> EventLoopFuture<[Flow.EventResult]> {
            var request = Flow_Access_GetEventsForHeightRangeRequest()
            request.type = type
            request.startHeight = range.lowerBound
            request.endHeight = range.upperBound
            let promise = clientChannel.eventLoop.makePromise(of: [Flow.EventResult].self)
            accessClient.getEventsForHeightRange(request).response.whenComplete { result in
                switch result {
                case let .success(response):
                    let entity = response.results.compactMap { Flow.EventResult(value: $0) }
                    promise.succeed(entity)
                case let .failure(error):
                    promise.fail(error)
                }
            }
            return promise.futureResult
        }

        public func getEventsForBlockIds(type: String, ids: Set<Flow.ID>) -> EventLoopFuture<[Flow.EventResult]> {
            var request = Flow_Access_GetEventsForBlockIDsRequest()
            request.type = type
            request.blockIds = ids.compactMap { $0.data }
            let promise = clientChannel.eventLoop.makePromise(of: [Flow.EventResult].self)
            accessClient.getEventsForBlockIDs(request).response.whenComplete { result in
                switch result {
                case let .success(response):
                    let entity = response.results.compactMap { Flow.EventResult(value: $0) }
                    promise.succeed(entity)
                case let .failure(error):
                    promise.fail(error)
                }
            }
            return promise.futureResult
        }

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
