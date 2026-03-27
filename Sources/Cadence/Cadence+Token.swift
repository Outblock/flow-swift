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
	@FlowCryptoActor
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

@FlowCryptoActor
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
		_Concurrency.Task { @FlowCryptoActor in
			self.isLoading = true
			defer { self.isLoading = false }

			do {
				let balances = try await self.flow.getTokenBalance(address: address)
				self.balances = balances
			} catch {
				self.error = error
			}
		}
	}
}

