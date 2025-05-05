import XCTest
import Combine
@testable import Flow

final class WebSocketTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    private var websocket: Flow.Websocket!
    
    override func setUp() {
        super.setUp()
        websocket = Flow.Websocket(chainID: .mainnet)
        websocket.connect()
    }
    
    override func tearDown() {
        websocket.disconnect()
        cancellables.removeAll()
        super.tearDown()
    }
    
    struct TimeoutError: LocalizedError {
        var errorDescription: String? {
            return "Publisher timed out"
        }
    }
    
    func awaitPublisher<T: Publisher>(_ publisher: T, timeout: TimeInterval = 5) async throws -> T.Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            let timeoutTask = _Concurrency.Task.detached {
                try await _Concurrency.Task.sleep(nanoseconds: 10_000_000_000)
                cancellable?.cancel()
                continuation.resume(throwing: TimeoutError())
            }
            
            cancellable = publisher.first()
                .sink(
                    receiveCompletion: { completion in
                        timeoutTask.cancel()
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                    },
                    receiveValue: { value in
                        timeoutTask.cancel()
                        continuation.resume(returning: value)
                    }
                )
        }
    }
    
    func awaitConnection() async throws {
        let result = try await awaitPublisher(
            Flow.Publisher.shared.connectionPublisher
                .filter { $0 == true }
                .first()
        )
        
        print(result)
    }
    
    func awaitDisconnection() async throws {
        try await awaitPublisher(
            Flow.Publisher.shared.connectionPublisher
                .filter { $0 == false }
                .first()
        )
    }
    
    func testWebSocketConnection() async throws {
        try await awaitConnection()
    }
    
    func testWebSocketDisconnection() async throws {
        try await awaitConnection()
        websocket.disconnect()
        try await awaitDisconnection()
    }
    
    func testBlockDigestSubscription() async throws {
        try await awaitConnection()
        let blockHeader = try await awaitPublisher(
            websocket.subscribeToBlockDigests()
        )
        XCTAssertNotNil(blockHeader)
    }
    
    func testTransactionStatusSubscription() async throws {
        try await awaitConnection()
        
        let testTxId = "5ab8b0bec5ee89c63c5c33ddc4144f3772d0eeda0e85e905fc7e41c2d449269f"
        let status = try await awaitPublisher(
            websocket.subscribeToTransactionStatus(txId: .init(hex: testTxId))
                .dropFirst()
                .filter({  $0.transactionResult.status > .executed })
                .eraseToAnyPublisher()
        )
        
        print("AAAA => \(status.transactionResult)")
        
        XCTAssertNotNil(status)
    }
    
    func testAccountStatusSubscription() async throws {
        try await awaitConnection()
        
        let testAddress = "0x01"
        let account = try await awaitPublisher(
            websocket.subscribeToAccountStatuses(address: testAddress)
        )
        
        XCTAssertNotNil(account)
    }
    
    func testListSubscriptions() async throws {
        try await awaitConnection()
        
//        let subscriptions = try await awaitPublisher(
//            websocket.listSubscriptions()
//        )
        
//        XCTAssertNotNil(subscriptions)
    }
} 
