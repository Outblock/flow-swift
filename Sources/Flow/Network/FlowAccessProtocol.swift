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
// import Foundation
// import Combine

/// The network protocol for access api
/// Find more detail here: https://docs.onflow.org/access-api/
// public protocol FlowAccessProtocol {
//    func ping() -> Future<Bool, Error>
//
//    func getLatestBlockHeader() -> Future<Flow.BlockHeader, Error>
//
//    func getBlockHeaderById(id: Flow.ID) -> Future<Flow.BlockHeader?, Error>
//
//    func getBlockHeaderByHeight(height: UInt64) -> Future<Flow.BlockHeader?, Error>
//
//    func getLatestBlock(sealed: Bool) -> Future<Flow.Block, Error>
//
//    func getBlockById(id: Flow.ID) -> Future<Flow.Block?, Error>
//
//    func getBlockByHeight(height: UInt64) -> Future<Flow.Block?, Error>
//
//    func getCollectionById(id: Flow.ID) -> Future<Flow.Collection?, Error>
//
//    func sendTransaction(transaction: Flow.Transaction) -> Future<Flow.ID, Error>
//
//    func getTransactionById(id: Flow.ID) -> Future<Flow.Transaction?, Error>
//
//    func getTransactionResultById(id: Flow.ID) -> Future<Flow.TransactionResult, Error>
//
//    func getAccountAtLatestBlock(address: Flow.Address) -> Future<Flow.Account?, Error>
//
//    func getAccountByBlockHeight(address: Flow.Address, height: UInt64) -> Future<Flow.Account?, Error>
//
//    func executeScriptAtLatestBlock(script: Flow.Script, arguments: [Flow.Argument]) -> Future<Flow.ScriptResponse, Error>
//
//    func executeScriptAtBlockId(script: Flow.Script, blockId: Flow.ID, arguments: [Flow.Argument]) -> Future<Flow.ScriptResponse, Error>
//
//    func executeScriptAtBlockHeight(script: Flow.Script, height: UInt64, arguments: [Flow.Argument]) -> Future<Flow.ScriptResponse, Error>
//
//    func getEventsForHeightRange(type: String, range: ClosedRange<UInt64>) -> Future<[Flow.Event.Result], Error>
//
//    func getEventsForBlockIds(type: String, ids: Set<Flow.ID>) -> Future<[Flow.Event.Result], Error>
//
//    func getNetworkParameters() -> Future<Flow.ChainID, Error>
//
//    func getLatestProtocolStateSnapshot() -> Future<Flow.Snapshot, Error>
// }
