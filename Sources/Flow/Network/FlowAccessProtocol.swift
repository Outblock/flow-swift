//
//  FlowAccessProtocol
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
import NIO

/// The network protocol for access api
/// Find more detail here: https://docs.onflow.org/access-api/
public protocol FlowAccessProtocol {
    func ping() -> EventLoopFuture<Bool>

    func getLatestBlockHeader() -> EventLoopFuture<Flow.BlockHeader>

    func getBlockHeaderById(id: Flow.ID) -> EventLoopFuture<Flow.BlockHeader?>

    func getBlockHeaderByHeight(height: UInt64) -> EventLoopFuture<Flow.BlockHeader?>

    func getLatestBlock(sealed: Bool) -> EventLoopFuture<Flow.Block>

    func getBlockById(id: Flow.ID) -> EventLoopFuture<Flow.Block?>

    func getBlockByHeight(height: UInt64) -> EventLoopFuture<Flow.Block?>

    func getCollectionById(id: Flow.ID) -> EventLoopFuture<Flow.Collection?>

    func sendTransaction(transaction: Flow.Transaction) -> EventLoopFuture<Flow.ID>

    func getTransactionById(id: Flow.ID) -> EventLoopFuture<Flow.Transaction?>

    func getTransactionResultById(id: Flow.ID) -> EventLoopFuture<Flow.TransactionResult>

    func getAccountAtLatestBlock(address: Flow.Address) -> EventLoopFuture<Flow.Account?>

    func getAccountByBlockHeight(address: Flow.Address, height: UInt64) -> EventLoopFuture<Flow.Account?>

    func executeScriptAtLatestBlock(script: Flow.Script, arguments: [Flow.Argument]) -> EventLoopFuture<Flow.ScriptResponse>

    func executeScriptAtBlockId(script: Flow.Script, blockId: Flow.ID, arguments: [Flow.Argument]) -> EventLoopFuture<Flow.ScriptResponse>

    func executeScriptAtBlockHeight(script: Flow.Script, height: UInt64, arguments: [Flow.Argument]) -> EventLoopFuture<Flow.ScriptResponse>

    func getEventsForHeightRange(type: String, range: ClosedRange<UInt64>) -> EventLoopFuture<[Flow.Event.Result]>

    func getEventsForBlockIds(type: String, ids: Set<Flow.ID>) -> EventLoopFuture<[Flow.Event.Result]>

    func getNetworkParameters() -> EventLoopFuture<Flow.ChainID>

    func getLatestProtocolStateSnapshot() -> EventLoopFuture<Flow.Snapshot>
}
