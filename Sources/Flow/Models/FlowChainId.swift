//
//  File.swift
//
//
//  Created by lmcmz on 27/7/21.
//

import Foundation

extension Flow {
    public enum ChainId: CaseIterable, Hashable {
        case unknown
        case mainnet
        case testnet
        case canarynet
        case emulator
        case custom(name: String, endpoint: Endpoint)

        public static var allCases: [Flow.ChainId] = [.mainnet, .testnet, .canarynet, .emulator]

        var name: String {
            switch self {
            case .mainnet:
                return "flow-mainnet"
            case .testnet:
                return "flow-testnet"
            case .canarynet:
                return "flow-canarynet"
            case .emulator:
                return "flow-emulator"
            case .unknown:
                return "unknown"
            case let .custom(name, _):
                return name
            }
        }

        init(id: String) {
            self = ChainId.allCases.first { $0.name == id } ?? .unknown
        }

        public struct Endpoint: Hashable {
            let gRPCNode: String
            let port: Int
        }

        var defaultNode: Endpoint? {
            switch self {
            case .mainnet:
                return Endpoint(gRPCNode: "access.mainnet.nodes.onflow.org", port: 9000)
            case .testnet:
                return Endpoint(gRPCNode: "access.devnet.nodes.onflow.org", port: 9000)
            case .canarynet:
                return Endpoint(gRPCNode: "access.canary.nodes.onflow.org", port: 9000)
            case .emulator:
                return Endpoint(gRPCNode: "127.0.0.1", port: 9000)
            default:
                return nil
            }
        }

        public static func == (lhs: Flow.ChainId, rhs: Flow.ChainId) -> Bool {
            return lhs.name == rhs.name &&
                lhs.defaultNode?.gRPCNode == rhs.defaultNode?.gRPCNode &&
                lhs.defaultNode?.port == rhs.defaultNode?.port
        }
    }
}
