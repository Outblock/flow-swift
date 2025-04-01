//
//  File.swift
//  Flow
//
//  Created by Hao Fu on 1/4/2025.
//

import Foundation

/// Contract Address Register manages the mapping of contract names to their addresses
/// for different Flow networks (mainnet, testnet)
public class ContractAddressRegister {
    
    /// Contract addresses for each network
    private var addresses: [Flow.ChainID: [String: String]]
    
    /// Initialize with contract addresses from JSON
    public init() {
        addresses = [:]  // Initialize first
        
        // Load JSON from bundle
        guard let url = Bundle.module.url(forResource: "addresses", withExtension: "json", subdirectory: "CommonCadence"),
              let data = try? Data(contentsOf: url) else {
            FlowLogger.shared.log(.warning, message: "Could not load addresses.json from bundle")
            return
        }
        
        do {
            // First decode as [String: [String: String]]
            let jsonDict = try JSONDecoder().decode([String: [String: String]].self, from: data)
            
            // Convert network strings to Flow.ChainID
            for (networkStr, contractAddresses) in jsonDict {
                let network = Flow.ChainID(name: networkStr)
                addresses[network] = contractAddresses
            }
            
        } catch {
            FlowLogger.shared.log(.warning, message: "Could not decode addresses.json")
        }
    }

    public func importAddresses(for network: Flow.ChainID, from dict: [String: String]) {
        for (contract, address) in dict {
            addresses[network]?[contract] = address
        }
    }

    public func importAddresses(for network: Flow.ChainID, from json: String) {
        guard let json = json.data(using: .utf8),
              let dict = try? JSONDecoder().decode([String: String].self, from: json) else {
            return
        }
         
        importAddresses(for: network, from: dict)
    }
    
    /// Get contract address for the specified network
    /// - Parameters:
    ///   - contract: Contract name with 0x prefix (e.g., "0xFlowToken")
    ///   - network: Network name ("mainnet" or "testnet")
    /// - Returns: Contract address if found, nil otherwise
    public func getAddress(for contract: String, on network: Flow.ChainID) -> String? {
        return addresses[network]?[contract]
    }
    
    /// Get all contract addresses for a network
    /// - Parameter network: Network name ("mainnet" or "testnet")
    /// - Returns: Dictionary of contract names to addresses
    public func getAddresses(for network: Flow.ChainID) -> [String: String] {
        return addresses[network] ?? [:]
    }
    
    /// Check if a contract exists on a network
    /// - Parameters:
    ///   - contract: Contract name with 0x prefix
    ///   - network: Network name
    /// - Returns: True if contract exists on the network
    public func contractExists(_ contract: String, on network: Flow.ChainID) -> Bool {
        return getAddress(for: contract, on: network) != nil
    }
    
    /// Get all available networks
    /// - Returns: Array of network names
    public func getNetworks() -> [Flow.ChainID] {
        return Array(addresses.keys)
    }
    
    /// Replace 0x placeholders in Cadence code with actual addresses
    /// - Parameters:
    ///   - code: Cadence code with 0x placeholders
    ///   - network: Network to use for address resolution
    /// - Returns: Code with resolved addresses
    public func resolveImports(in code: String, for network: Flow.ChainID) -> String {
        return code.replace(by: getAddresses(for: network))
    }
}
