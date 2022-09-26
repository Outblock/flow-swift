//
//  CadenceTypeTest
//
//  Copyright 2022 Outblock Pty Ltd
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

extension Flow {
    enum AccessEndpoint {
        case ping
        case getBlockHeaderByHeight(height: UInt64)
        case getBlockHeaderById(id: Flow.ID)
        case getLatestBlockHeader
        case getLatestBlock(sealed: Bool)
        case getBlockById(id: Flow.ID)
        case getBlockByHeight(height: UInt64)
        case getCollectionById(id: Flow.ID)
        case sendTransaction(transaction: Flow.Transaction)
        case getTransactionById(id: Flow.ID)
        case getTransactionResultById(id: Flow.ID)
        case getAccountAtLatestBlock(address: Flow.Address)
        case getAccountByBlockHeight(address: Flow.Address, height: UInt64)
        case executeScriptAtLatestBlock(script: Flow.Script, arguments: [Flow.Argument])
        case executeScriptAtBlockId(script: Flow.Script, blockId: Flow.ID, arguments: [Flow.Argument])
        case executeScriptAtBlockHeight(script: Flow.Script, height: UInt64, arguments: [Flow.Argument])
        case getEventsForHeightRange(type: String, range: ClosedRange<UInt64>)
        case getEventsForBlockIds(type: String, ids: Set<Flow.ID>)
    }
}

extension Flow.AccessEndpoint: TargetType {
    var task: Task {
        switch self {
        case .ping, .getLatestBlockHeader:
            return .requestParameters(["height": "sealed"])
        case let .getBlockHeaderByHeight(height: height):
            return .requestParameters(["height": String(height)])
        case .getBlockById:
            return .requestParameters(["expand": "payload"])
        case let .getBlockByHeight(height):
            return .requestParameters(["height": String(height), "expand": "payload"])
        case let .getLatestBlock(sealed: sealed):
            return .requestParameters(["height": sealed ? "sealed" : "finalized", "expand": "payload"])
        case .getAccountAtLatestBlock:
            return .requestParameters(["block_height": "sealed", "expand": "contracts,keys"])
        case let .getAccountByBlockHeight(_, height):
            return .requestParameters(["block_height": String(height), "expand": "contracts,keys"])
        case .getCollectionById:
            return .requestParameters(["expand": "transactions"])
        case let .executeScriptAtLatestBlock(script, arguments):
            return .requestParameters(["block_height": "sealed"], body: Flow.ScriptRequest(script: script, arguments: arguments))
        case let .executeScriptAtBlockHeight(script, height, arguments):
            return .requestParameters(["block_height": String(height)], body: Flow.ScriptRequest(script: script, arguments: arguments))
        case let .executeScriptAtBlockId(script, id, arguments):
            return .requestParameters(["block_id": id.hex], body: Flow.ScriptRequest(script: script, arguments: arguments))
        case let .sendTransaction(tx):
            return .requestParameters([:], body: tx)
        case let .getEventsForHeightRange(type, range):
            return .requestParameters(["type": type, "start_height": String(range.lowerBound), "end_height": String(range.upperBound)])
        case let .getEventsForBlockIds(type, ids):
            return .requestParameters(["type": type, "block_ids": ids.compactMap { $0.hex }.joined(separator: ",")])
        default:
            return .requestParameters()
        }
    }

    var method: Method {
        switch self {
        case .ping, .getBlockByHeight, .getBlockHeaderById:
            return .GET
        case .sendTransaction,
             .executeScriptAtBlockHeight,
             .executeScriptAtLatestBlock,
             .executeScriptAtBlockId:
            return .POST
        default:
            return .GET
        }
    }

    var baseURL: URL {
        flow.chainID.defaultHTTPNode.url!
    }

    var path: String {
        switch self {
        case .ping,
             .getLatestBlockHeader,
             .getBlockByHeight,
             .getLatestBlock:
            return "/v1/blocks"
        case let .getBlockHeaderById(id):
            return "/v1/blocks/\(id.hex)"
        case let .getBlockById(id):
            return "/v1/blocks/\(id.hex)"
        case let .getAccountAtLatestBlock(address):
            return "/v1/accounts/\(address.hex.stripHexPrefix())"
        case let .getAccountByBlockHeight(address, _):
            return "/v1/accounts/\(address.hex.stripHexPrefix())"
        case let .getTransactionResultById(id):
            return "/v1/transaction_results/\(id.hex)"
        case let .getTransactionById(id):
            return "/v1/transactions/\(id.hex)"
        case let .getCollectionById(id):
            return "/v1/collections/\(id.hex)"
        case .executeScriptAtLatestBlock,
             .executeScriptAtBlockId,
             .executeScriptAtBlockHeight:
            return "/v1/scripts"
        case .sendTransaction:
            return "/v1/transactions"
        case .getEventsForBlockIds, .getEventsForHeightRange:
            return "/v1/events"
        default:
            return ""
        }
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
