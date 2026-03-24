	//
	//  FlowWebsocketActor.swift
	//  Flow
	//
	//  Created by Nicholas Reich on 3/22/26.
	//  Modernized to delegate to FlowWebSocketCenter (NIO) while preserving
	//  the legacy Flow.Websocket + Combine API surface.
	//

import Foundation
@preconcurrency import Combine

	// MARK: - Global Websocket Actor

@globalActor
public actor FlowWebsocketActor {
	public static let shared = FlowWebsocketActor()

	public let websocket: Flow.Websocket

	public init() {
		self.websocket = Flow.Websocket()
	}
}

// MARK: - Websocket actor façade

public extension Flow {

		/// Legacy-style websocket façade that preserves the old API shape
		/// but delegates to FlowWebSocketCenter + NIO.
	@preconcurrency
	actor Websocket {

			// MARK: State (facade)

		private var isConnected = false

		private struct SubscriptionInfo {
			let id: String
			let topic: Topic
			let subject: Any
		}

		private var subscriptions: [String: SubscriptionInfo] = [:]

		private let connectionSubject = PassthroughSubject<Bool, Never>()
		private let accountUpdateSubject = PassthroughSubject<Flow.Address, Never>()
		private let transactionStatusSubject =
		PassthroughSubject<(Flow.ID, Flow.TransactionStatus), Never>()
		private let errorSubject = PassthroughSubject<Error, Never>()
		private let walletResponseSubject =
		PassthroughSubject<(approved: Bool, [String: String]), Never>()

		public init() {}

			// MARK: - Connection (delegates to FlowWebSocketCenter / NIO)

		public func connect(to url: URL) {
			_Concurrency.Task { [weak self] in
				guard let self else { return }
				do {
					try await FlowWebSocketCenter.shared.connectIfNeeded()
					await self.setConnected(true)
				} catch {
					await self.sendError(error)
				}
			}
		}

		public func disconnect() {
			_Concurrency.Task { [weak self] in
				guard let self else { return }
				await FlowWebSocketCenter.shared.disconnect()
				await self.setConnected(false)
			}
		}

			// MARK: - Legacy message handling helpers (still usable by tests)

		private func handleTextMessage(_ text: String) async {
			guard let data = text.data(using: .utf8) else { return }
			await handleBinaryMessage(data)
		}

		private func handleBinaryMessage(_ data: Data) async {
			let decoder = JSONDecoder()

			if let subscribeResponse = try? decoder.decode(SubscribeResponse.self, from: data) {
				if let error = subscribeResponse.error {
					errorSubject.send(WebSocketError.serverError(error))
				}
				return
			}

			if let anyResponse = try? decoder.decode(
				TopicResponse<AnyDecodable>.self,
				from: data
			),
			   let subscription = subscriptions[anyResponse.subscriptionId],
			   let subject = subscription.subject
				as? PassthroughSubject<TopicResponse<AnyDecodable>, Error> {
				subject.send(anyResponse)
			}
		}

			// MARK: - Subscription (single) via FlowWebSocketCenter

		public func subscribeToTransactionStatus(
			txId: Flow.ID
		) -> AnyPublisher<TopicResponse<Flow.WSTransactionResponse>, Error> {
			let subject = PassthroughSubject<TopicResponse<Flow.WSTransactionResponse>, Error>()
			let topic = Topic.transactionStatus(txId: txId)
			let subscriptionId = "transactionStatus:\(txId.hex)"

			subscriptions[subscriptionId] = SubscriptionInfo(
				id: subscriptionId,
				topic: topic,
				subject: subject
			)

			_Concurrency.Task { [weak self] in
				guard let self else { return }
				do {
					let stream = try await FlowWebSocketCenter.shared
						.transactionStatusStream(for: txId)

					for try await event in stream {
						await transactionStatusSubject.send((
							txId,
							event.payload?.transactionResult.status ?? .unknown
						))

						subject.send(
							TopicResponse(
								subscriptionId: event.subscriptionId,
								payload: event.payload
							)
						)
					}
					subject.send(completion: .finished)
				} catch {
					subject.send(completion: .failure(error))
					await self.sendError(error)
				}
			}

			return subject.eraseToAnyPublisher()
		}

			// MARK: - Subscription (batch via TaskGroup)

		@FlowWebsocketActor
		public static func subscribeToManyTransactionStatuses(
			txIds: [Flow.ID]
		) async throws -> [Flow.ID: AnyPublisher<TopicResponse<Flow.WSTransactionResponse>, Error>] {
			var result: [Flow.ID: AnyPublisher<TopicResponse<Flow.WSTransactionResponse>, Error>] = [:]

			try await withThrowingTaskGroup(
				of: (Flow.ID, AnyPublisher<TopicResponse<Flow.WSTransactionResponse>, Error>).self
			) { group in
				for id in txIds {
					group.addTask {
						let publisher = await FlowWebsocketActor.shared.websocket
							.subscribeToTransactionStatus(txId: id)
						return (id, publisher)
					}
				}

				for try await (id, publisher) in group {
					result[id] = publisher
				}
			}

			return result
		}

			// MARK: - Helpers

		private func setConnected(_ status: Bool) async {
			isConnected = status
			connectionSubject.send(status)
		}

		private func sendError(_ error: Error) async {
			errorSubject.send(error)
		}
	}
}

// MARK: - Models (unchanged public API)

public extension Flow {
	struct Topic: RawRepresentable, Sendable {
		public let rawValue: String

		public init(rawValue: String) {
			self.rawValue = rawValue
		}

		public static func transactionStatus(txId: Flow.ID) -> Topic {
			Topic(rawValue: "transactionStatus:\(txId.hex)")
		}
	}

	struct TopicResponse<T: Decodable>: Decodable {
		public let subscriptionId: String
		public let payload: T?
	}

	struct SubscribeResponse: Decodable {
		public struct ErrorBody: Decodable, Sendable {
			public let message: String
			public let code: Int?
		}

		public let id: String
		public let error: ErrorBody?
	}

	enum WebSocketError: Error {
		case serverError(SubscribeResponse.ErrorBody)
	}
}
