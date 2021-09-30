//
//  File.swift
//
//
//  Created by lmcmz on 27/7/21.
//

import Foundation

extension Flow {
    public enum ChainID: CaseIterable, Hashable {
        case unknown
        case mainnet
        case testnet
        case canarynet
        case emulator
        case custom(name: String, endpoint: Endpoint)

        public static var allCases: [Flow.ChainID] = [.mainnet, .testnet, .canarynet, .emulator]

        public var name: String {
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

        public init(name: String) {
            self = ChainID.allCases.first { $0.name == name } ?? .unknown
        }

        public struct Endpoint: Hashable, Equatable {
            public let node: String
            public let port: Int

            public init(node: String, port: Int) {
                self.node = node
                self.port = port
            }
        }

        public var defaultNode: Endpoint {
            switch self {
            case .mainnet:
                return Endpoint(node: "access.mainnet.nodes.onflow.org", port: 9000)
            case .testnet:
                return Endpoint(node: "access.devnet.nodes.onflow.org", port: 9000)
            case .canarynet:
                return Endpoint(node: "access.canary.nodes.onflow.org", port: 9000)
            case .emulator:
                return Endpoint(node: "127.0.0.1", port: 9000)
            case let .custom(_, endpoint):
                return endpoint
            default:
                return Endpoint(node: "access.mainnet.nodes.onflow.org", port: 9000)
            }
        }

        public static func == (lhs: Flow.ChainID, rhs: Flow.ChainID) -> Bool {
            return lhs.name == rhs.name && lhs.defaultNode == rhs.defaultNode
        }
    }
}
