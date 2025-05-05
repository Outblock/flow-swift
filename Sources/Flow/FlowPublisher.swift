import Foundation
import Combine

public extension Flow {
    /// Represents different types of events that can be published
    enum PublisherEvent {
        case transactionStatus(id: Flow.ID, status: Flow.Transaction.Status)
        case accountUpdate(address: Flow.Address)
        case connectionStatus(isConnected: Bool)
        case walletResponse(approved: Bool, data: [String: Any])
        case block(id: Flow.ID, height: String, timestamp: Date)
        case error(Error)
    }
    
    /// Central publisher manager for Flow events
    class Publisher {
        public static let shared = Publisher()
        
        // Main publisher for all events
        private let eventSubject = PassthroughSubject<PublisherEvent, Never>()
        
        // Specific publishers for different event types
        public var transactionPublisher: AnyPublisher<(Flow.ID, Flow.Transaction.Status), Never> {
            eventSubject
                .compactMap { event in
                    if case .transactionStatus(let id, let status) = event {
                        return (id, status)
                    }
                    return nil
                }
                .eraseToAnyPublisher()
        }
        
        public var accountPublisher: AnyPublisher<Flow.Address, Never> {
            eventSubject
                .compactMap { event in
                    if case .accountUpdate(let address) = event {
                        return address
                    }
                    return nil
                }
                .eraseToAnyPublisher()
        }
        
        public var blockPublisher: AnyPublisher<Flow.WSBlockHeader, Never> {
            eventSubject
                .compactMap { event in
                    if case let .block(id, height, timestamp) = event {
                        return WSBlockHeader(blockId: id, height: height, timestamp: timestamp)
                    }
                    return nil
                }
                .eraseToAnyPublisher()
        }
        
        public var connectionPublisher: AnyPublisher<Bool, Never> {
            eventSubject
                .compactMap { event in
                    if case .connectionStatus(let isConnected) = event {
                        return isConnected
                    }
                    return nil
                }
                .eraseToAnyPublisher()
        }
        
        public var walletResponsePublisher: AnyPublisher<(Bool, [String: Any]), Never> {
            eventSubject
                .compactMap { event in
                    if case .walletResponse(let approved, let data) = event {
                        return (approved, data)
                    }
                    return nil
                }
                .eraseToAnyPublisher()
        }
        
        public var errorPublisher: AnyPublisher<Error, Never> {
            eventSubject
                .compactMap { event in
                    if case .error(let error) = event {
                        return error
                    }
                    return nil
                }
                .eraseToAnyPublisher()
        }
        
        private init() {}
        
        // Method to publish events
        public func publish(_ event: PublisherEvent) {
            eventSubject.send(event)
        }
        
        // Convenience methods for publishing specific events
        public func publishTransactionStatus(id: Flow.ID, status: Flow.Transaction.Status) {
            publish(.transactionStatus(id: id, status: status))
        }
        
        public func publishAccountUpdate(address: Flow.Address) {
            publish(.accountUpdate(address: address))
        }
        
        public func publishConnectionStatus(isConnected: Bool) {
            publish(.connectionStatus(isConnected: isConnected))
        }
        
        public func publishWalletResponse(approved: Bool, data: [String: Any]) {
            publish(.walletResponse(approved: approved, data: data))
        }
        
        public func publishError(_ error: Error) {
            publish(.error(error))
        }
    }
}

// Extension to Flow for easy access to publisher
public extension Flow {
    var publisher: Publisher {
        return Publisher.shared
    }
} 
