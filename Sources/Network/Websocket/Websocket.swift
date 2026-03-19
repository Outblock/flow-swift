	//
	//  Websocket.swift
	//  Flow
	//
	//  Created by Hao Fu on 29/4/2025.
	//  Edited for Swift 6 concurrency & actors by Nicholas Reich on 2026-03-19.
	//

import Foundation
import Combine
import Starscream

public extension Flow {
	final class Websocket: NSObject {
		private var socket: WebSocket?
		private var isConnected = false
		private var subscriptions: [String: (subject: PassthroughSubject<Any, Error>, type: Any.Type)] = [:]
		private var cancellables = Set<AnyCancellable>()
		private var timeoutInterval: TimeInterval = 10
		private let connectionSubject = PassthroughSubject<Void, Never>()
		private var isConnecting: Bool = false
		public var isDebug: Bool = false

		private var decoder: JSONDecoder {
			let dateFormatter = DateFormatter()
				// eg. 2022-06-22T15:32:09.08595992Z
			dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS'Z'"
			dateFormatter.locale = Locale(identifier: "en_US_POSIX")
			dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .formatted(dateFormatter)
			decoder.keyDecodingStrategy = .convertFromSnakeCase
			return decoder
		}

		private var encoder: JSONEncoder {
			let encoder = JSONEncoder()
			encoder.keyEncodingStrategy = .convertToSnakeCase
			return encoder
		}

		private let url: URL

		public init(url: URL, timeoutInterval: TimeInterval = 30, isDebug: Bool = false) {
			self.url = url
			self.timeoutInterval = timeoutInterval
			self.isDebug = isDebug
			super.init()
		}

		public convenience init?(
			chainID: Flow.ChainID,
			timeoutInterval: TimeInterval = 30,
			isDebug: Bool = false
		) {
			guard let node = chainID.defaultWebSocketNode, let url = node.url else { return nil }
			self.init(url: url, timeoutInterval: timeoutInterval, isDebug: isDebug)
		}

		public func connect() {
			guard !isConnected && !isConnecting else { return }
			isConnecting = true
			var request = URLRequest(url: url)
			request.timeoutInterval = timeoutInterval
			socket = WebSocket(request: request)
			socket?.delegate = self
			socket?.connect()
		}

		public func disconnect() {
			socket?.disconnect()
			socket = nil
			isConnected = false
			subscriptions.forEach { $0.value.subject.send(completion: .finished) }
			subscriptions.removeAll()
			cancellables.removeAll()
			Flow.Publisher.shared.publishConnectionStatus(isConnected: false)
		}

			// MARK: - Subscription Methods

		@discardableResult
		public func subscribeToBlockDigests(
			blockStatus: BlockStatus = .sealed,
			startBlockHeight: String? = nil,
			startBlockId: String? = nil
		) -> AnyPublisher<Flow.Websocket.TopicResponse<Flow.WSBlockHeader>, Error> {
			let arguments = BlockDigestArguments(
				blockStatus: blockStatus,
				startBlockHeight: startBlockHeight,
				startBlockId: startBlockId
			)

			return subscribe(topic: .blockDigests, arguments: arguments, type: Flow.WSBlockHeader.self)
				.map { payload in
					TopicResponse(
						subscriptionId: payload.subscriptionId,
						topic: payload.topic,
						payload: payload.payload,
						error: payload.error
					)
				}
				.eraseToAnyPublisher()
		}

		@discardableResult
		public func subscribeToBlockHeaders()
		-> AnyPublisher<Flow.Websocket.TopicResponse<Flow.BlockHeader>, Error> {
			subscribe(topic: .blockHeaders, arguments: EmptyArguments(), type: Flow.BlockHeader.self)
		}

		@discardableResult
		public func subscribeToBlocks()
		-> AnyPublisher<Flow.Websocket.TopicResponse<Flow.Block>, Error> {
			subscribe(topic: .blocks, arguments: EmptyArguments(), type: Flow.Block.self)
		}

		@discardableResult
		public func subscribeToEvents(
			type: String? = nil,
			contractID: String? = nil,
			address: String? = nil
		) -> AnyPublisher<Flow.Websocket.TopicResponse<Flow.Event>, Error> {
			let arguments = EventArguments(type: type, contractID: contractID, address: address)
			return subscribe(topic: .events, arguments: arguments, type: Flow.Event.self)
		}

		@discardableResult
		public func subscribeToAccountStatuses(
			request: AccountArguments
		) -> AnyPublisher<Flow.Websocket.TopicResponse<Flow.Websocket.AccountStatusResponse>, Error> {
			let publisher = subscribe(
				topic: .accountStatuses,
				arguments: request,
				type: Flow.Websocket.AccountStatusResponse.self
			)

				// Also publish to central publisher for account updates
			publisher
				.compactMap { $0.payload }
				.sink(
					receiveCompletion: { _ in },
					receiveValue: { response in
						let addresses = response.accountEvents.keys.compactMap {
							try? Flow.Address(hex: $0)
						}
						addresses.forEach {
							Flow.Publisher.shared.publishAccountUpdate(address: $0)
						}
					}
				)
				.store(in: &cancellables)

			return publisher
		}

