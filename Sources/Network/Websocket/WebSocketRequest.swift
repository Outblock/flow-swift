	//
	//  WebSocketRequest.swift
	//  Flow
	//
	//  Created by Hao Fu on 30/4/2025.
	//  Edited for Swift 6 concurrency & actors by Nicholas Reich on 2026-03-19.
	//

import Foundation

public extension Flow {
	struct WSTransactionResponse: Decodable, Sendable {
		public let transactionResult: WSTransactionResult
	}

	struct WSTransactionResult: Decodable, Sendable {
			/// Use the core Transaction.Status enum instead of a duplicate websocket enum.
		public let status: Transaction.Status
	}
}

// If your core Transaction.Status type is not yet Sendable/Codable, you can
// ensure that here (or in its original declaration file):
//
// public extension Flow.Transaction.Status: Codable, Sendable {}

public extension Flow {

		/// Block status used in websocket arguments.
	enum WebSocketBlockStatus: String, Codable, Sendable {
		case finalized
		case sealed
	}

		/// Transaction status request arguments.
	struct WebSocketTransactionStatusRequest: Encodable, Sendable {
		public let txId: String

		enum CodingKeys: String, CodingKey {
			case txId = "tx_id"
		}

		public init(txId: String) {
			self.txId = txId
		}
	}

		/// Block digests arguments.
	struct WebSocketBlockDigestArguments: Encodable, Sendable {
		public let blockStatus: WebSocketBlockStatus
		public let startBlockHeight: String?
		public let startBlockId: String?

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

		/// Account status response.
	struct WebSocketAccountStatusResponse: Codable, Sendable {
		public let blockId: String
		public let height: String
		public let accountEvents: [String: [WebSocketAccountStatusEvent]]

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

		/// Single account status event.
	struct WebSocketAccountStatusEvent: Codable, Sendable {
		public let type: String
		public let transactionId: String
		public let transactionIndex: String
		public let eventIndex: String
		public let payload: String

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
