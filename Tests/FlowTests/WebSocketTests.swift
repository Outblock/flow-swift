import XCTest
import Combine
@testable import Flow

final class WebSocketTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    private var websocket: Flow.Websocket!
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testBlockDigestSubscription() async throws {
        let blockHeader = try await awaitPublisher(
            flow.websocket.subscribeToBlockDigests()
        )
        XCTAssertNotNil(blockHeader)
    }
    
    func testTransactionStatusSubscription() async throws {
        let testTxId = "5ab8b0bec5ee89c63c5c33ddc4144f3772d0eeda0e85e905fc7e41c2d449269f"
        flow.websocket.subscribeToTransactionStatus(txId: .init(hex: testTxId))
        let status = try await awaitPublisher(
            flow.publisher.transactionPublisher
                .filter({  $0.1.status > .executed })
                .eraseToAnyPublisher()
        )
        
        print(status)
        XCTAssertNotNil(status)
    }
    
    func testAccountStatusSubscription() async throws {
        let address = "0x418c09f201f67f89"
        let account = try await awaitPublisher(
            flow.websocket.subscribeToAccountStatuses(request:
                    .init(heartbeatInterval: "10",
                          accountAddresses: [address])
            )
        )
        XCTAssertNotNil(account)
    }
    
    func testListSubscriptions() async throws {
        // TODO
        XCTAssertTrue(true)
    }
} 
