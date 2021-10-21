//
//  File.swift
//  File
//
//  Created by lmcmz on 1/10/21.
//

import Foundation

public typealias Callback<T> = (Result<T, Error>) -> Void

public protocol FlowAccessBlockProtocol {
    func ping(completion: @escaping Callback<Bool>)

    func getLatestBlockHeader(completion: @escaping Callback<Flow.BlockHeader>)

    func getBlockHeaderById(id: Flow.ID, completion: @escaping Callback<Flow.BlockHeader?>)

    func getBlockHeaderByHeight(height: UInt64, completion: @escaping Callback<Flow.BlockHeader?>)

    func getLatestBlock(sealed: Bool, completion: @escaping Callback<Flow.Block>)

    func getBlockById(id: Flow.ID, completion: @escaping Callback<Flow.Block?>)

    func getBlockByHeight(height: UInt64, completion: @escaping Callback<Flow.Block?>)

    func getCollectionById(id: Flow.ID, completion: @escaping Callback<Flow.Collection?>)

    func sendTransaction(transaction: Flow.Transaction, completion: @escaping Callback<Flow.ID>)

    func getTransactionById(id: Flow.ID, completion: @escaping Callback<Flow.Transaction?>)

    func getTransactionResultById(id: Flow.ID, completion: @escaping Callback<Flow.TransactionResult>)

    func getAccountAtLatestBlock(address: Flow.Address, completion: @escaping Callback<Flow.Account?>)

    func getAccountByBlockHeight(address: Flow.Address, height: UInt64, completion: @escaping Callback<Flow.Account?>)

    func executeScriptAtLatestBlock(script: Flow.Script, arguments: [Flow.Argument], completion: @escaping Callback<Flow.ScriptResponse>)

    func executeScriptAtBlockId(script: Flow.Script, blockId: Flow.ID, arguments: [Flow.Argument], completion: @escaping Callback<Flow.ScriptResponse>)

    func executeScriptAtBlockHeight(script: Flow.Script, height: UInt64, arguments: [Flow.Argument], completion: @escaping Callback<Flow.ScriptResponse>)

    func getEventsForHeightRange(type: String, range: ClosedRange<UInt64>, completion: @escaping Callback<[Flow.Event.Result]>)

    func getEventsForBlockIds(type: String, ids: Set<Flow.ID>, completion: @escaping Callback<[Flow.Event.Result]>)

    func getNetworkParameters(completion: @escaping Callback<Flow.ChainID>)

    func getLatestProtocolStateSnapshot(completion: @escaping Callback<Flow.Snapshot>)
}
