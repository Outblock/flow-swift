//
//  File.swift
//  Flow
//
//  Created by Hao Fu on 4/4/2025.
//

import SwiftUI

extension CadenceLoader.Category {
	public enum Token: String, CaseIterable, CadenceLoaderProtocol {
		case getTokenBalanceStorage = "get_token_balance_storage"

		var filename: String { rawValue }
	}
}

public extension Flow {
		/// Get all token balances for account
	@MainActor
	func getTokenBalance(
		address: Flow.Address
	) async throws -> [String: Decimal] {
		let script = try CadenceLoader.load(
			CadenceLoader.Category.Token.getTokenBalanceStorage
		)
		return try await executeScriptAtLatestBlock(
			script: .init(text: script),
			arguments: [.address(address)]
		).decode()
	}
}

	// Actor-safe token manager for UI binding
@MainActor
class TokenManager: ObservableObject {
	@Published var balances: [String: Decimal] = [:]
	@Published var isLoading = false
	@Published var error: Error?

	private let flow: Flow

	init(flow: Flow) {
		self.flow = flow
	}

	func loadBalances(for address: Flow.Address) {
		Task {
			isLoading = true
			defer { isLoading = false }

			do {
				balances = try await flow.getTokenBalance(address: address)
			} catch {
				self.error = error
			}
		}
	}
}
//extension CadenceLoader.Category {
//    
//    public enum Token: String, CaseIterable, CadenceLoaderProtocol {
//        case getTokenBalanceStorage = "get_token_balance_storage"
//        
//        var filename: String {
//            rawValue
//        }
//    }
//    
//}
//
//// Extension to Flow for convenience methods
//public extension Flow {
//    func getTokenBalance(address: Flow.Address) async throws -> [String: Decimal] {
//        let script = try CadenceLoader.load(CadenceLoader.Category.Token.getTokenBalanceStorage)
//        return try await executeScriptAtLatestBlock(
//            script: .init(text: script),
//            arguments: [.address(address)]
//        ).decode()
//    }
//    
//}
