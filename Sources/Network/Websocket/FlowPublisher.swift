	//
	//  FlowPublisher.swift
	//  Flow
	//
	//  Async event bus for Flow websocket / access APIs.
	//  Converted from Combine-based implementation to AsyncStream
	//  by Nicholas Reich on 2026-03-24.
	//

import Foundation

public extension Flow {

		/// Represents different types of events that can be published
	enum PublisherEvent {
		case transactionStatus(id: Flow.ID, status: Flow.TransactionResult)
		case accountUpdate(address: Flow.Address)
		case connectionStatus(isConnected: Bool)
		case walletResponse(approved: Bool, [String: Any])
		case block(id: Flow.ID, height: String, timestamp: Date)
		case error(Error)
	}

		/// Central publisher manager for Flow events (AsyncStream-based).
	@FlowWebsocketActor
	final class Publisher: @unchecked Sendable {

			// Box type to carry non-Sendable wallet payload across concurrency boundaries.
		final class WalletPayloadBox: @unchecked Sendable {
			let approved: Bool
			let data: [String: Any]

			init(approved: Bool,  data:  [String: Any]) {
				self.approved = approved
				self.data = data
			}
		}

		static let shared = Publisher()

			// MARK: - Continuation registries

		private typealias TxPair = (Flow.ID, Flow.TransactionResult)

		private var transactionContinuations: [UUID: AsyncStream<TxPair>.Continuation] = [:]
		private var accountContinuations: [UUID: AsyncStream<Flow.Address>.Continuation] = [:]
		private var blockContinuations: [UUID: AsyncStream<WSBlockHeader>.Continuation] = [:]
		private var connectionContinuations: [UUID: AsyncStream<Bool>.Continuation] = [:]
		private var walletContinuations: [UUID: AsyncStream<WalletPayloadBox>.Continuation] = [:]
		private var errorContinuations: [UUID: AsyncStream<Error>.Continuation] = [:]

			// Simple block header model used by block streams
		public struct WSBlockHeader: Sendable {
			public let blockId: Flow.ID
			public let height: String
			public let timestamp: Date

			public init(blockId: Flow.ID, height: String, timestamp: Date) {
				self.blockId = blockId
				self.height = height
				self.timestamp = timestamp
			}
		}

			// MARK: - Init

		private init() { }

			// MARK: - Stream factories

		public func transactionStream() -> AsyncStream<(Flow.ID, Flow.TransactionResult)> {
			AsyncStream { continuation in
				let id = UUID()
				_Concurrency.Task { @FlowWebsocketActor in
					self.transactionContinuations[id] = continuation
				}
				continuation.onTermination = { _ in
					_Concurrency.Task { @FlowWebsocketActor in
						self.transactionContinuations[id] = nil
					}
				}
			}
		}

		public func accountStream() -> AsyncStream<Flow.Address> {
			AsyncStream { continuation in
				let id = UUID()
				_Concurrency.Task { @FlowWebsocketActor in
					self.accountContinuations[id] = continuation
				}
				continuation.onTermination = { _ in
					_Concurrency.Task { @FlowWebsocketActor in
						self.accountContinuations[id] = nil
					}
				}
			}
		}

		public func blockStream() -> AsyncStream<WSBlockHeader> {
			AsyncStream { continuation in
				let id = UUID()
				_Concurrency.Task { @FlowWebsocketActor in
					self.blockContinuations[id] = continuation
				}
				continuation.onTermination = { _ in
					_Concurrency.Task { @FlowWebsocketActor in
						self.blockContinuations[id] = nil
					}
				}
			}
		}

		public func connectionStream() -> AsyncStream<Bool> {
			AsyncStream { continuation in
				let id = UUID()
				_Concurrency.Task { @FlowWebsocketActor in
					self.connectionContinuations[id] = continuation
				}
				continuation.onTermination = { _ in
					_Concurrency.Task { @FlowWebsocketActor in
						self.connectionContinuations[id] = nil
					}
				}
			}
		}

			// New wallet stream API: bridges WalletPayloadBox → tuple
		public func walletResponseStream() -> AsyncStream<(approved: Bool, [String: Any])> {
			AsyncStream { continuation in
				let id = UUID()

				_Concurrency.Task { @FlowWebsocketActor in
						// Create inner stream whose continuations we store by UUID
					let inner = AsyncStream<WalletPayloadBox> { innerCont in
						self.walletContinuations[id] = innerCont
						innerCont.onTermination = { _ in
							_Concurrency.Task { @FlowWebsocketActor in
								self.walletContinuations[id] = nil
							}
						}
					}

						// Forward from inner boxes to outer tuple stream
					_Concurrency.Task {
						for await box in inner {
							continuation.yield((box.approved, box.data))
						}
						continuation.finish()
					}
				}

				continuation.onTermination = { _ in
					_Concurrency.Task { @FlowWebsocketActor in
						self.walletContinuations[id] = nil
					}
				}
			}
		}

		public func errorStream() -> AsyncStream<Error> {
			AsyncStream { continuation in
				let id = UUID()
				_Concurrency.Task { @FlowWebsocketActor in
					self.errorContinuations[id] = continuation
				}
				continuation.onTermination = { _ in
					_Concurrency.Task { @FlowWebsocketActor in
						self.errorContinuations[id] = nil
					}
				}
			}
		}

			// MARK: - Publish helpers

		public func publishTransactionStatus(id: Flow.ID, status: Flow.TransactionResult) {
			for continuation in transactionContinuations.values {
				continuation.yield((id, status))
			}
		}

		public func publishAccountUpdate(address: Flow.Address) {
			for continuation in accountContinuations.values {
				continuation.yield(address)
			}
		}

		public func publishConnectionStatus(isConnected: Bool) {
			for continuation in connectionContinuations.values {
				continuation.yield(isConnected)
			}
		}

		public func publishWalletResponse(approved: Bool,  data:  [String: Any]) {
			let box = WalletPayloadBox(approved: approved,  data:  data)
			for continuation in walletContinuations.values {
				continuation.yield(box)
			}
		}

		public func publishBlock(id: Flow.ID, height: String, timestamp: Date) {
			let header = WSBlockHeader(blockId: id, height: height, timestamp: timestamp)
			for continuation in blockContinuations.values {
				continuation.yield(header)
			}
		}

		public func publishError(_ error: Error) {
			for continuation in errorContinuations.values {
				continuation.yield(error)
			}
		}
	}
}

// Extension to Flow for easy access to publisher
@FlowWebsocketActor
public extension Flow {
	var publisher: Publisher {
		Publisher.shared
	}
}
