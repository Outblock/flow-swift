//
//  Flow.swift
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

/// Global variable to access the singleton of `Flow`
public let flow = Flow.shared

/// The namespace and class for `Flow`
/// Singleton class to make the class more accessible in global scope
/// Please use `flow` to access to its singleton entity.
public final class Flow {
    /// Singleton object for `Flow` class
    public static let shared = Flow()

    /// The user agent for the SDK client, used in access API header
    internal let defaultUserAgent = userAgent

    /// The chainID for the SDK environment, it be be changed by config func.
    /// The default value is `.mainnet`.
    public private(set) var chainID = ChainID.mainnet

    /// The access API client
    public private(set) var accessAPI: FlowAccessProtocol
    
    public var addressRegister: ContractAddressRegister = .init()

    internal var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return encoder
    }
    
    internal var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        return decoder
    }
    
    /// Default access client will be HTTP Client
    init() {
        accessAPI = FlowHTTPAPI(chainID: chainID)
    }

    // MARK: - AccessAPI

    /// Config the chainID for Flow Swift SDK
    /// Default access client will be HTTP Client
    /// - parameters:
    ///     - chainID: The chain id to be configured.
    ///
    ///
    /// For using default node:
    /// ```
    ///     flow.configure(chainID: .testnet)
    /// ```
    ///
    /// For custom node:
    /// ```
    ///     let endpoint = Flow.ChainID.Endpoint(node: "flow-testnet.g.alchemy.com", port: 443)
    ///     let chainID = Flow.ChainID.custom(name: "Alchemy-Testnet", endpoint:endpoint)
    ///     flow.configure(chainID: chainID)
    /// ```
    ///
    public func configure(chainID: ChainID) {
        self.chainID = chainID
        accessAPI = createHTTPAccessAPI(chainID: chainID)
    }

    /// Config the chainID and accessNode for Flow Swift SDK
    /// - parameters:
    ///     - chainID: The chain id to be configured.
    ///
    ///
    /// For using default node:
    /// ```
    ///     flow.configure(chainID: .testnet)
    /// ```
    ///
    /// For custom node:
    /// ```
    ///     let accessAPI = Flow.GRPCAccessAPI(chainID: .mainnet)!
    ///     let chainID = Flow.ChainID.mainnet
    ///     flow.configure(chainID: chainID, accessAPI: accessAPI)
    /// ```
    ///
    public func configure(chainID: ChainID, accessAPI: FlowAccessProtocol) {
        self.chainID = chainID
        self.accessAPI = accessAPI
    }

    /// Create an access API client of `Access` by chainID
    /// - parameters:
    ///     - chainID: The chain id to determine which gRPC node to connect.
    /// - returns: An `AccessAPI` client
    ///
    /// For using default node:
    /// ```
    ///     let client = flow.createAccessAPI(chainID: .testnet)
    /// ```
    ///
    /// For custom node:
    /// ```
    ///     let endpoint = Flow.ChainID.Endpoint(node: "flow-testnet.g.alchemy.com", port: 443)
    ///     let chainID = Flow.ChainID.custom(name: "Alchemy-Testnet", endpoint:endpoint)
    ///     let client = flow.createAccessAPI(chainID: chainID)
    /// ```
    ///
    public func createHTTPAccessAPI(chainID: ChainID) -> FlowAccessProtocol {
        return FlowHTTPAPI(chainID: chainID)
    }
}

extension Flow {
    /// Get notified when transaction's status changed.
    /// - parameters:
    ///     - transactionId: Transaction ID in Flow.ID format
    ///     - status: The status you want to monitor.
    ///     - delay: Interval between two queries. Default is 2 seconds.
    ///     - timeout: Timeout for this request. Default is 60 seconds.
    /// - returns: A future that will receive the `Flow.TransactionResult` value.
    func once(_ transactionId: Flow.ID,
              status: Flow.Transaction.Status,
              timeout: TimeInterval = 60) async throws -> Flow.TransactionResult
    {
        return try await transactionId.once(status: status, timeout: timeout)
    }

    /// Get notified when transaction's status change to `.finalized`.
    /// - parameters:
    ///     - transactionId: Transaction ID in Flow.ID format
    /// - returns: A future that will receive the `Flow.TransactionResult` value.
    func onceFinalized(_ transactionId: Flow.ID) async throws -> Flow.TransactionResult {
        return try await once(transactionId, status: .finalized)
    }

    /// Get notified when transaction's status change to `.executed`.
    /// - parameters:
    ///     - transactionId: Transaction ID in Flow.ID format
    /// - returns: A future that will receive the `Flow.TransactionResult` value.
    func onceExecuted(_ transactionId: Flow.ID) async throws -> Flow.TransactionResult {
        return try await once(transactionId, status: .executed)
    }

    /// Get notified when transaction's status change to `.sealed`.
    /// - parameters:
    ///     - transactionId: Transaction ID in Flow.ID format
    /// - returns: A future that will receive the `Flow.TransactionResult` value.
    func onceSealed(_ transactionId: Flow.ID) async throws -> Flow.TransactionResult {
        return try await once(transactionId, status: .sealed)
    }
    
    func isAddressVaildate(address: Flow.Address, network: Flow.ChainID = .mainnet) async -> Bool {
        do {
            let accessAPI = flow.createHTTPAccessAPI(chainID: network)
            _ = try await accessAPI.getAccountAtLatestBlock(address: address)
            return true
        } catch {
            return false
        }
    }
}
