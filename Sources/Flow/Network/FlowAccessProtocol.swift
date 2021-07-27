//
//  FlowAccessApi.swift
//
//
//  Created by lmcmz on 19/7/21.
//

import Foundation
import NIO

protocol FlowAccessProtocol {
    func ping() -> EventLoopFuture<Bool>

    func getLatestBlockHeader() -> EventLoopFuture<Flow.BlockHeader>

    func getBlockHeaderById(id: FlowId) -> EventLoopFuture<Flow.BlockHeader?>

    func getBlockHeaderByHeight(height: UInt64) -> EventLoopFuture<Flow.BlockHeader?>

    func getLatestBlock(sealed: Bool) -> EventLoopFuture<Flow.Block>

    func getBlockById(id: FlowId) -> EventLoopFuture<Flow.Block?>

    func getBlockByHeight(height: UInt64) -> EventLoopFuture<Flow.Block?>

    func getCollectionById(id: FlowId) -> EventLoopFuture<Flow.Collection?>

    func sendTransaction(transaction: Flow.Transaction) -> EventLoopFuture<FlowId>

    func getTransactionById(id: FlowId) -> EventLoopFuture<Flow.Transaction?>

    func getTransactionResultById(id: FlowId) -> EventLoopFuture<Flow.TransactionResult?>

    func getAccountAtLatestBlock(address: Flow.Address) -> EventLoopFuture<Flow.Account?>

    func getAccountByBlockHeight(address: Flow.Address, height: UInt64) -> EventLoopFuture<Flow.Account?>

    func executeScriptAtLatestBlock(script: Flow.Script, arguments: String...) -> EventLoopFuture<Flow.ScriptResponse>

    func executeScriptAtBlockId(script: Flow.Script, blockId: FlowId, arguments: String...) -> EventLoopFuture<Flow.ScriptResponse>

    func executeScriptAtBlockHeight(script: Flow.Script, height: UInt64, arguments: String...) -> EventLoopFuture<Flow.ScriptResponse>

    func getEventsForHeightRange(type: String, range: ClosedRange<UInt64>) -> EventLoopFuture<[Flow.EventResult]>

    func getEventsForBlockIds(type: String, ids: Set<FlowId>) -> EventLoopFuture<[Flow.EventResult]>

    func getNetworkParameters() -> EventLoopFuture<Flow.ChainId>

    func getLatestProtocolStateSnapshot() -> EventLoopFuture<FlowSnapshot>
}
