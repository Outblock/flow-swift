	//
	//  FlowTransport.swift
	//  Flow
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

public extension Flow {

		/// Endpoint / transport description for Flow access nodes.
	enum Transport: Equatable, Hashable, Sendable {
		case HTTP(_ url: URL)
		case gRPC(_ endpoint: Endpoint)
		case websocket(_ url: URL)

		public var url: URL? {
			switch self {
				case let .HTTP(url):
					return url
				case .gRPC:
					return nil
				case let .websocket(url):
					return url
			}
		}

		public var gRPCEndpoint: Endpoint? {
			switch self {
				case .HTTP:
					return nil
				case let .gRPC(endpoint):
					return endpoint
				case .websocket:
					return nil
			}
		}

		public static func == (lhs: Flow.Transport, rhs: Flow.Transport) -> Bool {
			switch (lhs, rhs) {
				case let (.HTTP(lhsValue), .HTTP(rhsValue)):
					return lhsValue == rhsValue
				case let (.gRPC(lhsValue), .gRPC(rhsValue)):
					return lhsValue == rhsValue
				default:
					return false
			}
		}

			/// Endpoint information for a gRPC node.
		public struct Endpoint: Hashable, Equatable, Sendable {
			public let node: String
			public let port: Int?

			public init(node: String, port: Int? = nil) {
				self.node = node
				self.port = port
			}
		}
	}
}

// MARK: - Strongly-typed RPC request payloads

public extension Flow {

		/// Request for `getAccountAtLatestBlock`.
	struct AccountAtLatestBlockRequest: Encodable {
		public let address: Flow.Address
		public let blockStatus: Flow.BlockStatus

		public init(address: Flow.Address, blockStatus: Flow.BlockStatus = .final) {
			self.address = address
			self.blockStatus = blockStatus
		}
	}

		/// Request for `getAccountByBlockHeight`.
	struct AccountByBlockHeightRequest: Encodable {
		public let address: Flow.Address
		public let height: UInt64

		public init(address: Flow.Address, height: UInt64) {
			self.address = address
			self.height = height
		}
	}

		/// Request for `executeScriptAtLatestBlock`.
	struct ExecuteScriptAtLatestBlockRequest: Encodable {
		public let script: Flow.Script
		public let arguments: [Flow.Argument]
		public let blockStatus: Flow.BlockStatus

		public init(
			script: Flow.Script,
			arguments: [Flow.Argument],
			blockStatus: Flow.BlockStatus = .final
		) {
			self.script = script
			self.arguments = arguments
			self.blockStatus = blockStatus
		}
	}

		/// Request for `executeScriptAtBlockId`.
	struct ExecuteScriptAtBlockIdRequest: Encodable {
		public let script: Flow.Script
		public let blockId: Flow.ID
		public let arguments: [Flow.Argument]

		public init(
			script: Flow.Script,
			blockId: Flow.ID,
			arguments: [Flow.Argument]
		) {
			self.script = script
			self.blockId = blockId
			self.arguments = arguments
		}
	}

		/// Request for `executeScriptAtBlockHeight`.
	struct ExecuteScriptAtBlockHeightRequest: Encodable {
		public let script: Flow.Script
		public let height: UInt64
		public let arguments: [Flow.Argument]

		public init(
			script: Flow.Script,
			height: UInt64,
			arguments: [Flow.Argument]
		) {
			self.script = script
			self.height = height
			self.arguments = arguments
		}
	}

		/// Request for `getEventsForHeightRange`.
	struct EventsForHeightRangeRequest: Encodable {
		public let type: String
		public let range: ClosedRange<UInt64>

		public init(type: String, range: ClosedRange<UInt64>) {
			self.type = type
			self.range = range
		}
	}

		/// Request for `getEventsForBlockIds`.
	struct EventsForBlockIdsRequest: Encodable {
		public let type: String
		public let ids: Set<Flow.ID>

		public init(type: String, ids: Set<Flow.ID>) {
			self.type = type
			self.ids = ids
		}
	}
}

// MARK: - RPC transport abstraction (additive, no breaking changes)

