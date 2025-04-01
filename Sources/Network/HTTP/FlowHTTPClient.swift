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

/// Flow HTTP Client Implementation
///
/// This file provides HTTP client functionality for interacting with the Flow blockchain API.
/// It handles request encoding, response decoding, and error handling for all Flow API endpoints.

import Foundation

extension Flow {
    /// HTTP client implementation for Flow Access API
    /// Handles all network communication with Flow nodes
    class FlowHTTPAPI: FlowAccessProtocol {
        /// Shared instance of the HTTP client
        static let client = FlowHTTPAPI()
        
        /// Current chain ID for the client
        var chainID: ChainID
        
        /// Initialize HTTP client with specific chain ID
        /// - Parameter chainID: Target chain identifier (default: .mainnet)
        init(chainID: ChainID = .mainnet) {
            self.chainID = chainID
        }
        
        /// Decode response data into specified type
        /// - Parameters:
        ///   - data: Response data to decode
        ///   - response: Optional URLResponse for status code checking
        /// - Returns: Decoded object of type T
        /// - Throws: Decoding errors or API errors
        static func decode<T: Decodable>(data: Data, response: URLResponse? = nil) throws -> T {
            let dateFormatter = DateFormatter()
            // 2022-06-22T15:32:09.08595992Z
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS'Z'"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 400
            {
                let errorModel = try decoder.decode(ErrorResponse.self, from: data)
                throw FError.customError(msg: errorModel.message)
            }

            return try decoder.decode(T.self, from: data)
        }
        
        /// Make HTTP request to Flow API
        /// - Parameters:
        ///   - target: API endpoint target
        /// - Returns: Decoded response of type T
        /// - Throws: Network or decoding errors
        func request<T: Decodable, U: TargetType>(_ target: U) async throws -> T {
            FlowLogger.shared.log(.debug, message: "Starting request to: \(target.path)")
            
            guard let url = chainID.defaultHTTPNode.url,
                  var urlComponents = URLComponents(string: url.absoluteString),
                  case let .requestParameters(parameters, body: body) = target.task
            else {
                FlowLogger.shared.log(.error, message: "Invalid URL configuration")
                throw FError.urlInvaild
            }
            
            // Log request details
            FlowLogger.shared.log(.debug, message: "Request parameters: \(String(describing: parameters))")
            if let bodyObject = body {
                FlowLogger.shared.log(.debug, message: "Request body: \(String(describing: bodyObject))")
            }
            
            urlComponents.path = target.path

            if let parametersList = parameters, !parametersList.isEmpty {
                urlComponents.queryItems = parametersList.compactMap { (key: String, value: String) in
                    URLQueryItem(name: key, value: value)
                }
            }

            guard let url = urlComponents.url else {
                throw Flow.FError.urlInvaild
            }

            var request = URLRequest(url: url)
            request.httpMethod = target.method.rawValue

            if let bodyObject = body {
                let encoder = JSONEncoder()
                encoder.keyEncodingStrategy = .convertToSnakeCase
                let data = try encoder.encode(AnyEncodable(bodyObject))
                request.httpBody = data
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue(Flow.shared.defaultUserAgent, forHTTPHeaderField: "User-Agent")
            }

            if let headers = target.headers {
                headers.forEach {
                    request.setValue($1, forHTTPHeaderField: $0)
                }
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Log response
            if let httpResponse = response as? HTTPURLResponse {
                FlowLogger.shared.log(.debug, message: "Response status code: \(httpResponse.statusCode)")
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                FlowLogger.shared.log(.debug, message: "Response data: \(jsonString)")
            }
            
            do {
                let result: T = try Flow.FlowHTTPAPI.decode(data: data, response: response)
                FlowLogger.shared.log(.debug, message: "Successfully decoded response of type: \(T.self)")
                return result
            } catch {
                FlowLogger.shared.log(.error, message: "Decoding error: \(error)")
                throw error
            }
        }

        func ping() async throws -> Bool {
            let result: [Flow.BlockHeaderResponse] = try await request(Flow.AccessEndpoint.ping)
            guard let block = result.first else {
                return false
            }
            return block.header.height > 0
        }

        func getNetworkParameters() async throws -> Flow.ChainID {
            let result: Flow.NetworkResponse = try await request(Flow.AccessEndpoint.getNetwork)
            return result.chainId
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
            let result: TransactionIdResponse = try await request(Flow.AccessEndpoint.sendTransaction(transaction: transaction))
            return result.id
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
            let resolvedScript = flow.addressRegister.resolveImports(in: script.text, for: flow.chainID)
            return try await request(Flow.AccessEndpoint.executeScriptAtLatestBlock(script: .init(text: resolvedScript), arguments: arguments))
        }

        func executeScriptAtBlockId(script: Flow.Script, blockId: Flow.ID, arguments: [Flow.Argument]) async throws -> Flow.ScriptResponse {
            let resolvedScript = flow.addressRegister.resolveImports(in: script.text, for: flow.chainID)
            return try await request(Flow.AccessEndpoint.executeScriptAtBlockId(script: .init(text: resolvedScript), blockId: blockId, arguments: arguments))
        }

        func executeScriptAtBlockHeight(script: Flow.Script, height: UInt64, arguments: [Flow.Argument]) async throws -> Flow.ScriptResponse {
            let resolvedScript = flow.addressRegister.resolveImports(in: script.text, for: flow.chainID)
            return try await request(Flow.AccessEndpoint.executeScriptAtBlockHeight(script: .init(text: resolvedScript), height: height, arguments: arguments))
        }

        func getEventsForHeightRange(type: String, range: ClosedRange<UInt64>) async throws -> [Flow.Event.Result] {
            return try await request(Flow.AccessEndpoint.getEventsForHeightRange(type: type, range: range))
        }

        func getEventsForBlockIds(type: String, ids: Set<Flow.ID>) async throws -> [Flow.Event.Result] {
            return try await request(Flow.AccessEndpoint.getEventsForBlockIds(type: type, ids: ids))
        }
    }
}
