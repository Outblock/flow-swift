//
//  FlowChainID
//
//  Copyright 2022 Outblock Pty Ltd
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
    enum ChainID: CaseIterable, Hashable, Codable {
        /// Unknow enviroment as a fallback cause
        case unknown

        /// Mainnet enviroment
        /// Default gRPC node is `access.mainnet.nodes.onflow.org:9000`
        /// HTTP node `https://rest-mainnet.onflow.org/`
        case mainnet

        /// Testnet enviroment
        /// Default gRPC node is `access.devnet.nodes.onflow.org:9000`
        /// HTTP node `https://rest-mainnet.onflow.org/`
        case testnet

        /// Testnet enviroment
        /// Default gRPC node is `access.sandboxnet.nodes.onflow.org:9000`
        /// HTTP node `https://rest-sandboxnet.onflow.org/`
        case sandboxnet

        /// Canarynet enviroment
        /// Default node is `access.canary.nodes.onflow.org:9000`
        case canarynet

        /// Emulator enviroment
        /// Default node is `127.0.0.1:9000`
        case emulator

        /// Custom chainID with custom `Endpoint`
        case custom(name: String, transport: Flow.Transport)

        /// List of other type chain id exclude custom type
        public static var allCases: [Flow.ChainID] = [.mainnet, .testnet, .canarynet, .sandboxnet, .emulator]

        /// Name of the chain id
        public var name: String {
            switch self {
            case .mainnet:
                return "mainnet"
            case .testnet:
                return "testnet"
            case .sandboxnet:
                return "sandboxnet"
            case .canarynet:
                return "canarynet"
            case .emulator:
                return "emulator"
            case .unknown:
                return "unknown"
            case let .custom(name, _):
                return name
            }
        }

        /// Value from the access API
        /// https://rest-mainnet.onflow.org/v1/network/parameters
        /// https://rest-testnet.onflow.org/v1/network/parameters
        public var value: String {
            "flow-\(name)"
        }

        public init(name: String) {
            self = ChainID.allCases.first { $0.name == name || $0.value == name } ?? .unknown
        }

        public static func == (lhs: Flow.ChainID, rhs: Flow.ChainID) -> Bool {
            return lhs.name == rhs.name && lhs.defaultNode == rhs.defaultNode
        }

        public var defaultHTTPNode: Flow.Transport {
            switch self {
            case .mainnet:
                return .HTTP(URL(string: "https://rest-mainnet.onflow.org/")!)
            case .testnet:
                return .HTTP(URL(string: "https://rest-testnet.onflow.org/")!)
            case .emulator:
                return .HTTP(URL(string: "http://127.0.0.1:8888/")!)
            case .sandboxnet:
                return .HTTP(URL(string: "https://rest-sandboxnet.onflow.org/")!)
            case let .custom(_, transport):
                return transport
            default:
                return .HTTP(URL(string: "https://rest-testnet.onflow.org/")!)
            }
        }

        /// Default node for `.mainnet, .testnet, .canarynet, .emulator`
        public var defaultNode: Flow.Transport {
            switch self {
            case .mainnet:
                return .gRPC(.init(node: "access.mainnet.nodes.onflow.org", port: 9000))
            case .testnet:
                return .gRPC(.init(node: "access.devnet.nodes.onflow.org", port: 9000))
            case .canarynet:
                return .gRPC(.init(node: "access.canary.nodes.onflow.org", port: 9000))
            case .sandboxnet:
                return .gRPC(.init(node: "access.sandboxnet.nodes.onflow.org", port: 9000))
            case .emulator:
                return .gRPC(.init(node: "127.0.0.1", port: 9000))
            case let .custom(_, endpoint):
                return endpoint
            default:
                return .gRPC(.init(node: "access.mainnet.nodes.onflow.org", port: 9000))
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(name)
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            self.init(name: string)
        }
    }
}
