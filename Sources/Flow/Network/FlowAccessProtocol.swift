//
//  FlowAccessApi.swift
//
//
//  Created by lmcmz on 19/7/21.
//

import Combine
import Foundation

protocol FlowAccessProtocol {
    func ping() -> Future<Void, Never>

    func getLatestBlockHeader() -> Future<FlowBlockHeader, Never>

    func getBlockHeaderById(id: FlowId) -> Future<FlowBlockHeader?, Never>

    func getBlockHeaderByHeight(height: UInt64) -> Future<FlowBlockHeader?, Never>

    func getLatestBlock(sealed: Bool) -> Future<FlowBlock, Never>

    func getBlockById(id: FlowId) -> Future<FlowBlock?, Never>

    func getBlockByHeight(height: UInt64) -> Future<FlowBlock?, Never>

    func getCollectionById(id: FlowId) -> Future<FlowCollection?, Never>

    func sendTransaction(transaction: FlowTransaction) -> Future<FlowId, Never>

    func getTransactionById(id: FlowId) -> Future<FlowTransaction?, Never>

    func getTransactionResultById(id: FlowId) -> Future<FlowTransactionResult?, Never>

    func getAccountAtLatestBlock(addresss: FlowAddress) -> Future<FlowAccount?, Never>

    func getAccountByBlockHeight(addresss: FlowAddress, height: UInt64) -> Future<FlowAccount?, Never>

    func executeScriptAtLatestBlock(script: FlowScript, arguments: String...) -> Future<FlowScriptResponse, Never>

    func executeScriptAtBlockId(script: FlowScript, blockId: FlowId, arguments: String...) -> Future<FlowScriptResponse, Never>

    func executeScriptAtBlockHeight(script: FlowScript, height: UInt64, arguments: String...) -> Future<FlowScriptResponse, Never>

    func getEventsForHeightRange(type: String, range: ClosedRange<UInt64>) -> Future<[FlowEventResult], Never>

    func getEventsForBlockIds(type: String, ids: Set<FlowId>) -> Future<[FlowEventResult], Never>

    func getNetworkParameters() -> Future<FlowChainId, Never>

    func getLatestProtocolStateSnapshot() -> Future<FlowSnapshot, Never>
}
