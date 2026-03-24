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
	//  Edited for Swift 6 concurrency & actors by Nicholas Reich on 2026-03-19.
	//

import Foundation

	// Central actors used by Flow facade.
public enum FlowActors {
	static let access = FlowAccessActor.shared
	static let websocket = FlowWebSocketCenter.shared
	static let config = FlowConfigActor.shared
	static let crypto = FlowCryptoActor.shared
}

	// MARK: - Flow core type

	/// Namespace and main entrypoint for Flow SDK.
	/// Public async APIs delegate to concurrency-safe actors.
public final class Flow: @unchecked Sendable {

		// Legacy singleton for API compatibility; internals are actor-backed.
	public static let shared = Flow()

		/// The user agent for the SDK client, used in access API header.
	public let defaultUserAgent = userAgent

		/// Contract address registry (value type, safe to share).
	public var addressRegister: ContractAddressRegister = .init()

	public var encoder: JSONEncoder {
		let encoder = JSONEncoder()
		encoder.outputFormatting = .sortedKeys
		return encoder
	}

	public var decoder: JSONDecoder {
		let decoder = JSONDecoder()
		return decoder
	}

		/// Private init; use Flow.shared.
	public init() {}

		// MARK: - Config

		/// Current chain ID (reads from FlowConfigActor).
	public var chainID: ChainID {
		get async { await FlowActors.config.chainID }
	}

		/// Configure chainID; will recreate the HTTP access client by default.
	public func configure(chainID: ChainID) async {
		await FlowAccessActor.shared.configure(chainID: chainID, accessAPI: nil)
	}

		/// Configure chainID and a custom accessAPI implementation.
	public func configure(chainID: ChainID, accessAPI: FlowAccessProtocol) async {
		await FlowAccessActor.shared.configure(chainID: chainID, accessAPI: accessAPI)
	}

		/// Create an HTTP access API client by chainID (non-cached).
	public func createHTTPAccessAPI(chainID: ChainID) -> FlowAccessProtocol {
		FlowHTTPAPI(chainID: chainID)
	}

		// MARK: - Access API facade

		/// Current FlowAccessProtocol client (from actor).
	public var accessAPI: FlowAccessProtocol {
		get async { await FlowActors.access.currentClient() }
	}
}

// MARK: - High-level helpers (actor-isolated facade)

@FlowActor
public extension Flow {

		/// Get notified when transaction's status changed.
		/// - Parameters:
		///   - transactionId: Transaction ID in Flow.ID format.
		///   - status: The status you want to monitor.
		///   - timeout: Timeout in seconds, default 60.
	func once(
		_ transactionId: Flow.ID,
		status: Flow.Transaction.Status,
		timeout: TimeInterval = 60
	) async throws -> Flow.TransactionResult {
		try await transactionId.once(status: status, timeout: timeout)
	}

		/// Get notified when transaction's status change to `.finalized`.
	func onceFinalized(_ transactionId: Flow.ID) async throws -> Flow.TransactionResult {
		try await once(transactionId, status: .finalized)
	}

		/// Get notified when transaction's status change to `.executed`.
	func onceExecuted(_ transactionId: Flow.ID) async throws -> Flow.TransactionResult {
		try await once(transactionId, status: .executed)
	}

		/// Get notified when transaction's status change to `.sealed`.
	func onceSealed(_ transactionId: Flow.ID) async throws -> Flow.TransactionResult {
		try await once(transactionId, status: .sealed)
	}

		/// Validate whether an address exists on a given network using an HTTP client.
	func isAddressVaildate(
		address: Flow.Address,
		network: Flow.ChainID = .mainnet
	) async -> Bool {
		do {
			let accessAPI = createHTTPAccessAPI(chainID: network)
			_ = try await accessAPI.getAccountAtLatestBlock(address: address)
			return true
		} catch {
			return false
		}
	}
}



