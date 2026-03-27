import AsyncAlgorithms
import Foundation

public struct TimeoutError: LocalizedError, Sendable, Equatable {
	public init() {}
	public var errorDescription: String? { "Operation timed out" }
}

public struct FinishedWithoutValueError: LocalizedError, Sendable, Equatable {
	public init() {}
	public var errorDescription: String? { "AsyncSequence finished without producing a value" }
}

public enum TimeoutPolicy: Sendable {
	case throwOnTimeout
	case finishOnTimeout
}

public enum TimeoutEvent<Element: Sendable>: Sendable {
	case element(Element)
	case timeout
}

public struct TimeoutAsyncSequence<Base: AsyncSequence & Sendable, C: Clock & Sendable>: AsyncSequence, Sendable
where Base.Element: Sendable {

	public typealias Element = Base.Element

	private let base: Base
	private let interval: C.Instant.Duration
	private let tolerance: C.Instant.Duration?
	private let clock: C
	private let policy: TimeoutPolicy

	public init(
		base: Base,
		after interval: C.Instant.Duration,
		tolerance: C.Instant.Duration? = nil,
		clock: C,
		policy: TimeoutPolicy
	) {
		self.base = base
		self.interval = interval
		self.tolerance = tolerance
		self.clock = clock
		self.policy = policy
	}

	public struct Iterator: AsyncIteratorProtocol {
		private var merged: AsyncMerge2Sequence<
			AsyncMapSequence<Base, TimeoutEvent<Base.Element>>,
			AsyncMapSequence<AsyncTimerSequence<C>, TimeoutEvent<Base.Element>>
		>.AsyncIterator

		private let policy: TimeoutPolicy
		private var didTimeout = false

		init(sequence: TimeoutAsyncSequence<Base, C>) {
			let elements = sequence.base.map { TimeoutEvent.element($0) }

			let timer = AsyncTimerSequence(
				interval: sequence.interval,
				tolerance: sequence.tolerance,
				clock: sequence.clock
			)
				.map { _ in TimeoutEvent<Base.Element>.timeout }

			self.merged = merge(elements, timer).makeAsyncIterator()
			self.policy = sequence.policy
		}

		public mutating func next() async throws -> Base.Element? {
			if didTimeout { return nil }

			while true {
				switch try await merged.next() {
					case .element(let value):
						return value

					case .timeout:
						didTimeout = true
						switch policy {
							case .finishOnTimeout:
								return nil
							case .throwOnTimeout:
								throw TimeoutError()
						}

					case nil:
						return nil
				}
			}
		}
	}

	public func makeAsyncIterator() -> Iterator {
		Iterator(sequence: self)
	}
}

public extension AsyncSequence where Self: Sendable, Element: Sendable {
	func timeout<C: Clock & Sendable>(
		after interval: C.Instant.Duration,
		tolerance: C.Instant.Duration? = nil,
		clock: C,
		policy: TimeoutPolicy = .throwOnTimeout
	) -> TimeoutAsyncSequence<Self, C> {
		TimeoutAsyncSequence(
			base: self,
			after: interval,
			tolerance: tolerance,
			clock: clock,
			policy: policy
		)
	}

	func timeout(
		after interval: Duration,
		tolerance: Duration? = nil,
		policy: TimeoutPolicy = .throwOnTimeout
	) -> TimeoutAsyncSequence<Self, ContinuousClock> {
		TimeoutAsyncSequence(
			base: self,
			after: interval,
			tolerance: tolerance,
			clock: ContinuousClock(),
			policy: policy
		)
	}
}

@inline(__always)
private func _duration(seconds: TimeInterval) -> Duration {
	let clamped = max(0, seconds)
	return .nanoseconds(Int64(clamped * 1_000_000_000))
}

public func awaitFirst<S: AsyncSequence & Sendable>(
	_ sequence: S,
	timeoutSeconds: TimeInterval = 20
) async throws -> S.Element
where S.Element: Sendable {
	var it = sequence
		.timeout(after: _duration(seconds: timeoutSeconds), policy: .throwOnTimeout)
		.makeAsyncIterator()

	guard let value = try await it.next() else {
		throw FinishedWithoutValueError()
	}
	return value
}

public func awaitFirstOrNil<S: AsyncSequence & Sendable>(
	_ sequence: S,
	timeoutSeconds: TimeInterval = 20
) async -> S.Element?
where S.Element: Sendable {
	do {
		return try await awaitFirst(sequence, timeoutSeconds: timeoutSeconds)
	} catch {
		return nil
	}
}
