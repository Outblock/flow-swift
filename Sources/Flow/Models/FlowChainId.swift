//
//  FlowChainID
//
//  Copyright 2021 Zed Labs Pty Ltd
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

public extension Flow {
    /// Identification the enviroment of flow
    enum ChainID: CaseIterable, Hashable {
        /// Unknow enviroment as a fallback cause
        case unknown

        /// Mainnet enviroment
        /// Default node is `access.mainnet.nodes.onflow.org:9000`
        case mainnet

        /// Testnet enviroment
        /// Default node is `access.devnet.nodes.onflow.org:9000`
        case testnet

        /// Canarynet enviroment
        /// Default node is `access.canary.nodes.onflow.org:9000`
        case canarynet

        /// Emulator enviroment
        /// Default node is `127.0.0.1:9000`
        case emulator

        /// Custom chainID with custom `Endpoint`
        case custom(name: String, endpoint: Endpoint)

        /// List of other type chain id exclude custom type
        public static var allCases: [Flow.ChainID] = [.mainnet, .testnet, .canarynet, .emulator]

        /// Name of the chain id
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

        /// Endpoint information for gRPC node
        public struct Endpoint: Hashable, Equatable {
            public let node: String
            public let port: Int

            public init(node: String, port: Int) {
                self.node = node
                self.port = port
            }
        }

        /// Default node for `.mainnet, .testnet, .canarynet, .emulator`
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