/// RPC methods supported by the transport layer.
/// This is used internally by concrete access clients.
public enum FlowRPCMethod: Sendable {
	case ping
	case getLatestBlockHeader
	case getBlockHeaderById
	case getBlockHeaderByHeight
	case getLatestBlock
	case getBlockById
	case getBlockByHeight
	case getCollectionById
	case sendTransaction
	case getTransactionById
	case getTransactionResultById
	case getAccountAtLatestBlock
	case getAccountByBlockHeight
	case executeScriptAtLatestBlock
	case executeScriptAtBlockId
	case executeScriptAtBlockHeight
	case getEventsForHeightRange
	case getEventsForBlockIds
	case getNetworkParameters
	// Extend as needed (e.g. latest protocol state snapshot).
}

/// Abstract transport for Flow access nodes (HTTP/gRPC/etc.).
/// Concrete implementations (e.g. `NIOTransport`) conform to this.
/// This does not change any existing public Flow APIs; it is used under the hood.
public protocol FlowTransport: Sendable {
	func executeRPC<Request: Encodable, Response: Decodable>(
	_ method: FlowRPCMethod,
	request: Request
	) async throws -> Response
}

// MARK: - NIO-based transport delegating to FlowHTTPAPI

/// Temporary NIO-based transport.
/// Currently delegates all RPCs to `FlowHTTPAPI` so behavior matches the HTTP client.
/// You can progressively move implementations to a true NIO HTTP/gRPC client.
public struct NIOTransport: FlowTransport {

		/// Underlying actor-based HTTP API client.
	private let httpAPI: FlowHTTPAPI

	public init(chainID: Flow.ChainID) {
		self.httpAPI = FlowHTTPAPI(chainID: chainID)
	}

