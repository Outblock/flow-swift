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

    func getLatestBlockHeader() -> EventLoopFuture<FlowBlockHeader> {
        let request = Flow_Access_GetLatestBlockRequest()
        let promise = clientChannel.eventLoop.makePromise(of: FlowBlockHeader.self)
        accessClient.getLatestBlock(request).response.whenComplete { result in
            switch result {
            case let .success(response):
                let entity = FlowBlockHeader(value: response.block)
                promise.succeed(entity)
            case let .failure(error):
                promise.fail(error)
            }
        }
        return promise.futureResult
    }

    func getBlockHeaderById(id: FlowId) -> EventLoopFuture<FlowBlockHeader?> {
        var request = Flow_Access_GetBlockByIDRequest()
        request.id = id.bytes.data
        let promise = clientChannel.eventLoop.makePromise(of: FlowBlockHeader?.self)
        accessClient.getBlockByID(request).response.whenComplete { result in
            switch result {
            case let .success(response):
                if response.hasBlock {
                    let entity = FlowBlockHeader(value: response.block)
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

    func getBlockHeaderByHeight(height: UInt64) -> EventLoopFuture<FlowBlockHeader?> {
        var request = Flow_Access_GetBlockHeaderByHeightRequest()
        request.height = height
        let promise = clientChannel.eventLoop.makePromise(of: FlowBlockHeader?.self)
        accessClient.getBlockHeaderByHeight(request).response.whenComplete { result in
            switch result {
            case let .success(response):
                if response.hasBlock {
                    let entity = FlowBlockHeader(value: response.block)
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

    func getLatestBlock(sealed: Bool) -> EventLoopFuture<FlowBlock> {
        var request = Flow_Access_GetLatestBlockRequest()
        request.isSealed = sealed
        let promise = clientChannel.eventLoop.makePromise(of: FlowBlock.self)
        accessClient.getLatestBlock(request).response.whenComplete { result in
            switch result {
            case let .success(response):
                let entity = FlowBlock(value: response.block)
                promise.succeed(entity)
            case let .failure(error):
                promise.fail(error)
            }
        }
        return promise.futureResult
    }

    func getBlockById(id: FlowId) -> EventLoopFuture<FlowBlock?> {
        var request = Flow_Access_GetBlockByIDRequest()
        request.id = id.bytes.data
        let promise = clientChannel.eventLoop.makePromise(of: FlowBlock?.self)
        accessClient.getBlockByID(request).response.whenComplete { result in
            switch result {
            case let .success(response):
                if response.hasBlock {
                    let entity = FlowBlock(value: response.block)
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

    func getBlockByHeight(height: UInt64) -> EventLoopFuture<FlowBlock?> {
        var request = Flow_Access_GetBlockByHeightRequest()
        request.height = height
        let promise = clientChannel.eventLoop.makePromise(of: FlowBlock?.self)
        accessClient.getBlockByHeight(request).response.whenComplete { result in
            switch result {
            case let .success(response):
                if response.hasBlock {
                    let entity = FlowBlock(value: response.block)
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

    func getCollectionById(id: FlowId) -> EventLoopFuture<FlowCollection?> {
        var request = Flow_Access_GetCollectionByIDRequest()
        request.id = id.bytes.data
        let promise = clientChannel.eventLoop.makePromise(of: FlowCollection?.self)
        accessClient.getCollectionByID(request).response.whenComplete { result in
            switch result {
            case let .success(response):
                if response.hasCollection {
                    let entity = FlowCollection(value: response.collection)
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

    func sendTransaction(transaction: FlowTransaction) -> EventLoopFuture<FlowId> {
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

    func getTransactionById(id: FlowId) -> EventLoopFuture<FlowTransaction?> {
        var request = Flow_Access_GetTransactionRequest()
        request.id = id.bytes.data
        let promise = clientChannel.eventLoop.makePromise(of: FlowTransaction?.self)
        accessClient.getTransaction(request).response.whenComplete { result in
            switch result {
            case let .success(response):
                if response.hasTransaction {
                    let entity = FlowTransaction(value: response.transaction)
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

    func getTransactionResultById(id: FlowId) -> EventLoopFuture<FlowTransactionResult?> {
        var request = Flow_Access_GetTransactionRequest()
        request.id = id.bytes.data
        let promise = clientChannel.eventLoop.makePromise(of: FlowTransactionResult?.self)
        accessClient.getTransactionResult(request).response.whenComplete { result in
            switch result {
            case let .success(response):
                let entity = FlowTransactionResult(value: response)
                promise.succeed(entity)
            case let .failure(error):
                promise.fail(error)
            }
        }
        return promise.futureResult
    }

    func getAccountAtLatestBlock(address: FlowAddress) -> EventLoopFuture<FlowAccount?> {
        var request = Flow_Access_GetAccountAtLatestBlockRequest()
        request.address = address.bytes.data
        let promise = clientChannel.eventLoop.makePromise(of: FlowAccount?.self)
        accessClient.getAccountAtLatestBlock(request).response.whenComplete { result in
            switch result {
            case let .success(response):
                if response.hasAccount {
                    let entity = FlowAccount(value: response.account)
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

    func getAccountByBlockHeight(address: FlowAddress, height _: UInt64) -> EventLoopFuture<FlowAccount?> {
        var request = Flow_Access_GetAccountAtBlockHeightRequest()
        request.address = address.bytes.data
        let promise = clientChannel.eventLoop.makePromise(of: FlowAccount?.self)
        accessClient.getAccountAtBlockHeight(request).response.whenComplete { result in
            switch result {
            case let .success(response):
                if response.hasAccount {
                    let entity = FlowAccount(value: response.account)
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

    func executeScriptAtLatestBlock(script: FlowScript, arguments: String...) -> EventLoopFuture<FlowScriptResponse> {
        var request = Flow_Access_ExecuteScriptAtLatestBlockRequest()
        request.script = script.bytes.data
        request.arguments = arguments.compactMap { $0.data(using: .utf8) }
        let promise = clientChannel.eventLoop.makePromise(of: FlowScriptResponse.self)
        accessClient.executeScriptAtLatestBlock(request).response.whenComplete { result in
            switch result {
            case let .success(response):
                let entity = FlowScriptResponse(bytes: response.value.byteArray)
                promise.succeed(entity)
            case let .failure(error):
                promise.fail(error)
            }
        }
        return promise.futureResult
    }

    func executeScriptAtBlockId(script: FlowScript, blockId _: FlowId, arguments: String...) -> EventLoopFuture<FlowScriptResponse> {
        var request = Flow_Access_ExecuteScriptAtBlockIDRequest()
        request.script = script.bytes.data
        request.arguments = arguments.compactMap { $0.data(using: .utf8) }
        let promise = clientChannel.eventLoop.makePromise(of: FlowScriptResponse.self)
        accessClient.executeScriptAtBlockID(request).response.whenComplete { result in
            switch result {
            case let .success(response):
                let entity = FlowScriptResponse(bytes: response.value.byteArray)
                promise.succeed(entity)
            case let .failure(error):
                promise.fail(error)
            }
        }
        return promise.futureResult
    }

    func executeScriptAtBlockHeight(script: FlowScript, height: UInt64, arguments: String...) -> EventLoopFuture<FlowScriptResponse> {
        var request = Flow_Access_ExecuteScriptAtBlockHeightRequest()
        request.script = script.bytes.data
        request.blockHeight = height
        request.arguments = arguments.compactMap { $0.data(using: .utf8) }
        let promise = clientChannel.eventLoop.makePromise(of: FlowScriptResponse.self)
        accessClient.executeScriptAtBlockHeight(request).response.whenComplete { result in
            switch result {
            case let .success(response):
                let entity = FlowScriptResponse(bytes: response.value.byteArray)
                promise.succeed(entity)
            case let .failure(error):
                promise.fail(error)
            }
        }
        return promise.futureResult
    }

    func getEventsForHeightRange(type: String, range: ClosedRange<UInt64>) -> EventLoopFuture<[FlowEventResult]> {
        var request = Flow_Access_GetEventsForHeightRangeRequest()
        request.type = type
        request.startHeight = range.lowerBound
        request.endHeight = range.upperBound
        let promise = clientChannel.eventLoop.makePromise(of: [FlowEventResult].self)
        accessClient.getEventsForHeightRange(request).response.whenComplete { result in
            switch result {
            case let .success(response):
                let entity = response.results.compactMap { FlowEventResult(value: $0) }
                promise.succeed(entity)
            case let .failure(error):
                promise.fail(error)
            }
        }
        return promise.futureResult
    }

    func getEventsForBlockIds(type: String, ids: Set<FlowId>) -> EventLoopFuture<[FlowEventResult]> {
        var request = Flow_Access_GetEventsForBlockIDsRequest()
        request.type = type
        request.blockIds = ids.compactMap { $0.bytes.data }
        let promise = clientChannel.eventLoop.makePromise(of: [FlowEventResult].self)
        accessClient.getEventsForBlockIDs(request).response.whenComplete { result in
            switch result {
            case let .success(response):
                let entity = response.results.compactMap { FlowEventResult(value: $0) }
                promise.succeed(entity)
            case let .failure(error):
                promise.fail(error)
            }
        }
        return promise.futureResult
    }

    func getNetworkParameters() -> EventLoopFuture<FlowChainId> {
        let request = Flow_Access_GetNetworkParametersRequest()
        let promise = clientChannel.eventLoop.makePromise(of: FlowChainId.self)
        accessClient.getNetworkParameters(request).response.whenComplete { result in
            switch result {
            case let .success(response):
                let entity = FlowChainId(id: response.chainID)
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
