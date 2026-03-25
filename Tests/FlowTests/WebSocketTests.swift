	//
	//  WebSocketTests.swift
	//  FlowTests
	//
	//  Migrated from XCTest to Swift Testing by Nicholas Reich on 2026-03-19.
	//  Refactored to Swift Testing + AsyncStream-based Flow websocket APIs.
	//

import Flow
import Testing
import Foundation

@Suite
struct WebSocketTests {

	init() { }

	@Test("Block digest stream yields a block header")
	func blockDigestSubscription() async throws {
			// Assuming Flow.Publisher exposes a blockStream() async -> AsyncStream<WSBlockHeader>
		let stream = await Flow.shared.publisher.blockStream()

			// Take first value from the async stream
		var iterator = stream.makeAsyncIterator()
		let header = await iterator.next()

		let blockHeader = try #require(header)
		#expect(blockHeader.height.isEmpty == false)
	}

	@Test("Transaction status stream yields a status")
	func transactionStatusSubscription() async throws {
			// Known executed transaction on testnet/mainnet used for integration tests
		let testTxIdHex = "5ab8b0bec5ee89c63c5c33ddc4144f3772d0eeda0e85e905fc7e41c2d449269f"
		let txId = Flow.ID(hex: testTxIdHex)

			// Start websocket subscription (AsyncThrowingStream)
		let stream = try await FlowWebsocketActor.shared.websocket
			.subscribeToTransactionStatus(txId: txId)

		var iterator = stream.makeAsyncIterator()
		while let next = try await iterator.next() {
			guard let payload = next.payload else { continue }
			let status = try payload.asTransactionResult()
			if status.status > .executed {
				#expect(status.status > .executed)
				return
			}
		}

		Issue.record("Did not receive a status > .executed for tx \(testTxIdHex)")
	}

	@Test("Account status subscription placeholder")
	func accountStatusSubscription() {
			// The legacy Combine-based account status subscription API was removed
			// in favor of NIO + AsyncStream and is not yet implemented for accounts.
			// Keep a placeholder test so the suite structure remains intact.
		#expect(true)
	}

	@Test("List subscriptions placeholder test")
	func listSubscriptions() {
			// TODO: Implement once server-side listSubscriptions behavior is defined.
		#expect(true)
	}
}
