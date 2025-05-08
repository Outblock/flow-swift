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
    
    func awaitConnection() async throws {
        let result = try await awaitPublisher(
            Flow.Publisher.shared.connectionPublisher
                .filter { $0 == true }
                .first()
        )
        
        print(result)
    }
    
    func testWebSocketConnection() async throws {
        try await awaitConnection()
    }
    
    func testWebSocketDisconnection() async throws {
        try await awaitConnection()
        Flow.Publisher.shared.connectionPublisher
            .sink(receiveValue: { connect in
                print(connect)
            })
        websocket.disconnect()
        
//        XCTAssertEqual(connect, false)
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
        websocket.subscribeToTransactionStatus(txId: .init(hex: testTxId))
        let status = try await awaitPublisher(
            flow.publisher.transactionPublisher
                .filter({  $0.1.status > .executed })
                .eraseToAnyPublisher()
        )
        
        print(status)
        XCTAssertNotNil(status)
        websocket.disconnect()
    }
    
    func testAccountStatusSubscription() async throws {
        try await awaitConnection()
        
        let testAddress = "0x418c09f201f67f89"
        let account = try await awaitPublisher(
            websocket.subscribeToAccountStatuses(request: .init(heartbeatInterval: "10", accountAddresses: [testAddress]))
        )
        XCTAssertNotNil(account)
        websocket.disconnect()
    }
    
    func testListSubscriptions() async throws {
        try await awaitConnection()
    }
} 
