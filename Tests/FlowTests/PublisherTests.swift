import XCTest
import Combine
@testable import Flow

final class PublisherTests: XCTestCase {
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = []
    }
    
    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }
    
    // MARK: - Transaction Status Tests
    
    func testTransactionStatusPublishing() {
//        let expectation = self.expectation(description: "Transaction status")
//        let testId = Flow.ID(hex: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef")
//        let testStatus = Flow.Transaction.Status.sealed
//        var receivedId: Flow.ID?
//        var receivedStatus: Flow.Transaction.Status?
//        
//        Flow.Publisher.shared.transactionPublisher
//            .sink { id, status in
//                receivedId = id
//                receivedStatus = status
//                expectation.fulfill()
//            }
//            .store(in: &cancellables)
//        
//        Flow.Publisher.shared.publishTransactionStatus(id: testId, status: testStatus)
//        
//        waitForExpectations(timeout: 1)
//        XCTAssertEqual(receivedId, testId)
//        XCTAssertEqual(receivedStatus, testStatus)
    }
    
    // MARK: - Account Update Tests
    
    func testAccountUpdatePublishing() {
        let expectation = self.expectation(description: "Account update")
        let testAddress = Flow.Address(hex: "0x0123456789abcdef")
        var receivedAddress: Flow.Address?
        
        Flow.Publisher.shared.accountPublisher
            .sink { address in
                receivedAddress = address
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        Flow.Publisher.shared.publishAccountUpdate(address: testAddress)
        
        waitForExpectations(timeout: 1)
        XCTAssertEqual(receivedAddress, testAddress)
    }
    
    // MARK: - Connection Status Tests
    
    func testConnectionStatusPublishing() {
        let expectation = self.expectation(description: "Connection status")
        let testStatus = true
        var receivedStatus: Bool?
        
        Flow.Publisher.shared.connectionPublisher
            .sink { status in
                receivedStatus = status
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        Flow.Publisher.shared.publishConnectionStatus(isConnected: testStatus)
        
        waitForExpectations(timeout: 1)
        XCTAssertEqual(receivedStatus, testStatus)
    }
    
    // MARK: - Wallet Response Tests
    
    func testWalletResponsePublishing() {
        let expectation = self.expectation(description: "Wallet response")
        let testApproved = true
        let testData: [String: Any] = ["key": "value"]
        var receivedApproved: Bool?
        var receivedData: [String: Any]?
        
        Flow.Publisher.shared.walletResponsePublisher
            .sink { approved, data in
                receivedApproved = approved
                receivedData = data
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        Flow.Publisher.shared.publishWalletResponse(approved: testApproved, data: testData)
        
        waitForExpectations(timeout: 1)
        XCTAssertEqual(receivedApproved, testApproved)
        XCTAssertEqual(receivedData?["key"] as? String, testData["key"] as? String)
    }
    
    // MARK: - Error Tests
    
    func testErrorPublishing() {
        let expectation = self.expectation(description: "Error")
        let testError = NSError(domain: "test", code: 1, userInfo: nil)
        var receivedError: Error?
        
        Flow.Publisher.shared.errorPublisher
            .sink { error in
                receivedError = error
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        Flow.Publisher.shared.publishError(testError)
        
        waitForExpectations(timeout: 1)
        XCTAssertEqual((receivedError as NSError?)?.domain, testError.domain)
        XCTAssertEqual((receivedError as NSError?)?.code, testError.code)
    }
    
    // MARK: - Multiple Subscriber Tests
    
    func testMultipleSubscribers() {
        let expectation1 = self.expectation(description: "Subscriber 1")
        let expectation2 = self.expectation(description: "Subscriber 2")
        let testStatus = true
        var receivedStatus1: Bool?
        var receivedStatus2: Bool?
        
        // First subscriber
        Flow.Publisher.shared.connectionPublisher
            .sink { status in
                receivedStatus1 = status
                expectation1.fulfill()
            }
            .store(in: &cancellables)
        
        // Second subscriber
        Flow.Publisher.shared.connectionPublisher
            .sink { status in
                receivedStatus2 = status
                expectation2.fulfill()
            }
            .store(in: &cancellables)
        
        Flow.Publisher.shared.publishConnectionStatus(isConnected: testStatus)
        
        waitForExpectations(timeout: 1)
        XCTAssertEqual(receivedStatus1, testStatus)
        XCTAssertEqual(receivedStatus2, testStatus)
    }
} 
