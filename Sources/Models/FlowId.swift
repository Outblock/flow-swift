	//
	//  FlowId.swift
	//
	//  Based on Outblock/flow-swift ID model,
	//  adapted for Swift 6 concurrency by Nicholas Reich, 2026-03-19.
	//

import Foundation

public extension Flow {

		/// The ID in Flow chain, which can represent a transaction id, block id,
		/// collection id, etc.
	struct ID: FlowEntity, Equatable, Hashable, Sendable {
			/// Raw ID bytes (big-endian).
		public var data: Data

			/// Create an ID from raw bytes.
		public init(data: Data) {
			self.data = data
		}

			/// Create an ID from a hex string (with or without "0x" prefix).
		public init(hex: String) {
			self.data = hex.hexValue.data
		}

			/// Create an ID from an array of bytes.
		public init(bytes: [UInt8]) {
			self.data = bytes.data
		}

			/// Create an ID from a slice of bytes.
		public init(bytes: ArraySlice<UInt8>) {
			self.data = Data(bytes)
		}
	}
}

	// MARK: - Codable (hex string representation)

extension Flow.ID: Codable {
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let hexString = try container.decode(String.self)
		self.init(hex: hexString)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(self.hex)
	}
}

	// MARK: - CustomStringConvertible

extension Flow.ID: CustomStringConvertible {
	public var description: String { hex }
}

	// MARK: - Concurrency helpers (wait for transaction status)

public extension Flow.ID {
	func once(
		status desiredStatus: Flow.Transaction.Status,
		timeout: TimeInterval = 60
	) async throws -> Flow.TransactionResult {

		let stream: AsyncThrowingStream<
			Flow.WebSocketTopicResponse<Flow.WSTransactionResponse>,
			Error
		> = try await FlowWebSocketCenter.shared.transactionStatusStream(for: self)

		return try await withThrowingTaskGroup(
			of: Flow.TransactionResult.self,
			returning: Flow.TransactionResult.self
		) { group in

			group.addTask { () -> Flow.TransactionResult in
				for try await event in stream {
						// NOTE: WebSocketTopicResponse wraps the decoded payload.
						// Your center yields: WebSocketTopicResponse<WSTransactionResponse>
					guard let ws = event.payload else { continue }

					let txResult: Flow.TransactionResult = try ws.asTransactionResult()

					if txResult.status.rawValue >= desiredStatus.rawValue {
						return txResult
					}
				}

				throw Flow.FError.customError(
					msg: "No matching transactionResult found for transaction ID \(self.hex)"
				)
			}

			group.addTask { () -> Flow.TransactionResult in
				try await _Concurrency.Task.sleep(
					nanoseconds: UInt64(timeout * 1_000_000_000)
				)
				throw Flow.FError.customError(
					msg: "Timeout waiting for transaction status update for \(self.hex)"
				)
			}

			guard let first = try await group.next() else {
				group.cancelAll()
				throw Flow.FError.customError(
					msg: "Task group finished without result for transaction ID \(self.hex)"
				)
			}

			group.cancelAll()
			return first
		}
	}
}

