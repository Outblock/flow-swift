//
//  File.swift
//  File
//
//  Created by lmcmz on 1/10/21.
//

import Foundation
import NIO

extension Flow.AccessAPI: FlowAccessBlockProtocol {
    public func ping(completion: @escaping Callback<Bool>) {
        ping().whenComplete { completion($0) }
    }

    public func getLatestBlockHeader(completion: @escaping Callback<Flow.BlockHeader>) {
        getLatestBlockHeader().whenComplete { completion($0) }
    }

    public func getBlockHeaderById(id: Flow.ID, completion: @escaping Callback<Flow.BlockHeader?>) {
        getBlockHeaderById(id: id).whenComplete { completion($0) }
    }

    public func getBlockHeaderByHeight(height: UInt64, completion: @escaping Callback<Flow.BlockHeader?>) {
        getBlockHeaderByHeight(height: height).whenComplete { completion($0) }
    }

    public func getLatestBlock(sealed: Bool, completion: @escaping Callback<Flow.Block>) {
        getLatestBlock(sealed: sealed).whenComplete { completion($0) }
    }

    public func getBlockById(id: Flow.ID, completion: @escaping Callback<Flow.Block?>) {
        getBlockById(id: id).whenComplete { completion($0) }
    }

    public func getBlockByHeight(height: UInt64, completion: @escaping Callback<Flow.Block?>) {
        getBlockByHeight(height: height).whenComplete { completion($0) }
    }

    public func getCollectionById(id: Flow.ID, completion: @escaping Callback<Flow.Collection?>) {
        getCollectionById(id: id).whenComplete { completion($0) }
    }

    public func sendTransaction(transaction: Flow.Transaction, completion: @escaping Callback<Flow.ID>) {
        sendTransaction(transaction: transaction).whenComplete { completion($0) }
    }

    public func getTransactionById(id: Flow.ID, completion: @escaping Callback<Flow.Transaction?>) {
        getTransactionById(id: id).whenComplete { completion($0) }
    }

    public func getTransactionResultById(id: Flow.ID, completion: @escaping Callback<Flow.TransactionResult>) {
        getTransactionResultById(id: id).whenComplete { completion($0) }
    }

    public func getAccountAtLatestBlock(address: Flow.Address, completion: @escaping Callback<Flow.Account?>) {
        getAccountAtLatestBlock(address: address).whenComplete { completion($0) }
    }

    public func getAccountByBlockHeight(address: Flow.Address, height: UInt64, completion: @escaping Callback<Flow.Account?>) {
        getAccountByBlockHeight(address: address, height: height).whenComplete { completion($0) }
    }

    public func executeScriptAtLatestBlock(script: Flow.Script, arguments: [Flow.Argument], completion: @escaping Callback<Flow.ScriptResponse>) {
        executeScriptAtLatestBlock(script: script, arguments: arguments).whenComplete { completion($0) }
    }

    public func executeScriptAtBlockId(script: Flow.Script, blockId: Flow.ID, arguments: [Flow.Argument], completion: @escaping Callback<Flow.ScriptResponse>) {
        executeScriptAtBlockId(script: script, blockId: blockId, arguments: arguments).whenComplete { completion($0) }
    }

    public func executeScriptAtBlockHeight(script: Flow.Script, height: UInt64, arguments: [Flow.Argument], completion: @escaping Callback<Flow.ScriptResponse>) {
        executeScriptAtBlockHeight(script: script, height: height, arguments: arguments).whenComplete { completion($0) }
    }

    public func getEventsForHeightRange(type: String, range: ClosedRange<UInt64>, completion: @escaping Callback<[Flow.EventResult]>) {
        getEventsForHeightRange(type: type, range: range).whenComplete { completion($0) }
    }

    public func getEventsForBlockIds(type: String, ids: Set<Flow.ID>, completion: @escaping Callback<[Flow.EventResult]>) {
        getEventsForBlockIds(type: type, ids: ids).whenComplete { completion($0) }
    }

    public func getNetworkParameters(completion: @escaping Callback<Flow.ChainID>) {
        getNetworkParameters().whenComplete { completion($0) }
    }

    public func getLatestProtocolStateSnapshot(completion: @escaping Callback<Flow.Snapshot>) {
        getLatestProtocolStateSnapshot().whenComplete { completion($0) }
    }
}
