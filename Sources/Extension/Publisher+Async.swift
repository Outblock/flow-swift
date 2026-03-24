/**
 *  AsyncCompatibilityKit
 *  Copyright (c) John Sundell 2021
 *  MIT license, see LICENSE.md file for details
 */
	//  Edited for Swift 6 concurrency & actors by Nicholas Reich on 2026-03-19.

@preconcurrency import Combine
import Combine
import Foundation
import SwiftUI

	// Simple Sendable box for the cancellable reference
final class CancellableBox: @unchecked Sendable {
	var cancellable: AnyCancellable?
	init(_ cancellable: AnyCancellable? = nil) {
		self.cancellable = cancellable
	}
}

@available(
	iOS,
	deprecated: 15.0,
	message: "AsyncCompatibilityKit is only useful when targeting iOS versions earlier than 15"
)
public extension Publisher {
		/// Convert this publisher into an `AsyncThrowingStream` that
		/// can be iterated over asynchronously using `for try await`.
		/// The stream will yield each output value produced by the
		/// publisher and will finish once the publisher completes.
	var values: AsyncThrowingStream<Output, Error> {
		AsyncThrowingStream { continuation in
			let box = CancellableBox()

			continuation.onTermination = { @Sendable _ in
				box.cancellable?.cancel()
			}

			box.cancellable = sink(
				receiveCompletion: { completion in
					switch completion {
						case .finished:
							continuation.finish()
						case let .failure(error):
							continuation.finish(throwing: error)
					}
				},
				receiveValue: { value in
					continuation.yield(value)
				}
			)
		}
	}
}

@available(
	iOS,
	deprecated: 15.0,
	message: "AsyncCompatibilityKit is only useful when targeting iOS versions earlier than 15"
)
public extension Publisher where Failure == Never {
		/// Convert this publisher into an `AsyncStream` that can
		/// be iterated over asynchronously using `for await`. The
		/// stream will yield each output value produced by the
		/// publisher and will finish once the publisher completes.
	var values: AsyncStream<Output> {
		AsyncStream { continuation in
			let box = CancellableBox()

			continuation.onTermination = { @Sendable _ in
				box.cancellable?.cancel()
			}

			box.cancellable = sink(
				receiveCompletion: { _ in
					continuation.finish()
				},
				receiveValue: { value in
					continuation.yield(value)
				}
			)
		}
	}
}

struct TimeoutError: LocalizedError {
	var errorDescription: String? {
		"Publisher timed out"
	}
}

public func awaitPublisher<T: Publisher>(
	_ publisher: T,
	timeout: TimeInterval = 20
) async throws -> T.Output {
	try await withCheckedThrowingContinuation { continuation in
		let box = CancellableBox()

		let timeoutTask = _Concurrency.Task.detached {
			try await _Concurrency.Task.sleep(
				nanoseconds: UInt64(timeout * 1_000_000_000)
			)
			box.cancellable?.cancel()
			continuation.resume(throwing: TimeoutError())
		}

		box.cancellable = publisher.first()
			.sink(
				receiveCompletion: { completion in
					timeoutTask.cancel()
					if case let .failure(error) = completion {
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
