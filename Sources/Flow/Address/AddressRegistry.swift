//
//  AddressRegistry.swift
//
//
//  Created by lmcmz on 23/7/21.
//

import Foundation

class AddressRegistry {
    var defaultChainId = Flow.shared.defaultChainId

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

    func clear() {
        scriptTokenDict.removeAll()
    }

    func register(chainId: FlowChainId, contract: String, address: FlowAddress) {
        scriptTokenDict[chainId]?[contract] = address
    }
}
