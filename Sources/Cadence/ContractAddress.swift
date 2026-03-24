	//
	//  ContractAddress.swift
	//  Flow
	//
	//  Created by Hao Fu on 1/4/2025.
	//  Reviewed for Swift 6 concurrency & actors by Nicholas Reich on 2026-03-19.
	//

	// Sources/Cadence/ContractAddress.swift

import Foundation

	/// Contract Address Register manages the mapping of contract names to their addresses
	/// for different Flow networks (mainnet, testnet).
public final class ContractAddressRegister {
		/// Contract addresses for each network.
	private var addresses: [Flow.ChainID: [String: String]]

	public init() {
		addresses = [:]
	}

	public func setAddress(
		_ address: String,
		for name: String,
		on chainID: Flow.ChainID
	) {
		var map = addresses[chainID] ?? [:]
		map[name] = address
		addresses[chainID] = map
	}

	public func address(for name: String, on chainID: Flow.ChainID) -> String? {
		addresses[chainID]?[name]
	}

		/// Resolve `import X from 0x...` in a script, based on configured addresses.
	public func resolveImports(in script: String, for chainID: Flow.ChainID) -> String {
		guard let map = addresses[chainID], !map.isEmpty else {
			return script
		}

		var result = script
		for (name, address) in map {
			let pattern = "import \(name) from "
			if result.contains(pattern) {
				result = result.replacingOccurrences(
					of: "\(pattern)0x",
					with: "\(pattern)0x\(address)"
				)
			}
		}
		return result
	}
}

