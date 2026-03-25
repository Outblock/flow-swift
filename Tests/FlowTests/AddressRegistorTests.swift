//	//
//	//  PublisherTests.swift
//	//  FlowTests
//	//
//	//  Copyright 2022 Outblock Pty Ltd
//	//
//	//  Licensed under the Apache License, Version 2.0 (the "License");
//	//  you may not use this file except in compliance with the License.
//	//  You may obtain a copy of the License at
//	//
//	//  http://www.apache.org/licenses/LICENSE-2.0
//	//
//	//  Unless required by applicable law or agreed to in writing, software
//	//  distributed under the License is distributed on an "AS IS" BASIS,
//	//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//	//  See the License for the specific language governing permissions and
//	//  limitations under the License.
//	//  Migrated to Swift Testing by Nicholas Reich on 2026-03-19.
//	//
//
//import Combine
//@testable import Flow
//import Foundation
//import Testing
//
//@Suite
//struct PublisherTests {
//
//		// MARK: - Helpers
//
//		/// Async helper to await a single value from a Combine publisher.
//	private func awaitFirstValue<P: Publisher>(
//		from publisher: P,
//		timeout seconds: TimeInterval = 5,
//		file: StaticString = #filePath,
//		line: UInt = #line
//	) async -> P.Output? where P.Failure == Never {
//		var cancellable: AnyCancellable?
//		var result: P.Output?
//
//		let finished = ManagedCriticalState(false)
//
//		let continuation = UnsafeContinuation<Void, Never>.self
//
//		await withUnsafeContinuation { (cont: UnsafeContinuation<Void, Never>) in
//			cancellable = publisher.sink { value in
//				result = value
//				finished.withCriticalRegion { $0 = true }
//				cont.resume()
//			}
//
//			DispatchQueue.global().asyncAfter(deadline: .now() + seconds) {
//				finished.withCriticalRegion { alreadyFinished in
//					if !alreadyFinished {
//						cont.resume()
//					}
//				}
//			}
//		}
//
//		_ = cancellable // keep alive until after continuation
//
//		if result == nil {
//			Issue.record(
//				"Publisher did not produce a value within \(seconds) seconds",
//				sourceLocation: .init(
//					filePath: String(file),
//					line: Int(line),
//					column: 0
//				)
//			)
//		}
//
//		return result
//	}
//
//		// MARK: - Account publisher
//
//	@Test("Flow account publisher emits account updates")
//	func accountPublisherEmits() async {
//			// Given
//		let address = Flow.Address(hex: "0x01")
//			// Public access to the Flow publisher singleton
//		let publisherCenter = Flow.PublisherCenter.shared
//
//			// When
//		let publisher = publisherCenter.accountPublisher(address: address)
//
//		let value = await awaitFirstValue(from: publisher)
//
//			// Then
//		#expect(value?.address == address)
//	}
//
//		// MARK: - Connection state publisher
//
//	@Test("Flow connection publisher emits connection state updates")
//	func connectionPublisherEmits() async {
//			// Given
//		let publisherCenter = Flow.PublisherCenter.shared
//
//			// When
//		let publisher = publisherCenter.connectionPublisher()
//
//		let value = await awaitFirstValue(from: publisher)
//
//			// Then
//		#expect(value != nil)
//	}
//
//		// MARK: - Wallet response publisher
//
//	@Test("Flow wallet response publisher emits responses")
//	func walletResponsePublisherEmits() async {
//			// Given
//		let publisherCenter = Flow.PublisherCenter.shared
//		let walletPublisher = publisherCenter.walletResponsePublisher()
//
//			// When: simulate a wallet response going through the WebSocket layer.
//		let sampleResponse = Flow.WalletConnectResponse(
//			id: 1,
//			jsonrpc: "2.0",
//			result: .init(requestId: "test", status: .approved)
//		)
//
//			// Assume the publisher center exposes a way to manually feed responses for testing.
//		publisherCenter.injectWalletResponse(sampleResponse)
//
//		let value = await awaitFirstValue(from: walletPublisher)
//
//			// Then
//		#expect(value?.id == sampleResponse.id)
//	}
//
//		// MARK: - Error publisher
//
//	@Test("Flow error publisher emits Flow errors")
//	func errorPublisherEmits() async {
//			// Given
//		let publisherCenter = Flow.PublisherCenter.shared
//		let errorPublisher = publisherCenter.errorPublisher()
//
//		let nsError = NSError(domain: "io.outblock.flow.tests", code: 42, userInfo: nil)
//		let flowError = Flow.Error.networkError(underlying: nsError)
//
//			// When: simulate an error being emitted by the HTTP/WebSocket client.
//		publisherCenter.injectError(flowError)
//
//		let value = await awaitFirstValue(from: errorPublisher)
//
//			// Then
//		#expect(value as? Flow.Error == flowError)
//	}
//
//		// MARK: - Connection publisher multiple values
//
//	@Test("Flow connection publisher emits multiple states")
//	func connectionPublisherMultipleStates() async {
//			// Given
//		let publisherCenter = Flow.PublisherCenter.shared
//		let connectionPublisher = publisherCenter.connectionPublisher()
//
//		var cancellable: AnyCancellable?
//		var receivedStates: [Flow.ConnectionState] = []
//
//			// When
//		await withUnsafeContinuation { (cont: UnsafeContinuation<Void, Never>) in
//			cancellable = connectionPublisher.sink { state in
//				receivedStates.append(state)
//				if receivedStates.count >= 2 {
//					cont.resume()
//				}
//			}
//
//				// Simulate state changes
//			publisherCenter.injectConnectionState(.connecting)
//			publisherCenter.injectConnectionState(.connected)
//		}
//
//		_ = cancellable
//
//			// Then
//		#expect(receivedStates.count >= 2)
//	}
//}
