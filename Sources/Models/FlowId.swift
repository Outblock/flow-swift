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

			/// Create an ID from a hex string (with or without `"0x"` prefix).
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
			// `hex` comes from `FlowEntity` default implementation.
		try container.encode(self.hex)
	}
}

// MARK: - CustomStringConvertible

extension Flow.ID: CustomStringConvertible {
	public var description: String {
		hex
	}
}

// MARK: - Concurrency helpers (wait for transaction status)

	// FlowId.swift

import Foundation

public extension Flow.ID {

		/// Wait for this transaction to reach at least the given status.
		///
		/// Uses FlowWebSocketCenter and an AsyncSequence of status updates,
		/// and fails if no matching status is observed within `timeout` seconds.
	func once(
		status desiredStatus: Flow.Transaction.Status,
		timeout: TimeInterval = 60
	) async throws -> Flow.TransactionResult {
			// Stream of TopicResponse<WSTransactionResponse>
		let stream = try await FlowWebSocketCenter.shared
			.transactionStatusStream(for: self)

		return try await withThrowingTaskGroup(of: Flow.TransactionResult.self) { group in
				// Task 1: read from websocket until we reach the desired status
			group.addTask {
				for try await event in stream {
					guard let wsPayload = event.payload else { continue }
					let result = wsPayload.transactionResult
					let currentStatus = result.status

					if currentStatus.rawValue >= desiredStatus.rawValue {
						return result
					}
				}

				throw Flow.FError.customError(
					msg: "No matching transactionResult found for transaction ID \(self.hex)"
				)
			}

				// Task 2: enforce timeout
			group.addTask {
				try await Task.sleep(
					nanoseconds: UInt64(timeout * 1_000_000_000)
				)
				throw Flow.FError.customError(
					msg: "Timeout waiting for transaction status update for \(self.hex)"
				)
			}

			guard let firstFinished = try await group.next() else {
				group.cancelAll()
				throw Flow.FError.customError(
					msg: "Task group finished without result for transaction ID \(self.hex)"
				)
			}

			group.cancelAll()
			return firstFinished
		}
	}

		/// Wait for many transactions to reach at least the given status in parallel.
	static func onceMany(
		ids: [Flow.ID],
		status: Flow.Transaction.Status,
		timeout: TimeInterval = 60
	) async throws -> [Flow.ID: Flow.TransactionResult] {
		try await withThrowingTaskGroup(of: (Flow.ID, Flow.TransactionResult).self) { group in
			for id in ids {
				group.addTask {
					let result = try await id.once(status: status, timeout: timeout)
					return (id, result)
				}
			}

			var results: [Flow.ID: Flow.TransactionResult] = [:]
			for try await (id, result) in group {
				results[id] = result
			}
			return results
		}
	}
}
