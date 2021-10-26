//
//  FlowAccessProtocol+Block
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

/// The wrapper for type of `Result<T, Error>`, used as block callback
public typealias Callback<T> = (Result<T, Error>) -> Void

/// The network protocol for access api with block callback
/// Find more detail here: https://docs.onflow.org/access-api/
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
