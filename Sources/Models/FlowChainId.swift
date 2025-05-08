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

        /// Canarynet enviroment
        /// Default node is `access.canary.nodes.onflow.org:9000`
        case canarynet
        
        /// Canarynet enviroment
        /// Default node is `access.crescendo.nodes.onflow.org:9000`
        /// HTTP node `https://rest-crescendo.onflow.org/`
        case crescendo
        
        /// Previewnet enviroment
        /// Default node is `access-previewnet.onflow.org/:9000`
        /// HTTP node `https://rest-previewnet.onflow.org/`
        case previewnet
        /// Emulator enviroment
        /// Default node is `127.0.0.1:9000`
        case emulator

        /// Custom chainID with custom `Endpoint`
        case custom(name: String, transport: Flow.Transport)

        /// List of other type chain id exclude custom type
        public static var allCases: [Flow.ChainID] = [.mainnet, .testnet, .canarynet, .crescendo,.previewnet, .emulator]

        /// Name of the chain id
        public var name: String {
            switch self {
            case .mainnet:
                return "mainnet"
            case .testnet:
                return "testnet"
            case .crescendo:
                return "crescendo"
            case .previewnet:
                return "previewnet"
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
            case .crescendo:
                return .HTTP(URL(string: "https://rest-crescendo.onflow.org/")!)
            case .previewnet:
                return .HTTP(URL(string: "https://rest-previewnet.onflow.org/")!)
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
            case .crescendo:
                return .gRPC(.init(node: "access.crescendo.nodes.onflow.org", port: 9000))
            case .previewnet:
                return .gRPC(.init(node: "access-previewnet.onflow.org", port: 9000))
            case .emulator:
                return .gRPC(.init(node: "127.0.0.1", port: 9000))
            case let .custom(_, endpoint):
                return endpoint
            default:
                return .gRPC(.init(node: "access.mainnet.nodes.onflow.org", port: 9000))
            }
        }
        
        public var defaultWebSocketNode: Flow.Transport? {
            switch self {
            case .mainnet:
                return .websocket(URL(string: "wss://rest-mainnet.onflow.org/v1/ws")!)
            case .testnet:
                return .websocket(URL(string: "wss://rest-testnet.onflow.org/v1/ws")!)
            default:
                return nil
            }
        }

        // TODO: Support Custom Node encode & decode
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

extension Flow.ChainID: RawRepresentable {
    public var rawValue: String {
        name
    }
    
    public init?(rawValue: String) {
        self.init(name: rawValue)
    }
}
