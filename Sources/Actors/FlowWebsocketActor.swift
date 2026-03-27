	//
	//  FlowWebsocketActor.swift
	//  Flow
	//
	//  Created by Nicholas Reich on 3/22/26.
	//  Modernized to delegate to FlowWebSocketCenter (NIO) while using
	//  Swift Concurrency (AsyncStream) instead of Combine.
	//

import Foundation

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

		/// Websocket façade that delegates to FlowWebSocketCenter + NIO
		/// and exposes AsyncStream-based APIs.
	actor Websocket {

			// MARK: State (facade)

		private var isConnected = false

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

			// MARK: - Transaction status subscription via FlowWebSocketCenter

			/// Async stream of raw topic responses for a given transaction ID.
			/// Also fan-outs high-level events via `Flow.Publisher`.
		public func subscribeToTransactionStatus(
			txId: Flow.ID
		) async throws -> AsyncThrowingStream<TopicResponse<Flow.WSTransactionResponse>, Error> {
			let upstream = try await FlowWebSocketCenter.shared
				.transactionStatusStream(for: txId)

			return AsyncThrowingStream { continuation in
				_Concurrency.Task { [weak self] in
					guard let self else { return }
					do {
						for try await event in upstream {
							guard let payload = event.payload else { continue }

							let txResult = try payload.asTransactionResult()

								// Publish high-level transaction status via Flow.Publisher
							await Flow.shared.publisher.publishTransactionStatus(
								id: txId,
								status: txResult
							)

								// Forward the raw topic response for low-level consumers
							continuation.yield(
								TopicResponse(
									subscriptionId: event.subscriptionId,
									payload: payload
								)
							)
						}

						continuation.finish()
					} catch {
						await self.sendError(error)
						continuation.finish(throwing: error)
					}
				}
			}
		}

			/// Convenience helper to build streams for multiple transaction IDs.
		@FlowWebsocketActor
		public static func subscribeToManyTransactionStatuses(
			txIds: [Flow.ID]
		) async throws -> [Flow.ID: AsyncThrowingStream<TopicResponse<Flow.WSTransactionResponse>, Error>] {
			var result: [Flow.ID: AsyncThrowingStream<TopicResponse<Flow.WSTransactionResponse>, Error>] = [:]

			for id in txIds {
				let stream = try await FlowWebsocketActor.shared.websocket
					.subscribeToTransactionStatus(txId: id)
				result[id] = stream
			}

			return result
		}

			// MARK: - Helpers

		private func setConnected(_ status: Bool) async {
			isConnected = status
			await Flow.shared.publisher.publishConnectionStatus(isConnected: status)
		}

		private func sendError(_ error: Error) async {
			await Flow.shared.publisher.publishError(error)
		}
	}
}

// MARK: - Models (unchanged public API surface)

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

	struct TopicResponse<T: Decodable & Sendable>: Decodable, Sendable{
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
