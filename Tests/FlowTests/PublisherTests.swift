	//
	//  PublisherTests.swift
	//  FlowTests
	//
	//  Migrated to Swift Testing by Nicholas Reich on 2026-03-19.
	//

import Foundation
import Testing
@testable import Flow

@Suite
struct PublisherTests {

	private func awaitFirstValue<T: Sendable>(
		from stream: AsyncStream<T>,
		timeoutSeconds: Double = 60
	) async -> T? {
		await withTaskGroup(of: T?.self) { group in
			group.addTask {
				for await value in stream {
					return value
				}
				return nil
			}

			group.addTask {
				let ns = UInt64(timeoutSeconds * 1_000_000_000)
				try? await _Concurrency.Task.sleep(nanoseconds: ns)
				return nil
			}

			let first = await group.next() ?? nil
			group.cancelAll()
			return first
		}
	}

	@Test("Flow account publisher emits account updates")
	func accountPublisherEmits() async {
		let address = Flow.Address(hex: "0x01")
		let center = Flow.PublisherCenter.shared

		let stream = center.accountPublisher(address: address)
		center.publishAccountUpdate(address: address)

		let value = await awaitFirstValue(from: stream)
		#expect(value == address)
	}

	@Test("Flow connection publisher emits connection status updates")
	func connectionPublisherEmits() async {
		let center = Flow.PublisherCenter.shared

		let stream = center.connectionPublisher()
		center.publishConnectionStatus(isConnected: true)

		let value = await awaitFirstValue(from: stream)
		#expect(value == true)
	}

	@Test("Flow wallet response publisher emits responses")
	func walletResponsePublisherEmits() async {
		let center = Flow.PublisherCenter.shared
		let stream = center.walletResponsePublisher()

		let sample = Flow.WalletResponse(
			id: 1,
			jsonrpc: "2.0",
			requestId: "test",
			approved: true
		)

		center.publishWalletResponse(sample)

		let value = await awaitFirstValue(from: stream)
		#expect(value == sample)
	}

	@Test("Flow error publisher emits errors")
	func errorPublisherEmits() async {
		let center = Flow.PublisherCenter.shared
		let stream = center.errorPublisher()

		let nsError = NSError(domain: "io.outblock.flow.tests", code: 42, userInfo: nil)
		center.publishError(nsError)

		let value = await awaitFirstValue(from: stream) as NSError?
		#expect(value?.domain == nsError.domain)
		#expect(value?.code == nsError.code)
	}

	@Test("Flow connection publisher emits multiple values")
	func connectionPublisherMultipleValues() async {
		let center = Flow.PublisherCenter.shared
		let stream = center.connectionPublisher()

		center.publishConnectionStatus(isConnected: false)
		center.publishConnectionStatus(isConnected: true)

		var it = stream.makeAsyncIterator()
		let first = await it.next()
		let second = await it.next()

		#expect(first == false)
		#expect(second == true)
	}


}