//// MARK: - Flow core type
//
///// The namespace and class for `Flow`
///// Singleton-like class managed by `FlowActor`.
//public final class Flow: @unchecked Sendable {
//	// If you still want a traditional singleton for legacy API, keep this:
//	public static let shared = Flow()
//
//		/// The user agent for the SDK client, used in access API header
//	internal let defaultUserAgent = userAgent
//
//		/// The chainID for the SDK environment, it can be changed by config.
//		/// The default value is `.mainnet`.
//	public private(set) var chainID = ChainID.mainnet
//
//		/// The access API client
//	public private(set) var accessAPI: FlowAccessProtocol
//
//		/// WebSocket client for Flow
//	public private(set) var websocket: Flow.Websocket!
//
//		/// Contract address registry
//	public var addressRegister: ContractAddressRegister = .init()
//
//	internal var encoder: JSONEncoder {
//		let encoder = JSONEncoder()
//		encoder.outputFormatting = .sortedKeys
//		return encoder
//	}
//
//	internal var decoder: JSONDecoder {
//		let decoder = JSONDecoder()
//		return decoder
//	}
//
//		/// Default access client will be HTTP Client
//	public init() {
//		self.accessAPI = FlowHTTPAPI(chainID: chainID)
//		self.websocket = Flow.Websocket()
//	}
//
//		// MARK: - AccessAPI configuration
//
//		/// Config the chainID for Flow Swift SDK.
//		/// Default access client will be HTTP Client.
//		///
//		/// For using default node:
//		/// ```swift
//		/// await FlowActor.shared.flow.configure(chainID: .testnet)
//		/// ```
//		///
//		/// For custom node:
//		/// ```swift
//		/// let endpoint = Flow.ChainID.Endpoint(node: "flow-testnet.g.alchemy.com", port: 443)
//		/// let chainID = Flow.ChainID.custom(name: "Alchemy-Testnet", endpoint: endpoint)
//		/// await FlowActor.shared.flow.configure(chainID: chainID)
//		/// ```
//	public func configure(chainID: ChainID) {
//		self.chainID = chainID
//		self.accessAPI = createHTTPAccessAPI(chainID: chainID)
//		self.websocket = Flow.Websocket()
//	}
//
//		/// Config the chainID and accessNode for Flow Swift SDK.
//		///
//		/// For using default node:
//		/// ```swift
//		/// await FlowActor.shared.flow.configure(chainID: .testnet)
//		/// ```
//		///
//		/// For custom node:
//		/// ```swift
//		/// let accessAPI = Flow.GRPCAccessAPI(chainID: .mainnet)!
//		/// let chainID = Flow.ChainID.mainnet
//		/// await FlowActor.shared.flow.configure(chainID: chainID, accessAPI: accessAPI)
//		/// ```
//	public func configure(chainID: ChainID, accessAPI: FlowAccessProtocol) {
//		self.chainID = chainID
//		self.accessAPI = accessAPI
//	}
//
//		/// Create an HTTP access API client by chainID.
//		///
//		/// For using default node:
//		/// ```swift
//		/// let client = FlowActor.shared.flow.createHTTPAccessAPI(chainID: .testnet)
//		/// ```
//		///
//		/// For custom node:
//		/// ```swift
//		/// let endpoint = Flow.ChainID.Endpoint(node: "flow-testnet.g.alchemy.com", port: 443)
//		/// let chainID = Flow.ChainID.custom(name: "Alchemy-Testnet", endpoint: endpoint)
//		/// let client = FlowActor.shared.flow.createHTTPAccessAPI(chainID: chainID)
//		/// ```
//	public func createHTTPAccessAPI(chainID: ChainID) -> FlowAccessProtocol {
//		FlowHTTPAPI(chainID: chainID)
//	}
//}

// MARK: - High-level helpers (actor-isolated)

//@FlowActor
//public extension Flow {
//	/// Get notified when transaction's status changed.
//	/// - Parameters:
//	///   - transactionId: Transaction ID in Flow.ID format
//	///   - status: The status you want to monitor.
//	///   - timeout: Timeout for this request. Default is 60 seconds.
//	/// - Returns: The `Flow.TransactionResult` value once condition is met.
//	func once(
//	_ transactionId: Flow.ID,
//	status: Flow.Transaction.Status,
//	timeout: TimeInterval = 60
//	) async throws -> Flow.TransactionResult {
//		try await transactionId.once(status: status, timeout: timeout)
//	}
//
//		/// Get notified when transaction's status change to `.finalized`.
//	func onceFinalized(_ transactionId: Flow.ID) async throws -> Flow.TransactionResult {
//		try await once(transactionId, status: .finalized)
//	}
//
//		/// Get notified when transaction's status change to `.executed`.
//	func onceExecuted(_ transactionId: Flow.ID) async throws -> Flow.TransactionResult {
//		try await once(transactionId, status: .executed)
//	}
//
//		/// Get notified when transaction's status change to `.sealed`.
//	func onceSealed(_ transactionId: Flow.ID) async throws -> Flow.TransactionResult {
//		try await once(transactionId, status: .sealed)
//	}
//
//		/// Validate whether an address exists on a given network using an HTTP client.
//	func isAddressVaildate(
//		address: Flow.Address,
//		network: Flow.ChainID = .mainnet
//	) async -> Bool {
//		do {
//			let accessAPI = createHTTPAccessAPI(chainID: network)
//			_ = try await accessAPI.getAccountAtLatestBlock(address: address)
//			return true
//		} catch {
//			return false
//		}
//	}
//}
