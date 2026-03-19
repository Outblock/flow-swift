	//
	//  WSRequest.swift
	//  Flow
	//
	//  Created by Hao Fu on 6/5/2025.
	//  Edited for Swift 6 concurrency & actors by Nicholas Reich on 2026-03-19.
	//

import Foundation

extension Flow {
	public struct WSBlockHeader: Codable, Sendable {
			/// The identification of block
		public let blockId: ID

			/// The height of block
		public let height: String

			/// The time when the block is created
		public let timestamp: Date
	}

	public struct WSTransactionResponse: Codable, Sendable {
		public let transactionResult: Flow.TransactionResult
	}
}

// MARK: - Supporting Types

extension Flow.Websocket {
	enum WebSocketError: Error, Sendable {
		case serverError(SocketError)
	}

	struct EmptyArguments: Codable, Sendable {}

	struct EventArguments: Codable, Sendable {
		public let type: String?
		public let contractID: String?
		public let address: String?
	}

	public struct AccountArguments: Codable, Sendable {
		public var startBlockId: String? = nil
		public var startBlockHeight: String? = nil
		public var heartbeatInterval: String? = nil
		public var eventTypes: [AccountEventType]? = nil
		public var accountAddresses: [String]? = nil

		public init(
			startBlockId: String? = nil,
			startBlockHeight: String? = nil,
			heartbeatInterval: String? = nil,
			eventTypes: [AccountEventType]? = nil,
			accountAddresses: [String]? = nil
		) {
			self.startBlockId = startBlockId
			self.startBlockHeight = startBlockHeight
			self.heartbeatInterval = heartbeatInterval
			self.eventTypes = eventTypes
			self.accountAddresses = accountAddresses
		}
	}

	struct SendTransactionArguments: Codable, Sendable {
		public let transaction: Flow.Transaction
	}

	public enum AccountEventType: String, Codable, Sendable {
		case accountCreated = "flow.AccountCreated"
		case accountKeyAdded = "flow.AccountKeyAdded"
		case accountKeyRemoved = "flow.AccountKeyRemoved"
		case accountContractAdded = "flow.AccountContractAdded"
		case accountContractUpdated = "flow.AccountContractUpdated"
		case accountContractRemoved = "flow.AccountContractRemoved"
		case inboxValuePublished = "flow.InboxValuePublished"
		case inboxValueUnpublished = "flow.InboxValueUnpublished"
		case inboxValueClaimed = "flow.InboxValueClaimed"
	}
}
