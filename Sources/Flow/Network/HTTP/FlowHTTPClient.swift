//
//  File.swift
//
//
//  Created by Hao Fu on 20/6/2022.
//

import Foundation


extension Flow {
    class FlowHTTPAPI: FlowAccessProtocol {
        static let client = FlowHTTPAPI()

        var chainID: ChainID

        init(chainID: ChainID = .mainnet) {
            self.chainID = chainID
        }

        func request<T: Decodable, U: TargetType>(_ target: U) async throws -> T {
            guard var urlComponents = URLComponents(string: target.baseURL.absoluteString),
                  case let .requestParameters(parameters, body: body) = target.task
            else {
                throw FError.urlInvaild
            }
            urlComponents.path = target.path
            urlComponents.queryItems = parameters?.map { (key: String, value: String) in
                URLQueryItem(name: key, value: value)
            }

            guard let url = urlComponents.url else {
                throw Flow.FError.urlInvaild
            }

            var request = URLRequest(url: url)
            request.httpMethod = target.method.rawValue

            if let bodyObject = body {
                let encoder = JSONEncoder()
                encoder.dataEncodingStrategy = .base64
                let data = try encoder.encode(AnyEncodable(bodyObject))
                request.httpBody = data
            }

//            let config = URLSessionConfiguration()
//            config.identifier = "FLOW ACCESS HTTP"
            let (data, _) = try await URLSession.shared.data(for: request)
            
            let dateFormatter = DateFormatter()
            // 2022-06-22T15:32:09.08595992Z
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSS'Z'"
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            decoder.dataDecodingStrategy = .base64
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                _ = try decoder.decode(T.self, from: data)
            } catch  {
                print(error)
            }
            
            return try decoder.decode(T.self, from: data)
        }

        func ping() async throws -> Bool {
            let result: [Flow.BlockResponse] = try await request(Flow.AccessEndpoint.ping)
            guard let block = result.first else {
                return false
            }
            return block.header.height > 0
        }

        func getLatestBlockHeader() async throws -> Flow.BlockHeader {
            let result: [Flow.BlockHeaderResponse] = try await request(Flow.AccessEndpoint.getLatestBlockHeader)
            guard let block = result.first else {
                throw FError.invaildResponse
            }
            return block.header
        }

        func getBlockHeaderById(id: Flow.ID) async throws -> Flow.BlockHeader {
            let result: [Flow.BlockHeaderResponse] = try await request(Flow.AccessEndpoint.getBlockById(id: id))
            guard let block = result.first else {
                throw FError.invaildResponse
            }
            return block.header
        }

        func getBlockHeaderByHeight(height: UInt64) async throws -> Flow.BlockHeader {
            let result: [Flow.BlockHeaderResponse] = try await request(Flow.AccessEndpoint.getBlockByHeight(height: height))
            guard let block = result.first else {
                throw FError.invaildResponse
            }
            return block.header
        }

        func getLatestBlock(sealed: Bool) async throws -> Flow.Block {
            let result: [Flow.BlockResponse] = try await request(Flow.AccessEndpoint.getLatestBlock(sealed: sealed))
            guard let block = result.first else {
                throw FError.invaildResponse
            }
            return block.toFlowBlock()
        }

        func getBlockById(id: Flow.ID) async throws -> Flow.Block {
            let result: [Flow.BlockResponse] = try await request(Flow.AccessEndpoint.getBlockById(id: id))
            guard let block = result.first else {
                throw FError.invaildResponse
            }
            return block.toFlowBlock()
        }

        func getBlockByHeight(height: UInt64) async throws -> Flow.Block {
            let result: [Flow.BlockResponse] = try await request(Flow.AccessEndpoint.getBlockByHeight(height: height))
            guard let block = result.first else {
                throw FError.invaildResponse
            }
            return block.toFlowBlock()
        }

        func getCollectionById(id: Flow.ID) async throws -> Flow.Collection {
            return try await request(Flow.AccessEndpoint.getCollectionById(id: id))
        }

        func sendTransaction(transaction: Flow.Transaction) async throws -> Flow.ID {
            return try await request(Flow.AccessEndpoint.sendTransaction(transaction: transaction))
        }

        func getTransactionById(id: Flow.ID) async throws -> Flow.Transaction {
            return try await request(Flow.AccessEndpoint.getTransactionById(id: id))
        }

        func getTransactionResultById(id: Flow.ID) async throws -> Flow.TransactionResult {
            return try await request(Flow.AccessEndpoint.getTransactionResultById(id: id))
        }

        func getAccountAtLatestBlock(address: Flow.Address) async throws -> Flow.Account {
            return try await request(Flow.AccessEndpoint.getAccountAtLatestBlock(address: address))
        }

        func getAccountByBlockHeight(address: Flow.Address, height: UInt64) async throws -> Flow.Account {
            return try await request(Flow.AccessEndpoint.getAccountByBlockHeight(address: address, height: height))
        }

        func executeScriptAtLatestBlock(script: Flow.Script, arguments: [Flow.Argument]) async throws -> Flow.ScriptResponse {
            return try await request(Flow.AccessEndpoint.executeScriptAtLatestBlock(script: script, arguments: arguments))
        }

        func executeScriptAtBlockId(script: Flow.Script, blockId: Flow.ID, arguments: [Flow.Argument]) async throws -> Flow.ScriptResponse {
            return try await request(Flow.AccessEndpoint.executeScriptAtBlockId(script: script, blockId: blockId, arguments: arguments))
        }

        func executeScriptAtBlockHeight(script: Flow.Script, height: UInt64, arguments: [Flow.Argument]) async throws -> Flow.ScriptResponse {
            return try await request(Flow.AccessEndpoint.executeScriptAtBlockHeight(script: script, height: height, arguments: arguments))
        }

        func getEventsForHeightRange(type: String, range: ClosedRange<UInt64>) async throws -> [Flow.Event.Result] {
            return try await request(Flow.AccessEndpoint.getEventsForHeightRange(type: type, range: range))
        }

        func getEventsForBlockIds(type: String, ids: Set<Flow.ID>) async throws -> [Flow.Event.Result] {
            return try await request(Flow.AccessEndpoint.getEventsForBlockIds(type: type, ids: ids))
        }

        func getNetworkParameters() async throws -> Flow.ChainID {
            return try await request(Flow.AccessEndpoint.getNetworkParameters)
        }

        func getLatestProtocolStateSnapshot() async throws -> Flow.Snapshot {
            return try await request(Flow.AccessEndpoint.getLatestProtocolStateSnapshot)
        }
    }
}
