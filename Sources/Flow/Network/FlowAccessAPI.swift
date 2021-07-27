//
//  File.swift
//
//
//  Created by lmcmz on 25/7/21.
//

import Foundation
import GRPC
import NIO
import SwiftProtobuf

class FlowAccessAPI: FlowAccessProtocol {
    var clientChannel: ClientConnection
    var accessClient: Flow_Access_AccessAPIClient

    init(config: ClientConnection.Configuration) {
        clientChannel = ClientConnection(configuration: config)
        accessClient = Flow_Access_AccessAPIClient(channel: clientChannel)
    }

    // MARK: - Implementation

    func ping() -> EventLoopFuture<Bool> {
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

    func getLatestBlockHeader() -> EventLoopFuture<Flow.BlockHeader> {
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

    func getBlockHeaderById(id: FlowId) -> EventLoopFuture<Flow.BlockHeader?> {
        var request = Flow_Access_GetBlockByIDRequest()
        request.id = id.bytes.data
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

    func getBlockHeaderByHeight(height: UInt64) -> EventLoopFuture<Flow.BlockHeader?> {
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

    func getLatestBlock(sealed: Bool) -> EventLoopFuture<Flow.Block> {
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

    func getBlockById(id: FlowId) -> EventLoopFuture<Flow.Block?> {
        var request = Flow_Access_GetBlockByIDRequest()
        request.id = id.bytes.data
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

    func getBlockByHeight(height: UInt64) -> EventLoopFuture<Flow.Block?> {
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

    func getCollectionById(id: FlowId) -> EventLoopFuture<Flow.Collection?> {
        var request = Flow_Access_GetCollectionByIDRequest()
        request.id = id.bytes.data
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

    func sendTransaction(transaction: Flow.Transaction) -> EventLoopFuture<FlowId> {
        var request = Flow_Access_SendTransactionRequest()
        request.transaction = transaction.toFlowEntity()
        let promise = clientChannel.eventLoop.makePromise(of: FlowId.self)
        accessClient.sendTransaction(request).response.whenComplete { result in
            switch result {
            case let .success(response):
                let entity = FlowId(bytes: response.id.byteArray)
                promise.succeed(entity)
            case let .failure(error):
                promise.fail(error)
            }
        }
        return promise.futureResult
    }

    func getTransactionById(id: FlowId) -> EventLoopFuture<Flow.Transaction?> {
        var request = Flow_Access_GetTransactionRequest()
        request.id = id.bytes.data
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

    func getTransactionResultById(id: FlowId) -> EventLoopFuture<Flow.TransactionResult?> {
        var request = Flow_Access_GetTransactionRequest()
        request.id = id.bytes.data
        let promise = clientChannel.eventLoop.makePromise(of: Flow.TransactionResult?.self)
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

    func getAccountAtLatestBlock(address: Flow.Address) -> EventLoopFuture<Flow.Account?> {
        var request = Flow_Access_GetAccountAtLatestBlockRequest()
        request.address = address.bytes.data
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

    func getAccountByBlockHeight(address: Flow.Address, height: UInt64) -> EventLoopFuture<Flow.Account?> {
        var request = Flow_Access_GetAccountAtBlockHeightRequest()
        request.address = address.bytes.data
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

    func executeScriptAtLatestBlock(script: Flow.Script, arguments: String...) -> EventLoopFuture<Flow.ScriptResponse> {
        var request = Flow_Access_ExecuteScriptAtLatestBlockRequest()
        request.script = script.bytes.data
        request.arguments = arguments.compactMap { $0.data(using: .utf8) }
        let promise = clientChannel.eventLoop.makePromise(of: Flow.ScriptResponse.self)
        accessClient.executeScriptAtLatestBlock(request).response.whenComplete { result in
            switch result {
            case let .success(response):
                let entity = Flow.ScriptResponse(bytes: response.value.byteArray)
                promise.succeed(entity)
            case let .failure(error):
                promise.fail(error)
            }
        }
        return promise.futureResult
    }

    func executeScriptAtBlockId(script: Flow.Script, blockId _: FlowId, arguments: String...) -> EventLoopFuture<Flow.ScriptResponse> {
        var request = Flow_Access_ExecuteScriptAtBlockIDRequest()
        request.script = script.bytes.data
        request.arguments = arguments.compactMap { $0.data(using: .utf8) }
        let promise = clientChannel.eventLoop.makePromise(of: Flow.ScriptResponse.self)
        accessClient.executeScriptAtBlockID(request).response.whenComplete { result in
            switch result {
            case let .success(response):
                let entity = Flow.ScriptResponse(bytes: response.value.byteArray)
                promise.succeed(entity)
            case let .failure(error):
                promise.fail(error)
            }
        }
        return promise.futureResult
    }

    func executeScriptAtBlockHeight(script: Flow.Script, height: UInt64, arguments: String...) -> EventLoopFuture<Flow.ScriptResponse> {
        var request = Flow_Access_ExecuteScriptAtBlockHeightRequest()
        request.script = script.bytes.data
        request.blockHeight = height
        request.arguments = arguments.compactMap { $0.data(using: .utf8) }
        let promise = clientChannel.eventLoop.makePromise(of: Flow.ScriptResponse.self)
        accessClient.executeScriptAtBlockHeight(request).response.whenComplete { result in
            switch result {
            case let .success(response):
                let entity = Flow.ScriptResponse(bytes: response.value.byteArray)
                promise.succeed(entity)
            case let .failure(error):
                promise.fail(error)
            }
        }
        return promise.futureResult
    }

    func getEventsForHeightRange(type: String, range: ClosedRange<UInt64>) -> EventLoopFuture<[Flow.EventResult]> {
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

    func getEventsForBlockIds(type: String, ids: Set<FlowId>) -> EventLoopFuture<[Flow.EventResult]> {
        var request = Flow_Access_GetEventsForBlockIDsRequest()
        request.type = type
        request.blockIds = ids.compactMap { $0.bytes.data }
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

    func getNetworkParameters() -> EventLoopFuture<Flow.ChainId> {
        let request = Flow_Access_GetNetworkParametersRequest()
        let promise = clientChannel.eventLoop.makePromise(of: Flow.ChainId.self)
        accessClient.getNetworkParameters(request).response.whenComplete { result in
            switch result {
            case let .success(response):
                let entity = Flow.ChainId(id: response.chainID)
                promise.succeed(entity)
            case let .failure(error):
                promise.fail(error)
            }
        }
        return promise.futureResult
    }

    func getLatestProtocolStateSnapshot() -> EventLoopFuture<FlowSnapshot> {
        let request = Flow_Access_GetLatestProtocolStateSnapshotRequest()
        let promise = clientChannel.eventLoop.makePromise(of: FlowSnapshot.self)
        accessClient.getLatestProtocolStateSnapshot(request).response.whenComplete { result in
            switch result {
            case let .success(response):
                let entity = FlowSnapshot(bytes: response.serializedSnapshot.byteArray)
                promise.succeed(entity)
            case let .failure(error):
                promise.fail(error)
            }
        }
        return promise.futureResult
    }
}
