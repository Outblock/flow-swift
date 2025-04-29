import XCTest
import Combine
@testable import Flow

final class WebSocketTests: XCTestCase {
    private var websocket: Flow.Websocket!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        // Using testnet URL for testing
        websocket = Flow.Websocket(chainID: .mainnet)
        cancellables = []
    }
    
    override func tearDown() {
        websocket.disconnect()
        cancellables.removeAll()
        websocket = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    func awaitPublisher<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T.Output {
        var result: Result<T.Output, Error>?
        let expectation = self.expectation(description: "Awaiting publisher")
        
        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    result = .failure(error)
                case .finished:
                    break
                }
                expectation.fulfill()
            },
            receiveValue: { value in
                result = .success(value)
            }
        )
        
        waitForExpectations(timeout: timeout)
        cancellable.cancel()
        
        let unwrappedResult = try XCTUnwrap(
            result,
            "Awaited publisher did not produce any output",
            file: file,
            line: line
        )
        
        return try unwrappedResult.get()
    }
    
    // MARK: - Connection Tests
    
    func testWebSocketConnection() {
        let expectation = self.expectation(description: "WebSocket connection")
        var receivedStatuses: [Bool] = []
        
        Flow.Publisher.shared.connectionPublisher
            .filter { $0 == true } // Only interested in connected state
            .first() // Take only the first true connection
            .sink { connected in
                receivedStatuses.append(connected)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        websocket.connect()
        
        waitForExpectations(timeout: 5)
        XCTAssertTrue(receivedStatuses.contains(true), "WebSocket should have connected")
    }
    
    func testWebSocketDisconnection() {
        let connectionExpectation = self.expectation(description: "WebSocket connection")
        let disconnectionExpectation = self.expectation(description: "WebSocket disconnection")
        var connectionStatuses: [Bool] = []
        
        Flow.Publisher.shared.connectionPublisher
            .sink { connected in
                connectionStatuses.append(connected)
                if connected {
                    connectionExpectation.fulfill()
                } else {
                    disconnectionExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        websocket.connect()
        
        // Wait for connection before testing disconnection
        wait(for: [connectionExpectation], timeout: 5)
        
        websocket.disconnect()
        
        wait(for: [disconnectionExpectation], timeout: 5)
        XCTAssertTrue(connectionStatuses.contains(false), "WebSocket should have disconnected")
    }
    
    // MARK: - Subscription Tests
    
    func testBlockDigestSubscription() throws {
        let expectation = self.expectation(description: "Block digest subscription")
        var receivedHeader: Flow.BlockHeader?
        
        websocket.connect()
        
        websocket.subscribeToBlockDigests()
            .first() // Take only the first block digest
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { header in
                    receivedHeader = header
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 10)
        XCTAssertNotNil(receivedHeader, "Should receive block header")
    }
    
    func testTransactionStatusSubscription() throws {
        let expectation = self.expectation(description: "Transaction status subscription")
        let testTxId = Flow.ID(hex: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef")
        var receivedStatus: Flow.Transaction.Status?
        
        websocket.connect()
        
        websocket.subscribeToTransactionStatus(txId: testTxId)
            .first() // Take only the first status update
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { status in
                    receivedStatus = status
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 10)
        XCTAssertNotNil(receivedStatus, "Should receive transaction status")
    }
    
    func testAccountStatusSubscription() throws {
        let expectation = self.expectation(description: "Account status subscription")
        let testAddress = "0x0123456789abcdef"
        var receivedAccount: Flow.Account?
        
        websocket.connect()
        
        websocket.subscribeToAccountStatuses(address: testAddress)
            .first() // Take only the first account update
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { account in
                    receivedAccount = account
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 10)
        XCTAssertNotNil(receivedAccount, "Should receive account update")
    }
    
    func testListSubscriptions() {
        let expectation = self.expectation(description: "List subscriptions")
        
        websocket.connect()
        
        // Subscribe to something first
        websocket.subscribeToBlockDigests()
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        // Give it a moment to establish the subscription
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.websocket.listSubscriptions()
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10)
    }
} 
