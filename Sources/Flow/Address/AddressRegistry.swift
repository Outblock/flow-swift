//
//  AddressRegistry.swift
//
//
//  Created by lmcmz on 23/7/21.
//

import Foundation

class AddressRegistry {
    var defaultChainId: Flow.ChainId = Flow.ChainId.mainnet

    private var scriptTokenDict = [Flow.ChainId: [String: Flow.Address]]()

    init() {
        registerDefaults()
    }

    func registerDefaults() {
        let addresses = [
            Flow.ChainId.emulator: [
                Flow.ScriptAddress.fungibleToken,
                Flow.ScriptAddress.flowToken,
                Flow.ScriptAddress.flowFees,
            ],
            Flow.ChainId.testnet: [
                Flow.ScriptAddress.fungibleToken,
                Flow.ScriptAddress.flowToken,
                Flow.ScriptAddress.flowFees,
                Flow.ScriptAddress.flowTablesTaking,
                Flow.ScriptAddress.lockedTokens,
                Flow.ScriptAddress.stakingProxy,
                Flow.ScriptAddress.nonFungibleToken,
            ],
            Flow.ChainId.mainnet: [
                Flow.ScriptAddress.fungibleToken,
                Flow.ScriptAddress.flowToken,
                Flow.ScriptAddress.flowFees,
                Flow.ScriptAddress.flowTablesTaking,
                Flow.ScriptAddress.lockedTokens,
                Flow.ScriptAddress.stakingProxy,
                Flow.ScriptAddress.nonFungibleToken,
            ],
        ]

        addresses.forEach { (chainId: Flow.ChainId, value: [Flow.ScriptAddress]) in
            value.forEach { scriptAddress in
                guard let address = scriptAddress.address(chain: chainId) else { return }
                register(chainId: chainId, contract: scriptAddress.rawValue, address: address)
            }
        }
    }

    func addressOf(contract: String) -> Flow.Address? {
        return addressOf(contract: contract, chainId: defaultChainId)
    }

    func addressOf(contract: String, chainId: Flow.ChainId) -> Flow.Address? {
        return scriptTokenDict[chainId]?.first { $0.key == contract }?.value
    }

    func processScript(script: String) -> String {
        return processScript(script: script, chainId: defaultChainId)
    }

    func processScript(script: String, chainId: Flow.ChainId) -> String {
        var ret = script
        scriptTokenDict[chainId]?.forEach {
            ret = ret.replacingOccurrences(of: $0.key,
                                           with: $0.value.base16Value.addHexPrefix())
        }
        return ret
    }

    func deregister(contract: String, chainId: Flow.ChainId? = nil) {
        var chains = Flow.ChainId.allCases
        if let chainId = chainId {
            chains = [chainId]
        }
        chains.forEach { scriptTokenDict[$0]?.removeValue(forKey: contract) }
    }

    func clear() {
        scriptTokenDict.removeAll()
    }

    func register(chainId: Flow.ChainId, contract: String, address: Flow.Address) {
        scriptTokenDict[chainId]?[contract] = address
    }
}
