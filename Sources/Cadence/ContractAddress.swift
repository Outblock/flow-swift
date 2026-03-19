	//
	//  ContractAddress.swift
	//  Flow
	//
	//  Created by Hao Fu on 1/4/2025.
	//  Reviewed for Swift 6 concurrency & actors by Nicholas Reich on 2026-03-19.
	//

import Foundation

	/// Contract Address Register manages the mapping of contract names to their addresses
	/// for different Flow networks (mainnet, testnet).
public final class ContractAddressRegister {
		/// Contract addresses for each network.
	private var addresses: [Flow.ChainID: [String: String]]

		/// Initialize with contract addresses from JSON.
	public init() {
		addresses = [:]

			// Load JSON from bundle.
		guard
			let url = Bundle.module.url(
				forResource: "addresses",
				withExtension: "json",
				subdirectory: "CommonCadence"
			),
			let data = try? Data(contentsOf: url)
		else {
			FlowLogger.shared.log(
				.warning,
				message: "Could not load addresses.json from bundle"
			)
			return
		}

		do {
				// First decode as [String: [String: String]].
			let jsonDict = try JSONDecoder().decode(
				[String: [String: String]].self,
				from: data
			)

				// Convert network strings to Flow.ChainID.
			for (networkStr, contractAddresses) in jsonDict {
				let network = Flow.ChainID(name: networkStr)
				addresses[network] = contractAddresses
			}
		} catch {
			FlowLogger.shared.log(
				.warning,
				message: "Could not decode addresses.json"
			)
		}
	}

		/// Import addresses for a given network from a dictionary.
	public func importAddresses(
		for network: Flow.ChainID,
		from dict: [String: String]
	) {
		if addresses[network] == nil {
			addresses[network] = dict
		} else {
			for (contract, address) in dict {
				addresses[network]?[contract] = address
			}
		}
	}

		/// Import addresses for a given network from a JSON string.
	public func importAddresses(
		for network: Flow.ChainID,
		from json: String
	) {
		guard
			let jsonData = json.data(using: .utf8),
			let dict = try? JSONDecoder().decode(
				[String: String].self,
				from: jsonData
			)
		else {
			return
		}

		importAddresses(for: network, from: dict)
	}

		/// Get contract address for the specified network.
		/// - Parameters:
		///   - contract: Contract name with 0x prefix (e.g., "0xFlowToken").
		///   - network: Network name (.mainnet, .testnet, or custom).
		/// - Returns: Contract address if found, nil otherwise.
	public func getAddress(
		for contract: String,
		on network: Flow.ChainID
	) -> String? {
		addresses[network]?[contract]
	}

		/// Get all contract addresses for a network.
		/// - Parameter network: Network identifier.
		/// - Returns: Dictionary of contract names to addresses.
	public func getAddresses(for network: Flow.ChainID) -> [String: String] {
		addresses[network] ?? [:]
	}

		/// Check if a contract exists on a network.
		/// - Parameters:
		///   - contract: Contract name with 0x prefix.
		///   - network: Network identifier.
		/// - Returns: True if contract exists on the network.
	public func contractExists(
		_ contract: String,
		on network: Flow.ChainID
	) -> Bool {
		getAddress(for: contract, on: network) != nil
	}

		/// Get all available networks.
		/// - Returns: Array of networks that have registered contracts.
	public func getNetworks() -> [Flow.ChainID] {
		Array(addresses.keys)
	}

		/// Replace 0x placeholders in Cadence code with actual addresses.
		/// - Parameters:
		///   - code: Cadence code with 0x placeholders.
		///   - network: Network to use for address resolution.
		/// - Returns: Code with resolved addresses.
	public func resolveImports(
		in code: String,
		for network: Flow.ChainID
	) -> String {
		code.replace(by: getAddresses(for: network))
	}
}
