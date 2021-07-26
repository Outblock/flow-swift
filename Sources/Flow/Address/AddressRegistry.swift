//
//  AddressRegistry.swift
//
//
//  Created by lmcmz on 23/7/21.
//

import Foundation

class AddressRegistry {
    var defaultChainId: FlowChainId = FlowChainId.mainnet

    private var scriptTokenDict = [FlowChainId: [String: FlowAddress]]()

    init() {
        registerDefaults()
    }

    func registerDefaults() {
        let addresses = [
            FlowChainId.emulator: [
                FlowScriptAddress.fungibleToken,
                FlowScriptAddress.flowToken,
                FlowScriptAddress.flowFees,
            ],
            FlowChainId.testnet: [
                FlowScriptAddress.fungibleToken,
                FlowScriptAddress.flowToken,
                FlowScriptAddress.flowFees,
                FlowScriptAddress.flowTablesTaking,
                FlowScriptAddress.lockedTokens,
                FlowScriptAddress.stakingProxy,
                FlowScriptAddress.nonFungibleToken,
            ],
            FlowChainId.mainnet: [
                FlowScriptAddress.fungibleToken,
                FlowScriptAddress.flowToken,
                FlowScriptAddress.flowFees,
                FlowScriptAddress.flowTablesTaking,
                FlowScriptAddress.lockedTokens,
                FlowScriptAddress.stakingProxy,
                FlowScriptAddress.nonFungibleToken,
            ],
        ]

        addresses.forEach { (chainId: FlowChainId, value: [FlowScriptAddress]) in
            value.forEach { scriptAddress in
                guard let address = scriptAddress.address(chain: chainId) else { return }
                register(chainId: chainId, contract: scriptAddress.rawValue, address: address)
            }
        }
    }

    func addressOf(contract: String) -> FlowAddress? {
        return addressOf(contract: contract, chainId: defaultChainId)
    }

    func addressOf(contract: String, chainId: FlowChainId) -> FlowAddress? {
        return scriptTokenDict[chainId]?.first { $0.key == contract }?.value
    }

    func processScript(script: String) -> String {
        return processScript(script: script, chainId: defaultChainId)
    }

    func processScript(script: String, chainId: FlowChainId) -> String {
        var ret = script
        scriptTokenDict[chainId]?.forEach {
            ret = ret.replacingOccurrences(of: $0.key,
                                           with: $0.value.base16Value.addPrefixIfNeeded(prefix: "0x"))
        }
        return ret
    }

    func deregister(contract: String, chainId: FlowChainId? = nil) {
        var chains = FlowChainId.allCases
        if let chainId = chainId {
            chains = [chainId]
        }
        chains.forEach { scriptTokenDict[$0]?.removeValue(forKey: contract) }
    }

    func clear() {
        scriptTokenDict.removeAll()
    }

    func register(chainId: FlowChainId, contract: String, address: FlowAddress) {
        scriptTokenDict[chainId]?[contract] = address
    }
}
