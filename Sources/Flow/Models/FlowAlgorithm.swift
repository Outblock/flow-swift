//
//  FlowAlgorithm
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
    /// The signature algorithm supported by flow which include `.ECDSA_P256` and `.ECDSA_SECP256k1`
    enum SignatureAlgorithm: String, CaseIterable, Codable {
        case unknown
        case ECDSA_P256
        case ECDSA_SECP256k1 = "ECDSA_secp256k1"

        public var algorithm: String {
            switch self {
            case .unknown:
                return "unknown"
            case .ECDSA_P256:
                return "ECDSA"
            case .ECDSA_SECP256k1:
                return "ECDSA"
            }
        }

        public var id: String {
            switch self {
            case .unknown:
                return "unknown"
            case .ECDSA_P256:
                return "ECDSA_P256"
            case .ECDSA_SECP256k1:
                return "ECDSA_secp256k1"
            }
        }

        public var code: Int {
            switch self {
            case .unknown:
                return -1
            case .ECDSA_P256:
                return 2
            case .ECDSA_SECP256k1:
                return 3
            }
        }

        public var index: Int {
            switch self {
            case .unknown:
                return 0
            case .ECDSA_P256:
                return 1
            case .ECDSA_SECP256k1:
                return 2
            }
        }

        public var curve: String {
            switch self {
            case .unknown:
                return "unknown"
            case .ECDSA_P256:
                return "P-256"
            case .ECDSA_SECP256k1:
                return "secp256k1"
            }
        }

        public init(code: Int) {
            self = SignatureAlgorithm.allCases.first { $0.code == code } ?? .unknown
        }

        public init(index: Int) {
            self = SignatureAlgorithm.allCases.first { $0.index == index } ?? .unknown
        }
    }

    /// The hash algorithm supported by flow which include `.SHA2_256`, `.SHA2_384`, `.SHA3_256` and `.SHA3_384`
    enum HashAlgorithm: String, CaseIterable, Codable {
        case unknown
        case SHA2_256
        case SHA2_384
        case SHA3_256
        case SHA3_384

        public var algorithm: String {
            switch self {
            case .unknown:
                return "unknown"
            case .SHA2_256:
                return "SHA2-256"
            case .SHA2_384:
                return "SHA2-384"
            case .SHA3_256:
                return "SHA3-256"
            case .SHA3_384:
                return "SHA3-384"
            }
        }

        public var outputSize: Int {
            switch self {
            case .unknown:
                return -1
            case .SHA2_256:
                return 256
            case .SHA2_384:
                return 384
            case .SHA3_256:
                return 256
            case .SHA3_384:
                return 384
            }
        }

        public var id: String {
            switch self {
            case .unknown:
                return "unknown"
            case .SHA2_256:
                return "SHA256withECDSA"
            case .SHA2_384:
                return "SHA384withECDSA"
            case .SHA3_256:
                return "SHA3-256withECDSA"
            case .SHA3_384:
                return "SHA3-384withECDSA"
            }
        }

        public var code: Int {
            switch self {
            case .unknown:
                return -1
            case .SHA2_256:
                return 1
            case .SHA2_384:
                return 1
            case .SHA3_256:
                return 3
            case .SHA3_384:
                return 3
            }
        }

        public var index: Int {
            switch self {
            case .unknown:
                return 0
            case .SHA2_256:
                return 1
            case .SHA2_384:
                return 2
            case .SHA3_256:
                return 3
            case .SHA3_384:
                return 4
            }
        }

        public init(code: Int) {
            self = HashAlgorithm.allCases.first { $0.code == code } ?? .unknown
        }

        public init(cadence index: Int) {
            self = HashAlgorithm.allCases.first { $0.index == index } ?? .unknown
        }
    }
}
