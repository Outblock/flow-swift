	//
	//  FlowWebSocketCenter.swift
	//  Flow
	//
	//  Created by Nicholas Reich on 3/21/26.
	//

import Foundation

	/// A key that uniquely identifies a subscription within the websocket center.
public struct FlowWebSocketSubscriptionKey: Hashable, Sendable {
	public let topic: String
	public let id: String

	public init(topic: String, id: String) {
		self.topic = topic
		self.id = id
	}
}

/// Central NIO-based websocket coordination actor.
public actor FlowWebSocketCenter {
	public static let shared = FlowWebSocketCenter()

	private let nioClient: FlowNIOWebSocketClient

		// Transaction status streams: txID → continuation.
	private var transactionSubscriptions: [
		Flow.ID: AsyncThrowingStream<
		Flow.WebSocketTopicResponse<Flow.WSTransactionResponse>,
		Error
		>.Continuation
	] = [:]

	public init(nioClient: FlowNIOWebSocketClient? = nil) {
		self.nioClient = nioClient ?? FlowNIOWebSocketClient()
	}

		// MARK: - Connection

	public func connectIfNeeded() async throws {
		try await nioClient.connectIfNeeded()
	}

	public func disconnect() async {
		await nioClient.disconnect()
	}

		// MARK: - Transaction status stream

	public func transactionStatusStream(
		for id: Flow.ID
	) async throws -> AsyncThrowingStream<
		Flow.WebSocketTopicResponse<Flow.WSTransactionResponse>,
		Error
	> {
		try await connectIfNeeded()

			// If already subscribed, fail the new stream immediately.
		if transactionSubscriptions[id] != nil {
			return AsyncThrowingStream { continuation in
				continuation.finish(
					throwing: Flow.FError.customError(
						msg: "Multiple streams per ID not yet supported for \(id)"
					)
				)
			}
		}

		return AsyncThrowingStream { continuation in
			transactionSubscriptions[id] = continuation

			continuation.onTermination = { [weak self] _ in
				_Concurrency.Task {
					await self?.removeTransactionSubscription(for: id)
				}
			}

			_Concurrency.Task {
				await self.nioClient.sendTransactionStatusSubscribe(id: id)
			}
		}
	}

	private func removeTransactionSubscription(for id: Flow.ID) {
		transactionSubscriptions[id] = nil
	}

		// MARK: - Called by frame handler

	public func handleTransactionStatusMessage(
		_ response: Flow.WebSocketTopicResponse<Flow.WSTransactionResponse>
	) async {
			// Expect subscriptionId to encode txId at the end (e.g. "tx:<hex>")
		let parts = response.subscriptionId.split(separator: ":")
		guard let last = parts.last else { return }
		let hex = String(last)
		let txId = Flow.ID(hex: hex)

		guard let continuation = transactionSubscriptions[txId] else { return }
		continuation.yield(response)
	}

	public func finishTransactionStatus(
		id: Flow.ID,
		error: Error? = nil
	) {
		guard let continuation = transactionSubscriptions[id] else { return }
		if let error {
			continuation.finish(throwing: error)
		} else {
			continuation.finish()
		}
		transactionSubscriptions[id] = nil
	}
}