		@discardableResult
		public func subscribeToTransactionStatus(
			txId: Flow.ID
		) -> AnyPublisher<Flow.Websocket.TopicResponse<Flow.WSTransactionResponse>, Error> {
			let arguments = TransactionStatusRequest(txId: txId.hex)
			let publisher = subscribe(
				topic: .transactionStatuses,
				arguments: arguments,
				type: Flow.WSTransactionResponse.self
			)

				// Also publish transaction status updates to central publisher
			publisher
				.sink(
					receiveCompletion: { _ in },
					receiveValue: { response in
						if let status = response.payload {
							Flow.Publisher.shared.publishTransactionStatus(
								id: txId,
								status: status.transactionResult
							)
						}
					}
				)
				.store(in: &cancellables)

			return publisher
		}

		public func listSubscriptions() {
			let request = SubscribeRequest<EmptyArguments>(
				id: generateShortUUID(),
				action: .listSubscriptions,
				topic: .blocks,
				arguments: nil
			)
			do {
				let data = try encoder.encode(request)
				socket?.write( data)
			} catch {
				Flow.Publisher.shared.publishError(error)
			}
		}

		private func subscribe<T: Encodable & Sendable, U: Decodable & Sendable>(
			topic: Topic,
			arguments: T,
			type: U.Type
		) -> AnyPublisher<TopicResponse<U>, Error> {
			let subscriptionId = generateShortUUID()
			let request = SubscribeRequest(
				id: subscriptionId,
				action: .subscribe,
				topic: topic,
				arguments: arguments
			)
			let subject = PassthroughSubject<Any, Error>()
			subscriptions[subscriptionId] = (subject: subject, type: TopicResponse<U>.self)

				// If not connected or connecting, initiate connection
			if !isConnected && !isConnecting {
				connect()
			}

				// Wait for connection, then send the request
			connectedPublisher
				.sink { [weak self] in
					guard let self = self else { return }
					do {
						let data = try self.encoder.encode(request)
						self.socket?.write( data)
					} catch {
						subject.send(completion: .failure(error))
						self.subscriptions.removeValue(forKey: subscriptionId)
						Flow.Publisher.shared.publishError(error)
					}
				}
				.store(in: &cancellables)

			return subject
				.compactMap { value -> TopicResponse<U>? in
					value as? TopicResponse<U>
				}
				.eraseToAnyPublisher()
		}

		public func unsubscribe(subscriptionId: String) {
			let request = SubscribeRequest<EmptyArguments>(
				id: subscriptionId,
				action: .unsubscribe,
				topic: .blocks,
				arguments: nil
			)
			do {
				let data = try encoder.encode(request)
				socket?.write( data)
				subscriptions[subscriptionId]?.subject.send(completion: .finished)
				subscriptions.removeValue(forKey: subscriptionId)
			} catch {
				print("Error unsubscribing: \(error)")
				Flow.Publisher.shared.publishError(error)
			}
		}

			// Helper method to generate short UUIDs
		private func generateShortUUID() -> String {
				// Generate UUID and take first 20 characters
			let fullUUID = UUID().uuidString
			return String(fullUUID.prefix(20))
		}

		private var connectedPublisher: AnyPublisher<Void, Never> {
			if isConnected {
					// Immediately emit if already connected
				return Just(()).eraseToAnyPublisher()
			} else {
					// Wait for the next connection event
				return connectionSubject.prefix(1).eraseToAnyPublisher()
			}
		}

			// MARK: - Message handling

		private func handleTextMessage(_ text: String) {
			guard let data = text.data(using: .utf8) else { return }
			handleBinaryMessage(data)
		}

		private func handleBinaryMessage(_  Data) {
			do {
					// Try to decode as a SubscribeResponse
				if let response = try? decoder.decode(SubscribeResponse.self, from: data) {
					if let error = response.error {
						let wsError = WebSocketError.serverError(error)
						subscriptions[response.subscriptionId]?.subject
							.send(completion: .failure(wsError))
						Flow.Publisher.shared.publishError(wsError)
					}
					return
				}

					// Try to decode as a ListSubscriptionsResponse
				if let response = try? decoder.decode(ListSubscriptionsResponse.self, from: data) {
					if isDebug {
						print("Active subscriptions: \(response.subscriptions)")
					}
					return
				}

				if isDebug {
					let object = try JSONSerialization.jsonObject(with: data)
					print(object)
				}

					// Directly decode using the TopicResponse.self type stored at subscription time
				if let anyResponse = try? decoder.decode(TopicResponse<AnyDecodable>.self, from: data),
				   let subscription = subscriptions[anyResponse.subscriptionId],
				   let decodableType = subscription.type as? Decodable.Type {
					do {
						let decoded = try decoder.decode(decodableType, from: data)
						subscription.subject.send(decoded)
					} catch {
						subscription.subject.send(completion: .failure(error))
						Flow.Publisher.shared.publishError(error)
					}
					return
				}
			} catch {
				print("Error decoding message: \(error)")
				Flow.Publisher.shared.publishError(error)
			}
		}
	}
}

	// MARK: - WebSocketDelegate

extension Flow.Websocket: WebSocketDelegate {
	public func didReceive(event: WebSocketEvent, client: WebSocket) {
		switch event {
			case .connected:
				isConnected = true
				isConnecting = false
				connectionSubject.send(())
				Flow.Publisher.shared.publishConnectionStatus(isConnected: true)

			case let .disconnected(_, _):
				isConnected = false
				isConnecting = false
				Flow.Publisher.shared.publishConnectionStatus(isConnected: false)

			case let .text(text):
				handleTextMessage(text)

			case let .binary(data):
				handleBinaryMessage(data)

			default:
				break
		}
	}
}

