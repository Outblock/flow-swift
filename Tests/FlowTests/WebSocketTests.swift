	//
	//  WebSocketTests.swift
	//  FlowTests
	//
	//  Migrated from XCTest to Swift Testing by Nicholas Reich on 2026-03-19.
	//

import Combine
import Flow
import Testing

@Suite
struct WebSocketTests {
	private var cancellables = Set<AnyCancellable>()

	init() { }

	@Test(
		"Block digest subscription yields a block header",
		.timeLimit(.seconds(10))
	)
	mutating func blockDigestSubscription() async throws {
		let expectation = AsyncExpectation<Flow.Websocket.TopicResponse<Flow.WSBlockHeader>>()

		flow.websocket
			.subscribeToBlockDigests()
			.sink(
				receiveCompletion: { completion in
					if case let .failure(error) = completion {
						expectation.fail(error)
					}
				},
				receiveValue: { value in
					expectation.fulfill(value)
				}
			)
			.store(in: &cancellables)

		let blockHeader = try await expectation.value
		#expect(blockHeader.payload != nil)
	}

	@Test(
		"Transaction status subscription yields a status",
		.timeLimit(.seconds(30))
	)
	mutating func transactionStatusSubscription() async throws {
		let testTxId = "5ab8b0bec5ee89c63c5c33ddc4144f3772d0eeda0e85e905fc7e41c2d449269f"

		flow.websocket.subscribeToTransactionStatus(txId: .init(hex: testTxId))

		let expectation = AsyncExpectation<(Flow.ID, Flow.TransactionResult)>()

		flow.publisher.transactionPublisher
			.filter { $0.1.status > .executed }
			.sink(
				receiveCompletion: { completion in
					if case let .failure(error) = completion as? any Error {
						expectation.fail(error)
					}
				},
				receiveValue: { value in
					expectation.fulfill(value)
				}
			)
			.store(in: &cancellables)

		let status = try await expectation.value
		#expect(status.1.status > .executed)
	}

	@Test(
		"Account status subscription yields updates",
		.timeLimit(.seconds(30))
	)
	mutating func accountStatusSubscription() async throws {
		let address = "0x418c09f201f67f89"

		let expectation =
		AsyncExpectation<Flow.Websocket.TopicResponse<Flow.Websocket.AccountStatusResponse>>()

		flow.websocket
			.subscribeToAccountStatuses(
				request: .init(
					heartbeatInterval: "10",
					accountAddresses: [address]
				)
			)
			.sink(
				receiveCompletion: { completion in
					if case let .failure(error) = completion {
						expectation.fail(error)
					}
				},
				receiveValue: { value in
					expectation.fulfill(value)
				}
			)
			.store(in: &cancellables)

		let accountStatus = try await expectation.value
		#expect(accountStatus.payload != nil)
	}

	@Test(
		"List subscriptions placeholder test",
		.timeLimit(.seconds(2))
	)
	func listSubscriptions() {
			// TODO: Implement once server-side listSubscriptions behavior is defined.
		#expect(true)
	}
}