	public func executeRPC<Request, Response>(
		_ method: FlowRPCMethod,
		request: Request
	) async throws -> Response where Request: Encodable, Response: Decodable {
		switch method {

			case .ping:
				let result = try await httpAPI.ping()
				return try cast(result, as: Response.self, method: method)

			case .getLatestBlockHeader:
				guard let status = request as? Flow.BlockStatus else {
					throw invalidRequest(method, expected: Flow.BlockStatus.self, got: Request.self)
				}
				let result = try await httpAPI.getLatestBlockHeader(blockStatus: status)
				return try cast(result, as: Response.self, method: method)

			case .getBlockHeaderById:
				guard let id = request as? Flow.ID else {
					throw invalidRequest(method, expected: Flow.ID.self, got: Request.self)
				}
				let result = try await httpAPI.getBlockHeaderById(id: id)
				return try cast(result, as: Response.self, method: method)

			case .getBlockHeaderByHeight:
				guard let height = request as? UInt64 else {
					throw invalidRequest(method, expected: UInt64.self, got: Request.self)
				}
				let result = try await httpAPI.getBlockHeaderByHeight(height: height)
				return try cast(result, as: Response.self, method: method)

			case .getLatestBlock:
				guard let status = request as? Flow.BlockStatus else {
					throw invalidRequest(method, expected: Flow.BlockStatus.self, got: Request.self)
				}
				let result = try await httpAPI.getLatestBlock(blockStatus: status)
				return try cast(result, as: Response.self, method: method)

			case .getBlockById:
				guard let id = request as? Flow.ID else {
					throw invalidRequest(method, expected: Flow.ID.self, got: Request.self)
				}
				let result = try await httpAPI.getBlockById(id: id)
				return try cast(result, as: Response.self, method: method)

			case .getBlockByHeight:
				guard let height = request as? UInt64 else {
					throw invalidRequest(method, expected: UInt64.self, got: Request.self)
				}
				let result = try await httpAPI.getBlockByHeight(height: height)
				return try cast(result, as: Response.self, method: method)

			case .getCollectionById:
				guard let id = request as? Flow.ID else {
					throw invalidRequest(method, expected: Flow.ID.self, got: Request.self)
				}
				let result = try await httpAPI.getCollectionById(id: id)
				return try cast(result, as: Response.self, method: method)

			case .sendTransaction:
				guard let tx = request as? Flow.Transaction else {
					throw invalidRequest(method, expected: Flow.Transaction.self, got: Request.self)
				}
				let result = try await httpAPI.sendTransaction(transaction: tx)
				return try cast(result, as: Response.self, method: method)

			case .getTransactionById:
				guard let id = request as? Flow.ID else {
					throw invalidRequest(method, expected: Flow.ID.self, got: Request.self)
				}
				let result = try await httpAPI.getTransactionById(id: id)
				return try cast(result, as: Response.self, method: method)

			case .getTransactionResultById:
				guard let id = request as? Flow.ID else {
					throw invalidRequest(method, expected: Flow.ID.self, got: Request.self)
				}
				let result = try await httpAPI.getTransactionResultById(id: id)
				return try cast(result, as: Response.self, method: method)

			case .getAccountAtLatestBlock:
				guard let req = request as? Flow.AccountAtLatestBlockRequest else {
					throw invalidRequest(method, expected: Flow.AccountAtLatestBlockRequest.self, got: Request.self)
				}
				let result = try await httpAPI.getAccountAtLatestBlock(
					address: req.address,
					blockStatus: req.blockStatus
				)
				return try cast(result, as: Response.self, method: method)

			case .getAccountByBlockHeight:
				guard let req = request as? Flow.AccountByBlockHeightRequest else {
					throw invalidRequest(method, expected: Flow.AccountByBlockHeightRequest.self, got: Request.self)
				}
				let result = try await httpAPI.getAccountByBlockHeight(
					address: req.address,
					height: req.height
				)
				return try cast(result, as: Response.self, method: method)

			case .executeScriptAtLatestBlock:
				guard let req = request as? Flow.ExecuteScriptAtLatestBlockRequest else {
					throw invalidRequest(method, expected: Flow.ExecuteScriptAtLatestBlockRequest.self, got: Request.self)
				}
				let result = try await httpAPI.executeScriptAtLatestBlock(
					script: req.script,
					arguments: req.arguments,
					blockStatus: req.blockStatus
				)
				return try cast(result, as: Response.self, method: method)

			case .executeScriptAtBlockId:
				guard let req = request as? Flow.ExecuteScriptAtBlockIdRequest else {
					throw invalidRequest(method, expected: Flow.ExecuteScriptAtBlockIdRequest.self, got: Request.self)
				}
				let result = try await httpAPI.executeScriptAtBlockId(
					script: req.script,
					blockId: req.blockId,
					arguments: req.arguments
				)
				return try cast(result, as: Response.self, method: method)

			case .executeScriptAtBlockHeight:
				guard let req = request as? Flow.ExecuteScriptAtBlockHeightRequest else {
					throw invalidRequest(
						method,
						expected: Flow.ExecuteScriptAtBlockHeightRequest.self,
						got: Request.self
					)
				}
				let result = try await httpAPI.executeScriptAtBlockHeight(
					script: req.script,
					height: req.height,
					arguments: req.arguments
				)
				return try cast(result, as: Response.self, method: method)

			case .getEventsForHeightRange:
				guard let req = request as? Flow.EventsForHeightRangeRequest else {
					throw invalidRequest(method, expected: Flow.EventsForHeightRangeRequest.self, got: Request.self)
				}
				let result = try await httpAPI.getEventsForHeightRange(
					type: req.type,
					range: req.range
				)
				return try cast(result, as: Response.self, method: method)

			case .getEventsForBlockIds:
				guard let req = request as? Flow.EventsForBlockIdsRequest else {
					throw invalidRequest(method, expected: Flow.EventsForBlockIdsRequest.self, got: Request.self)
				}
				let result = try await httpAPI.getEventsForBlockIds(
					type: req.type,
					ids: req.ids
				)
				return try cast(result, as: Response.self, method: method)

			case .getNetworkParameters:
				let result = try await httpAPI.getNetworkParameters()
				return try cast(result, as: Response.self, method: method)
		}
	}

		// MARK: - Helpers

	private func cast<Response>(
		_ value: Any,
		as type: Response.Type,
		method: FlowRPCMethod
	) throws -> Response {
		guard let typed = value as? Response else {
			throw Flow.FError.customError(
				msg: "Unexpected response type \(Swift.type(of: value)) for RPC method \(method)"
			)
		}
		return typed
	}

	private func invalidRequest<Request>(
		_ method: FlowRPCMethod,
		expected: Any.Type,
		got: Request.Type
	) -> Flow.FError {
		.customError(
			msg: "Invalid request type \(got) for RPC method \(method); expected \(expected)"
		)
	}
}
