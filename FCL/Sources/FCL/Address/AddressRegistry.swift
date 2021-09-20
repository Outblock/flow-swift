//
//  AddressRegistry.swift
//
//
//  Created by lmcmz on 23/7/21.
//

import FlowFoundation
import Foundation

public class AddressRegistry {
    var defaultChainId: Flow.ChainId = Flow.ChainId.mainnet

    private var scriptTokenDict = [Flow.ChainId: [String: Flow.Address]]()

    init() {
        registerDefaults()
    }

    func registerDefaults() {
        let addresses = [
            Flow.ChainId.emulator: [
                FCL.ScriptAddress.fungibleToken,
                FCL.ScriptAddress.flowToken,
                FCL.ScriptAddress.flowFees,
            ],
            Flow.ChainId.testnet: [
                FCL.ScriptAddress.fungibleToken,
                FCL.ScriptAddress.flowToken,
                FCL.ScriptAddress.flowFees,
                FCL.ScriptAddress.flowTablesTaking,
                FCL.ScriptAddress.lockedTokens,
                FCL.ScriptAddress.stakingProxy,
                FCL.ScriptAddress.nonFungibleToken,
            ],
            Flow.ChainId.mainnet: [
                FCL.ScriptAddress.fungibleToken,
                FCL.ScriptAddress.flowToken,
                FCL.ScriptAddress.flowFees,
                FCL.ScriptAddress.flowTablesTaking,
                FCL.ScriptAddress.lockedTokens,
                FCL.ScriptAddress.stakingProxy,
                FCL.ScriptAddress.nonFungibleToken,
            ],
        ]

        addresses.forEach { (chainId: Flow.ChainId, value: [FCL.ScriptAddress]) in
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

    func processScript(script: String, chainId _: Flow.ChainId) -> String {
        var ret = script
//        scriptTokenDict[chainId]?.forEach {
//            ret = ret.replacingOccurrences(of: $0.key,
//                                           with: $0.value.hexValue.addHexPrefix())
//        }
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
