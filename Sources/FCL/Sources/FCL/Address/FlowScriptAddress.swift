//
//  FlowScriptAddress.swift
//
//
//  Created by lmcmz on 23/7/21.
//

import FlowFoundation
import Foundation

extension FCL {
    enum ScriptAddress: String {
        case fungibleToken = "0xFUNGIBLETOKEN"
        case flowToken = "0xFLOWTOKEN"
        case flowFees = "0xFLOWFEES"
        case flowTablesTaking = "0xFLOWTABLESTAKING"
        case lockedTokens = "0xLOCKEDTOKENS"
        case stakingProxy = "0xSTAKINGPROXY"
        case nonFungibleToken = "0xNONFUNGIBLETOKEN"

        func address(chain: Flow.ChainId) -> Flow.Address? {
            switch (self, chain) {
            // Mainnet
            case (.fungibleToken, .mainnet):
                return Flow.Address(hex: "0xf233dcee88fe0abe")
            case (.flowToken, .mainnet):
                return Flow.Address(hex: "0x1654653399040a61")
            case (.flowFees, .mainnet):
                return Flow.Address(hex: "0xf919ee77447b7497")
            case (.flowTablesTaking, .mainnet):
                return Flow.Address(hex: "0x8624b52f9ddcd04a")
            case (.lockedTokens, .mainnet):
                return Flow.Address(hex: "0x8d0e87b65159ae63")
            case (.stakingProxy, .mainnet):
                return Flow.Address(hex: "0x62430cf28c26d095")
            case (.nonFungibleToken, .mainnet):
                return Flow.Address(hex: "0x1d7e57aa55817448")
            // Testnet
            case (.fungibleToken, .testnet):
                return Flow.Address(hex: "0x9a0766d93b6608b7")
            case (.flowToken, .testnet):
                return Flow.Address(hex: "0x7e60df042a9c0868")
            case (.flowFees, .testnet):
                return Flow.Address(hex: "0x912d5440f7e3769e")
            case (.flowTablesTaking, .testnet):
                return Flow.Address(hex: "0x9eca2b38b18b5dfe")
            case (.lockedTokens, .testnet):
                return Flow.Address(hex: "0x95e019a17d0e23d7")
            case (.stakingProxy, .testnet):
                return Flow.Address(hex: "0x7aad92e5a0715d21")
            case (.nonFungibleToken, .testnet):
                return Flow.Address(hex: "0x631e88ae7f1d7c20")
            // Emulator
            case (.fungibleToken, .emulator):
                return Flow.Address(hex: "0xee82856bf20e2aa6")
            case (.flowToken, .emulator):
                return Flow.Address(hex: "0x0ae53cb6e3f42a79")
            case (.flowFees, .emulator):
                return Flow.Address(hex: "0xe5a8b7f23e8b548f")

            default:
                return nil
            }
        }
    }
}
