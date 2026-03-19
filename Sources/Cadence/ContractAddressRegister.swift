//
//  ContractAddressRegister.swift
//  
//
//  Created by Nicholas Reich on 3/19/26.
//


public class ContractAddressRegister {
    private var addresses: [Flow.ChainID: [String: String]]

    public init() {
        addresses = [:]

        // Load from bundle (CommonCadence/addresses.json)
        guard let url = Bundle.module.url(
            forResource: "addresses",
            withExtension: "json",
            subdirectory: "CommonCadence"
        ),
        let data = try? Data(contentsOf: url) else {
            FlowLogger.shared.log(.warning, message: "Could not load addresses.json")
            return
        }

        do {
            let jsonDict = try JSONDecoder().decode(
                [String: [String: String]].self,
                from: data
            )

            // Convert network strings to Flow.ChainID
            for (networkStr, contractAddresses) in jsonDict {
                let network = Flow.ChainID(name: networkStr)
                addresses[network] = contractAddresses
            }
        } catch {
            FlowLogger.shared.log(.warning, message: "Could not decode addresses.json")
        }
    }

    /// Get address for contract on specific network
    public func getAddress(for contract: String, on network: Flow.ChainID) -> String? {
        return addresses[network]?[contract]
    }

    /// Get all addresses for network
    public func getAddresses(for network: Flow.ChainID) -> [String: String] {
        return addresses[network] ?? [:]
    }

    /// Replace 0x placeholders in Cadence code
    public func resolveImports(in code: String, for network: Flow.ChainID) -> String {
        return code.replace(by: getAddresses(for: network))
    }
}