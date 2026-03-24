/**
 *  AsyncCompatibilityKit
 *  Copyright (c) John Sundell 2021
 *  MIT license, see LICENSE.md file for details
 *
 *  Edited for Swift 6 concurrency & actors by Nicholas Reich on 2026-03-19.
 */

@preconcurrency import Combine
import Foundation
import SwiftUI

	/// Simple Sendable box for the cancellable reference
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
public extension Publisher where Output: Sendable {
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

			box.cancellable = self.sink(
				receiveCompletion: { @Sendable completion in
					switch completion {
						case .finished:
							continuation.finish()
						case let .failure(error):
							continuation.finish(throwing: error)
					}
				},
				receiveValue: { @Sendable value in
						// `Output` is constrained to `Sendable`, so this is safe.
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
public extension Publisher where Failure == Never, Output: Sendable {
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

			box.cancellable = self.sink(
				receiveCompletion: { @Sendable _ in
					continuation.finish()
				},
				receiveValue: { @Sendable value in
						// `Output` is constrained to `Sendable`, so this is safe.
					continuation.yield(value)
				}
			)
		}
	}
}

struct TimeoutError: LocalizedError, Sendable {
	var errorDescription: String? {
		"Publisher timed out"
	}
}

public func awaitPublisher<T: Publisher>(
	_ publisher: T,
	timeout: TimeInterval = 20
) async throws -> T.Output where T.Output: Sendable {
	try await withCheckedThrowingContinuation { continuation in
		let box = CancellableBox()

		let timeoutTask = _Concurrency.Task {
			try await _Concurrency.Task.sleep(
				nanoseconds: UInt64(timeout * 1_000_000_000)
			)
			box.cancellable?.cancel()
			continuation.resume(throwing: TimeoutError())
		}

		box.cancellable = publisher.first()
			.sink(
				receiveCompletion: { @Sendable completion in
					timeoutTask.cancel()
					if case let .failure(error) = completion {
						continuation.resume(throwing: error)
					}
				},
				receiveValue: { @Sendable value in
					timeoutTask.cancel()
						// `T.Output` is constrained to `Sendable`, so this is safe.
					continuation.resume(returning: value)
				}
			)
	}
}
