	//
	//  Cadence+Token.swift
	//  Flow
	//
	//  Created by Hao Fu on 4/4/2025.
	//

import SwiftUI

	// MARK: - Cadence Loader Category

extension CadenceLoader.Category {
	public enum Token: String, CaseIterable, CadenceLoaderProtocol {
		case getTokenBalanceStorage = "get_token_balance_storage"

		public var filename: String { rawValue }
	}
}

// MARK: - Flow convenience API

public extension Flow {
	/// Get all token balances for an account using the Cadence script
	/// `get_token_balance_storage`.
	@MainActor
	func getTokenBalance(
	address: Flow.Address
	) async throws -> [String: Decimal] {
		let scriptSource = try await CadenceLoader.load(
		CadenceLoader.Category.Token.getTokenBalanceStorage
		)
		// `Flow.Script` has an initializer taking text; keep using that.
		return try await executeScriptAtLatestBlock(
		script: .init(text: scriptSource),
		arguments: [.address(address)]
			).decode()
	}
}

// MARK: - Actor-safe Token Manager for UI

@MainActor
final class TokenManager: ObservableObject {
	@Published var balances: [String: Decimal] = [:]
	@Published var isLoading = false
	@Published var error: Error?

	private let flow: Flow

	init(flow: Flow) {
		self.flow = flow
	}

		/// Fire-and-forget load suitable for SwiftUI call sites.
		/// Example:
		///     Button("Refresh") { tokenManager.loadBalances(for: address) }
	func loadBalances(for address: Flow.Address) {
			// Use the concurrency Task explicitly from the _Concurrency module
			// to avoid any local `Task` name collisions.
		_Concurrency.Task { @MainActor in
			self.isLoading = true
			defer { self.isLoading = false }

			do {
				self.balances = try await self.flow.getTokenBalance(address: address)
			} catch {
				self.error = error
			}
		}
	}
}
