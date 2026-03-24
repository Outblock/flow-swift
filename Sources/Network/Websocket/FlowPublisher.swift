import Foundation
import Combine

public extension Flow {

		/// Events produced by Flow’s websocket / access APIs.
	enum PublisherEvent {
		case transactionStatus(id: Flow.ID, status: Flow.TransactionResult)
		case accountUpdate(address: Flow.Address)
		case connectionStatus(isConnected: Bool)
		case walletResponse(approved: Bool, [String: Any])
		case block(id: Flow.ID, height: String, timestamp: Date)
		case error(Error)
	}

		/// Central publisher manager for Flow events (Combine-based).
	@FlowWebsocketActor
	final class Publisher {

		static let shared = Publisher()

		private let eventSubject = PassthroughSubject<PublisherEvent, Never>()

		private let walletResponseSubject =
		PassthroughSubject<(approved: Bool, [String: String]), Never>()

			// MARK: - Typed publishers

		public var transactionPublisher:
		AnyPublisher<(Flow.ID, Flow.TransactionResult), Never> {
			eventSubject
				.compactMap { event -> (Flow.ID, Flow.TransactionResult)? in
					if case let .transactionStatus(id, status) = event {
						return (id, status)
					}
					return nil
				}
				.eraseToAnyPublisher()
		}

		public var accountPublisher: AnyPublisher<Flow.Address, Never> {
			eventSubject
				.compactMap { event -> Flow.Address? in
					if case let .accountUpdate(address) = event {
						return address
					}
					return nil
				}
				.eraseToAnyPublisher()
		}

		public struct WSBlockHeader {
			public let blockId: Flow.ID
			public let height: String
			public let timestamp: Date
		}

		public var blockPublisher: AnyPublisher<WSBlockHeader, Never> {
			eventSubject
				.compactMap { event -> WSBlockHeader? in
					if case let .block(id, height, timestamp) = event {
						return WSBlockHeader(blockId: id, height: height, timestamp: timestamp)
					}
					return nil
				}
				.eraseToAnyPublisher()
		}

		public var connectionPublisher: AnyPublisher<Bool, Never> {
			eventSubject
				.compactMap { event -> Bool? in
					if case let .connectionStatus(isConnected) = event {
						return isConnected
					}
					return nil
				}
				.eraseToAnyPublisher()
		}

		public var walletResponsePublisher:
		AnyPublisher<(approved: Bool, [String: Any]), Never> {
			eventSubject
				.compactMap { event -> (approved: Bool, [String: Any])? in
					if case let .walletResponse(approved, data) = event {
						return (approved, data)
					}
					return nil
				}
				.eraseToAnyPublisher()
		}

		public var errorPublisher: AnyPublisher<Error, Never> {
			eventSubject
				.compactMap { event -> Error? in
					if case let .error(error) = event {
						return error
					}
					return nil
				}
				.eraseToAnyPublisher()
		}

			// MARK: - Init

		private init() { }

			// MARK: - Publish helpers

		public func publish(_ event: PublisherEvent) {
			eventSubject.send(event)
		}

		public func publishTransactionStatus(id: Flow.ID, status: Flow.TransactionResult) {
			publish(.transactionStatus(id: id, status: status))
		}

		public func publishAccountUpdate(address: Flow.Address) {
			publish(.accountUpdate(address: address))
		}

		public func publishConnectionStatus(isConnected: Bool) {
			publish(.connectionStatus(isConnected: isConnected))
		}

		public func publishWalletResponse(approved: Bool,data:  [String: Any]) {
			publish(.walletResponse(approved: approved, data))
		}

		public func publishError(_ error: Error) {
			publish(.error(error))
		}
	}
}

@FlowWebsocketActor
public extension Flow {
	var publisher: Publisher {
		Publisher.shared
	}
}
