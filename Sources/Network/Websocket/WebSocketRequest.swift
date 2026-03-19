	//
	//  WebSocketRequest.swift
	//  Flow
	//
	//  Created by Hao Fu on 30/4/2025.
	//  Edited for Swift 6 concurrency & actors by Nicholas Reich on 2026-03-19.
	//

import Foundation

extension Flow.Websocket {
	public enum BlockStatus: String, Codable, Sendable {
		case finalized
		case sealed
	}

	struct TransactionStatusRequest: Encodable, Sendable {
		let txId: String

		enum CodingKeys: String, CodingKey {
			case txId = "tx_id"
		}
	}

	struct BlockDigestArguments: Encodable, Sendable {
		let blockStatus: BlockStatus
		let startBlockHeight: String?
		let startBlockId: String?

		init(
			blockStatus: BlockStatus,
			startBlockHeight: String? = nil,
			startBlockId: String? = nil
		) {
			self.blockStatus = blockStatus
			self.startBlockHeight = startBlockHeight
			self.startBlockId = startBlockId
		}
	}

	public struct AccountStatusResponse: Codable, Sendable {
		public let blockId: String
		public let height: String
		public let accountEvents: [String: [AccountStatusEvent]]

		public init(
			blockId: String,
			height: String,
			accountEvents: [String: [AccountStatusEvent]]
		) {
			self.blockId = blockId
			self.height = height
			self.accountEvents = accountEvents
		}
	}

	public struct AccountStatusEvent: Codable, Sendable {
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
