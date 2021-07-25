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

    func getLatestBlockHeader() -> EventLoopFuture<FlowBlockHeader>

    func getBlockHeaderById(id: FlowId) -> EventLoopFuture<FlowBlockHeader?>

    func getBlockHeaderByHeight(height: UInt64) -> EventLoopFuture<FlowBlockHeader?>

    func getLatestBlock(sealed: Bool) -> EventLoopFuture<FlowBlock>

    func getBlockById(id: FlowId) -> EventLoopFuture<FlowBlock?>

    func getBlockByHeight(height: UInt64) -> EventLoopFuture<FlowBlock?>

    func getCollectionById(id: FlowId) -> EventLoopFuture<FlowCollection?>

    func sendTransaction(transaction: FlowTransaction) -> EventLoopFuture<FlowId>

    func getTransactionById(id: FlowId) -> EventLoopFuture<FlowTransaction?>

    func getTransactionResultById(id: FlowId) -> EventLoopFuture<FlowTransactionResult?>

    func getAccountAtLatestBlock(addresss: FlowAddress) -> EventLoopFuture<FlowAccount?>

    func getAccountByBlockHeight(addresss: FlowAddress, height: UInt64) -> EventLoopFuture<FlowAccount?>

    func executeScriptAtLatestBlock(script: FlowScript, arguments: String...) -> EventLoopFuture<FlowScriptResponse>

    func executeScriptAtBlockId(script: FlowScript, blockId: FlowId, arguments: String...) -> EventLoopFuture<FlowScriptResponse>

    func executeScriptAtBlockHeight(script: FlowScript, height: UInt64, arguments: String...) -> EventLoopFuture<FlowScriptResponse>

    func getEventsForHeightRange(type: String, range: ClosedRange<UInt64>) -> EventLoopFuture<[FlowEventResult]>

    func getEventsForBlockIds(type: String, ids: Set<FlowId>) -> EventLoopFuture<[FlowEventResult]>

    func getNetworkParameters() -> EventLoopFuture<FlowChainId>

    func getLatestProtocolStateSnapshot() -> EventLoopFuture<FlowSnapshot>
}
