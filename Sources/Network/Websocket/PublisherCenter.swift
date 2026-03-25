//
//  PublisherCenter.swift
//  Flow
//
//  Created by Nicholas Reich on 3/25/26.
//
import Foundation

public extension Flow {

	struct WalletResponse: Equatable, Sendable {
		public let id: Int
		public let jsonrpc: String
		public let requestId: String
		public let approved: Bool

		public init(id: Int, jsonrpc: String, requestId: String, approved: Bool) {
			self.id = id
			self.jsonrpc = jsonrpc
			self.requestId = requestId
			self.approved = approved
		}
	}

		/// Async/await-friendly event hub for tests and modern consumers.
		/// This intentionally avoids Combine so the test target doesn't need `import Combine`.
	final class PublisherCenter: @unchecked Sendable {
		public static let shared = PublisherCenter()

		private let lock = NSLock()

		private var accountSubs: [UUID: (address: Flow.Address, cont: AsyncStream<Flow.Address>.Continuation)] = [:]
		private var connectionSubs: [UUID: AsyncStream<Bool>.Continuation] = [:]
		private var walletSubs: [UUID: AsyncStream<Flow.WalletResponse>.Continuation] = [:]
		private var errorSubs: [UUID: AsyncStream<any Error>.Continuation] = [:]

		private init() {}

			// MARK: - Subscriptions

		public func accountPublisher(address: Flow.Address) -> AsyncStream<Flow.Address> {
			AsyncStream { continuation in
				let id = UUID()
				lock.lock()
				accountSubs[id] = (address, continuation)
				lock.unlock()

				continuation.onTermination = { [weak self] _ in
					guard let self else { return }
					self.lock.lock()
					self.accountSubs[id] = nil
					self.lock.unlock()
				}
			}
		}

		public func connectionPublisher() -> AsyncStream<Bool> {
			AsyncStream { continuation in
				let id = UUID()
				lock.lock()
				connectionSubs[id] = continuation
				lock.unlock()

				continuation.onTermination = { [weak self] _ in
					guard let self else { return }
					self.lock.lock()
					self.connectionSubs[id] = nil
					self.lock.unlock()
				}
			}
		}

		public func walletResponsePublisher() -> AsyncStream<Flow.WalletResponse> {
			AsyncStream { continuation in
				let id = UUID()
				lock.lock()
				walletSubs[id] = continuation
				lock.unlock()

				continuation.onTermination = { [weak self] _ in
					guard let self else { return }
					self.lock.lock()
					self.walletSubs[id] = nil
					self.lock.unlock()
				}
			}
		}

		public func errorPublisher() -> AsyncStream<any Error> {
			AsyncStream { continuation in
				let id = UUID()
				lock.lock()
				errorSubs[id] = continuation
				lock.unlock()

				continuation.onTermination = { [weak self] _ in
					guard let self else { return }
					self.lock.lock()
					self.errorSubs[id] = nil
					self.lock.unlock()
				}
			}
		}

			// MARK: - Publish helpers

		public func publishAccountUpdate(address: Flow.Address) {
			lock.lock()
			let subs = accountSubs.values
			lock.unlock()

			for (target, cont) in subs where target == address {
				cont.yield(address)
			}
		}

		public func publishConnectionStatus(isConnected: Bool) {
			lock.lock()
			let subs = Array(connectionSubs.values)
			lock.unlock()

			for cont in subs {
				cont.yield(isConnected)
			}
		}

		public func publishWalletResponse(_ response: Flow.WalletResponse) {
			lock.lock()
			let subs = Array(walletSubs.values)
			lock.unlock()

			for cont in subs {
				cont.yield(response)
			}
		}

		public func publishError(_ error: any Error) {
			lock.lock()
			let subs = Array(errorSubs.values)
			lock.unlock()

			for cont in subs {
				cont.yield(error)
			}
		}
	}
}

