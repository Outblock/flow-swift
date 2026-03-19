	//
	//  WebsocketModels.swift
	//  Flow
	//
	//  Created by Hao Fu on 29/4/2025.
	//  Edited for Swift 6 concurrency & actors by Nicholas Reich on 2026-03-19.
	//

import Foundation

extension Flow.Websocket {
	public enum Action: String, Codable, Sendable {
		case subscribe = "subscribe"
		case unsubscribe = "unsubscribe"
		case listSubscriptions = "list_subscriptions"
	}

	public enum Topic: String, Codable, Sendable {
		case blockDigests = "block_digests"
		case blockHeaders = "block_headers"
		case blocks = "blocks"
		case events = "events"
		case accountStatuses = "account_statuses"
		case transactionStatuses = "transaction_statuses"
		case sendAndGetTransactionStatuses = "send_and_get_transaction_statuses"
	}

	public struct SubscribeRequest<T: Encodable & Sendable>: Encodable, Sendable {
		public let id: String?
		public let action: Action
		public let topic: Topic?
		public let arguments: T?

		enum CodingKeys: String, CodingKey {
			case id = "subscription_id"
			case action
			case topic
			case arguments
		}

		public init(
			id: String?,
			action: Action,
			topic: Topic?,
			arguments: T?
		) {
			self.id = id
			self.action = action
			self.topic = topic
			self.arguments = arguments
		}
	}

	public struct SubscribeResponse: Decodable, Sendable {
		public let subscriptionId: String
		public let action: Action
		public let error: SocketError?
	}

	public struct SocketError: Codable, Sendable {
		public let code: Int
		public let message: String
	}

	public struct TopicResponse<T: Decodable & Sendable>: Decodable, Sendable {
		public let subscriptionId: String
		public let topic: Topic
		public let payload: T?
		public let error: SocketError?
	}

	public struct ListSubscriptionsResponse: Decodable, Sendable {
		public let subscriptions: [SubscriptionInfo]
	}

	public struct SubscriptionInfo: Decodable, Sendable {
		public let id: String
		public let topic: Topic
		public let arguments: AnyDecodable?
	}
}
