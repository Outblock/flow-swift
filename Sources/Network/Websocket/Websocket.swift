//
//  File.swift
//  Flow
//
//  Created by Hao Fu on 29/4/2025.
//

import Foundation
import Combine
import Starscream

public extension Flow {
    final class Websocket {
        private var socket: WebSocket?
        private var isConnected = false
        private var subscriptions: [String: (subject: PassthroughSubject<Any, Error>, type: Any.Type)] = [:]
        private var cancellables = Set<AnyCancellable>()
        
        private let decoder = JSONDecoder()
        private let encoder = JSONEncoder()
        
        private let url: URL
        
        public init(url: URL, timeoutInterval: TimeInterval = 10) {
            self.url = url
        }
        
        convenience init?(chainID: Flow.ChainID, timeoutInterval: TimeInterval = 10) {
            guard let node = chainID.defaultWebSocketNode, let url = node.url else { return nil }
            self.init(url: url, timeoutInterval: timeoutInterval)
        }
        
        public func connect() {
            var request = URLRequest(url: url)
            request.timeoutInterval = 5
            
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
        
        public func subscribeToBlockDigests() -> AnyPublisher<Flow.BlockHeader, Error> {
            return subscribe(topic: .blockDigests, arguments: EmptyArguments(), type: Flow.BlockHeader.self)
        }
        
        public func subscribeToBlockHeaders() -> AnyPublisher<Flow.BlockHeader, Error> {
            return subscribe(topic: .blockHeaders, arguments: EmptyArguments(), type: Flow.BlockHeader.self)
        }
        
        public func subscribeToBlocks() -> AnyPublisher<Flow.Block, Error> {
            return subscribe(topic: .blocks, arguments: EmptyArguments(), type: Flow.Block.self)
        }
        
        public func subscribeToEvents(type: String? = nil, contractID: String? = nil, address: String? = nil) -> AnyPublisher<Flow.Event, Error> {
            let arguments = EventArguments(type: type, contractID: contractID, address: address)
            return subscribe(topic: .events, arguments: arguments, type: Flow.Event.self)
        }
        
        public func subscribeToAccountStatuses(address: String) -> AnyPublisher<Flow.Account, Error> {
            let arguments = AccountArguments(address: address)
            let publisher = subscribe(topic: .accountStatuses, arguments: arguments, type: Flow.Account.self)
            
            // Also publish to central publisher for account updates
            Flow.Publisher.shared.publishAccountUpdate(address: Flow.Address(hex: address))
            
            return publisher
        }
        
        public func subscribeToTransactionStatus(txId: Flow.ID) -> AnyPublisher<Flow.Transaction.Status, Error> {
            let arguments = TransactionStatusRequest(txId: txId.hex)
            let publisher = subscribe(topic: .transactionStatuses, arguments: arguments, type: Flow.Transaction.Status.self)
            
            // Also publish transaction status updates to central publisher
            publisher.sink(
                receiveCompletion: { _ in },
                receiveValue: { status in
                    Flow.Publisher.shared.publishTransactionStatus(id: txId, status: status)
                }
            ).store(in: &cancellables)
            
            return publisher
        }
        
//        public func sendAndSubscribeToTransactionStatus(transaction: Flow.Transaction) -> AnyPublisher<Flow.Transaction.Status, Error> {
//            let arguments = SendTransactionArguments(transaction: transaction)
//            let publisher = subscribe(topic: .sendAndGetTransactionStatuses, arguments: arguments, type: Flow.Transaction.Status.self)
//            
//            // Also publish transaction status updates to central publisher
//            publisher.sink(
//                receiveCompletion: { _ in },
//                receiveValue: { status in
//                    Flow.Publisher.shared.publishTransactionStatus(id: transaction., status: status)
//                }
//            ).store(in: &cancellables)
//            
//            return publisher
//        }
        
        public func listSubscriptions() {
            let request = SubscribeRequest<EmptyArguments>(id: UUID().uuidString, action: .listSubscriptions, topic: .blocks, arguments: nil)
            do {
                let data = try encoder.encode(request)
                socket?.write(data: data)
            } catch {
                Flow.Publisher.shared.publishError(error)
            }
        }
        
        private func subscribe<T: Encodable, U: Decodable>(topic: Topic, arguments: T, type: U.Type) -> AnyPublisher<U, Error> {
            let subscriptionId = UUID().uuidString
            let request = SubscribeRequest(id: subscriptionId, action: .subscribe, topic: topic, arguments: arguments)
            
            let subject = PassthroughSubject<Any, Error>()
            subscriptions[subscriptionId] = (subject: subject, type: U.self)
            
            do {
                let data = try encoder.encode(request)
                socket?.write(data: data)
            } catch {
                subject.send(completion: .failure(error))
                subscriptions.removeValue(forKey: subscriptionId)
                Flow.Publisher.shared.publishError(error)
            }
            
            return subject
                .compactMap { value -> U? in
                    return value as? U
                }
                .eraseToAnyPublisher()
        }
        
        public func unsubscribe(subscriptionId: String) {
            let request = SubscribeRequest<EmptyArguments>(id: subscriptionId, action: .unsubscribe, topic: .blocks, arguments: nil)
            do {
                let data = try encoder.encode(request)
                socket?.write(data: data)
                subscriptions[subscriptionId]?.subject.send(completion: .finished)
                subscriptions.removeValue(forKey: subscriptionId)
            } catch {
                print("Error unsubscribing: \(error)")
                Flow.Publisher.shared.publishError(error)
            }
        }
    }
}

// MARK: - WebSocketDelegate

extension Flow.Websocket: WebSocketDelegate {
    public func didReceive(event: WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
        case .connected(_):
            isConnected = true
            Flow.Publisher.shared.publishConnectionStatus(isConnected: true)
            
        case .disconnected(_, _):
            isConnected = false
            Flow.Publisher.shared.publishConnectionStatus(isConnected: false)
            
        case .text(let string):
            handleTextMessage(string)
            
        case .binary(let data):
            handleBinaryMessage(data)
            
        case .error(let error):
            print("WebSocket error: \(String(describing: error))")
            let wsError = WebSocketError.serverError(SocketError(code: -1, message: error?.localizedDescription ?? "Unknown error"))
            subscriptions.values.forEach { $0.subject.send(completion: .failure(wsError)) }
            Flow.Publisher.shared.publishError(wsError)
            
        default:
            break
        }
    }
    
