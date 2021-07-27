//
//  File.swift
//
//
//  Created by lmcmz on 27/7/21.
//

import Foundation

extension Flow {
    enum ChainId: String, CaseIterable {
        case unknown
        case mainnet = "flow-mainnet"
        case testnet = "flow-testnet"
        case canarynet = "flow-canarynet"
        case emulator = "flow-emulator"

        init(id: String) {
            self = ChainId.allCases.first { $0.rawValue == id } ?? .unknown
        }

        struct Endpoint {
            let gRPCNode: String
            let port: Int
        }

        var defaultNode: Endpoint? {
            switch self {
            case .mainnet:
                return Endpoint(gRPCNode: "access-mainnet-beta.onflow.org", port: 9000)
            case .testnet:
                return Endpoint(gRPCNode: "access.devnet.nodes.onflow.org", port: 9000)
            case .canarynet:
                return Endpoint(gRPCNode: "access.canary.nodes.onflow.org", port: 9000)
            default:
                return nil
            }
        }
    }
}
