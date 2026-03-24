//	//
//	//  PublisherTests.swift
//	//  FlowTests
//	//
//	//  Migrated from XCTest to Swift Testing by Nicholas Reich on 2026-03-19.
//	//
//
//import Combine
//import Flow
//import Testing
//
//@Suite
//struct PublisherTests {
//	private var cancellables = Set<AnyCancellable>()
//
//	init() { }
//
//		// MARK: - Account Update Tests
//
//	@Test(
//		"Account update is published to subscribers",
//		.timeLimit(.seconds(2))
//	)
//	mutating func accountUpdatePublishing() async throws {
//		let testAddress = Flow.Address(hex: "0x0123456789abcdef")
//		var receivedAddress: Flow.Address?
//
//		let expectation = AsyncExpectation<Void>()
//
//		Flow.Publisher.shared.accountPublisher
//			.sink { address in
//				receivedAddress = address
//				expectation.fulfill()
//			}
//			.store(in: &cancellables)
//
//		Flow.Publisher.shared.publishAccountUpdate(address: testAddress)
//
//		try await expectation.value
//		#expect(receivedAddress == testAddress)
//	}
//
//		// MARK: - Connection Status Tests
//
//	@Test(
//		"Connection status is published",
//		.timeLimit(.seconds(2))
//	)
//	mutating func connectionStatusPublishing() async throws {
//		let testStatus = true
//		var receivedStatus: Bool?
//
//		let expectation = AsyncExpectation<Void>()
//
//		Flow.Publisher.shared.connectionPublisher
//			.sink { status in
//				receivedStatus = status
//				expectation.fulfill()
//			}
//			.store(in: &cancellables)
//
//		Flow.Publisher.shared.publishConnectionStatus(isConnected: testStatus)
//
//		try await expectation.value
//		#expect(receivedStatus == testStatus)
//	}
//
//		// MARK: - Wallet Response Tests
//
//	@Test(
//		"Wallet response is published",
//		.timeLimit(.seconds(2))
//	)
//	mutating func walletResponsePublishing() async throws {
//		let testApproved = true
//		let testData: [String: Any] = ["key": "value"]
//		var receivedApproved: Bool?
//		var receivedData: [String: Any]?
//
//		let expectation = AsyncExpectation<Void>()
//
//		Flow.Publisher.shared.walletResponsePublisher
//			.sink { approved, data in
//				receivedApproved = approved
//				receivedData = data
//				expectation.fulfill()
//			}
//			.store(in: &cancellables)
//
//		Flow.Publisher.shared.publishWalletResponse(
//			approved: testApproved,
//			testData
//		)
//
//		try await expectation.value
//		#expect(receivedApproved == testApproved)
//		#expect((receivedData?["key"] as? String) == (testData["key"] as? String))
//	}
//
//		// MARK: - Error Tests
//
//	@Test(
//		"Error is published",
//		.timeLimit(.seconds(2))
//	)
//	mutating func errorPublishing() async throws {
//		let testError = NSError(domain: "test", code: 1, userInfo: nil)
//		var receivedError: Error?
//
//		let expectation = AsyncExpectation<Void>()
//
//		Flow.Publisher.shared.errorPublisher
//			.sink { error in
//				receivedError = error
//				expectation.fulfill()
//			}
//			.store(in: &cancellables)
//
//		Flow.Publisher.shared.publishError(testError)
//
//		try await expectation.value
//		let nsError = receivedError as NSError?
//		#expect(nsError?.domain == testError.domain)
//		#expect(nsError?.code == testError.code)
//	}
//
//		// MARK: - Multiple Subscriber Tests
//
//	@Test(
//		"Multiple subscribers receive connection status",
//		.timeLimit(.seconds(2))
//	)
//	mutating func multipleSubscribers() async throws {
//		let testStatus = true
//		var receivedStatus1: Bool?
//		var receivedStatus2: Bool?
//
//		let expectation1 = AsyncExpectation<Void>()
//		let expectation2 = AsyncExpectation<Void>()
//
//			// First subscriber
//		Flow.Publisher.shared.connectionPublisher
//			.sink { status in
//				receivedStatus1 = status
//				expectation1.fulfill()
//			}
//			.store(in: &cancellables)
//
//			// Second subscriber
//		Flow.Publisher.shared.connectionPublisher
//			.sink { status in
//				receivedStatus2 = status
//				expectation2.fulfill()
//			}
//			.store(in: &cancellables)
//
//		Flow.Publisher.shared.publishConnectionStatus(isConnected: testStatus)
//
//		try await expectation1.value
//		try await expectation2.value
//
//		#expect(receivedStatus1 == testStatus)
//		#expect(receivedStatus2 == testStatus)
//	}
//}