    private func handleTextMessage(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }
        handleBinaryMessage(data)
    }
    
    private func handleBinaryMessage(_ data: Data) {
        do {
            // Try to decode as a SubscribeResponse
            if let response = try? decoder.decode(SubscribeResponse.self, from: data) {
                if let error = response.error {
                    let wsError = WebSocketError.serverError(error)
                    subscriptions[response.id]?.subject.send(completion: .failure(wsError))
                    Flow.Publisher.shared.publishError(wsError)
                }
                return
            }
            
            // Try to decode as a ListSubscriptionsResponse
            if let response = try? decoder.decode(ListSubscriptionsResponse.self, from: data) {
                print("Active subscriptions: \(response.subscriptions)")
                return
            }
            
            // Try to decode as a TopicResponse with different types
            let response = try decoder.decode(TopicResponse<AnyDecodable>.self, from: data)
            guard let subscription = subscriptions[response.id] else { return }
            
            if let error = response.error {
                let wsError = WebSocketError.serverError(error)
                subscription.subject.send(completion: .failure(wsError))
                Flow.Publisher.shared.publishError(wsError)
                return
            }
            
            guard let anyData = response.data else { return }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: anyData.value)
                if let decodableType = subscription.type as? Decodable.Type {
                    let decodedData = try decoder.decode(decodableType, from: jsonData)
                    subscription.subject.send(decodedData)
                }
            } catch {
                subscription.subject.send(completion: .failure(error))
                Flow.Publisher.shared.publishError(error)
            }
        } catch {
            print("Error decoding message: \(error)")
            Flow.Publisher.shared.publishError(error)
        }
    }
}

// MARK: - Supporting Types

extension Flow.Websocket {
    enum WebSocketError: Error {
        case serverError(SocketError)
    }
    
    struct EmptyArguments: Codable {}
    
    struct EventArguments: Codable {
        let type: String?
        let contractID: String?
        let address: String?
    }
    
    struct AccountArguments: Codable {
        let address: String
    }
    
    struct SendTransactionArguments: Codable {
        let transaction: Flow.Transaction
    }
}
