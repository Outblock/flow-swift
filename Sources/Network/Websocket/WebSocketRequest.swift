	//
	//  WebSocketRequest.swift
	//  Flow
	//
	//  Created by Hao Fu on 30/4/2025.
	//  Edited for Swift 6 concurrency & actors by Nicholas Reich on 2026-03-19.
	//

import Foundation

public extension Flow {

		// MARK: - WebSocket transaction response / bridge

	struct WSTransactionResponse: Decodable, Sendable {
		public let status: Flow.Transaction.Status
		public let statusCode: Int
		public let errorMessage: String?
		public let blockId: String?
		public let computationUsed: String?
		public let events: [Flow.Event]

		private enum CodingKeys: String, CodingKey {
			case status
			case statusCode = "status_code"
			case errorMessage = "error_message"
			case blockId = "block_id"
			case computationUsed = "computation_used"
			case events
		}

			/// Bridge to the public `TransactionResult` model.
		public func asTransactionResult() throws -> Flow.TransactionResult {
				// Require a block id – this should always be present once the
				// transaction has reached a meaningful state.
			guard let blockIdHex = blockId else {
				throw Flow.FError.customError(msg: "Missing block_id in WebSocket transaction result")
			}

			let id = Flow.ID(hex: blockIdHex)
			let used = computationUsed ?? "0"

			return Flow.TransactionResult(
				status: status,
				errorMessage: errorMessage ?? "",
				events: events,
				statusCode: statusCode,
				blockId: id,
				computationUsed: used
			)
		}
	}

		/// Convenience namespace for WebSocket-specific helpers.
	enum WebSocketRequest {
			/// Convert a raw `WSTransactionResponse` (as decoded from WebSocket JSON)
			/// into the canonical `Flow.TransactionResult`.
			///
			/// This keeps all JSON-shape knowledge at the edge of the system while
			/// the rest of the SDK works only with `TransactionResult`.
		static func makeTransactionResult(from ws: Flow.WSTransactionResponse) throws -> Flow.TransactionResult {
			try ws.asTransactionResult()
		}
	}

		// MARK: - Block / account streaming types

		/// Block status used in websocket arguments.
	enum WebSocketBlockStatus: String, Codable, Sendable {
		case finalized
		case sealed
	}

		/// Transaction status request arguments (`transaction_statuses` topic).
	struct WebSocketTransactionStatusRequest: Encodable, Sendable {
		public let txId: String

		private enum CodingKeys: String, CodingKey {
			case txId = "tx_id"
		}

		public init(txId: String) {
			self.txId = txId
		}
	}

		/// Block digests arguments (for `blocks` / `block_digests` topics).
	struct WebSocketBlockDigestArguments: Encodable, Sendable {
		public let blockStatus: WebSocketBlockStatus
		public let startBlockHeight: String?
		public let startBlockId: String?

		private enum CodingKeys: String, CodingKey {
			case blockStatus = "block_status"
			case startBlockHeight = "start_block_height"
			case startBlockId = "start_block_id"
		}

		public init(
			blockStatus: WebSocketBlockStatus,
			startBlockHeight: String? = nil,
			startBlockId: String? = nil
		) {
			self.blockStatus = blockStatus
			self.startBlockHeight = startBlockHeight
			self.startBlockId = startBlockId
		}
	}

		/// Account status response for account-specific streaming topics.
	struct WebSocketAccountStatusResponse: Codable, Sendable {
		public let blockId: String
		public let height: String
		public let accountEvents: [String: [WebSocketAccountStatusEvent]]

		private enum CodingKeys: String, CodingKey {
			case blockId = "block_id"
			case height
			case accountEvents = "account_events"
		}

		public init(
			blockId: String,
			height: String,
			accountEvents: [String: [WebSocketAccountStatusEvent]]
		) {
			self.blockId = blockId
			self.height = height
			self.accountEvents = accountEvents
		}
	}

		/// Single account status event, matching the WebSocket event shape.
	struct WebSocketAccountStatusEvent: Codable, Sendable {
		public let type: String
		public let transactionId: String
		public let transactionIndex: String
		public let eventIndex: String
		public let payload: String

		private enum CodingKeys: String, CodingKey {
			case type
			case transactionId = "transaction_id"
			case transactionIndex = "transaction_index"
			case eventIndex = "event_index"
			case payload
		}

		public init(
			type: String,
			transactionId: String,
			transactionIndex: String,
			eventIndex: String,
			payload: String
		) {
			self.type = type
			self.transactionId = transactionId
			self.transactionIndex = transactionIndex
			self.eventIndex = eventIndex
			self.payload = payload
		}
	}
}
