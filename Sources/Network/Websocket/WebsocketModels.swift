	//
	//  WebsocketModels.swift
	//  Flow
	//
	//  Created by Hao Fu on 29/4/2025.
	//  Edited for Swift 6 concurrency & actors by Nicholas Reich on 2026-03-19.
	//

import Foundation

public extension Flow {

		/// High-level websocket topics used by the Flow access node.
	enum WebSocketTopic: String, Codable, Sendable {
		case blockDigests = "block_digests"
		case blockHeaders = "block_headers"
		case blocks = "blocks"
		case events = "events"
		case accountStatuses = "account_statuses"
		case transactionStatuses = "transaction_statuses"
		case sendAndGetTransactionStatuses = "send_and_get_transaction_statuses"
	}

		/// Websocket action verbs.
	enum WebSocketAction: String, Codable, Sendable {
		case subscribe = "subscribe"
		case unsubscribe = "unsubscribe"
		case listSubscriptions = "list_subscriptions"
	}

		/// Generic subscribe request for Flow websocket.
	struct WebSocketSubscribeRequest<Arguments: Encodable & Sendable>: Encodable, Sendable {
		public let id: String?
		public let action: WebSocketAction
		public let topic: WebSocketTopic?
		public let arguments: Arguments?

		enum CodingKeys: String, CodingKey {
			case id = "subscription_id"
			case action
			case topic
			case arguments
		}

		public init(
			id: String?,
			action: WebSocketAction,
			topic: WebSocketTopic?,
			arguments: Arguments?
		) {
			self.id = id
			self.action = action
			self.topic = topic
			self.arguments = arguments
		}
	}

		/// Response to a subscribe/unsubscribe/list request.
	struct WebSocketSubscribeResponse: Decodable, Sendable {
		public let subscriptionId: String
		public let action: WebSocketAction
		public let error: WebSocketSocketError?
	}

		/// Error payload from websocket.
	struct WebSocketSocketError: Codable, Sendable {
		public let code: Int
		public let message: String
	}

		/// Topic response carrying typed payload `T`.
	struct WebSocketTopicResponse<T: Decodable & Sendable>: Decodable, Sendable {
		public let subscriptionId: String
		public let topic: WebSocketTopic
		public let payload: T?
		public let error: WebSocketSocketError?
	}
}
