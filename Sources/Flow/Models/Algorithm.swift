//
//  Algorithm.swift
//
//
//  Created by lmcmz on 21/7/21.
//

import Foundation

enum SignatureAlgorithm: CaseIterable {
    case unknown
    case ECDSA_P256
    case ECDSA_SECP256k1

    var algorithm: String {
        switch self {
        case .unknown:
            return "unknown"
        case .ECDSA_P256:
            return "ECDSA"
        case .ECDSA_SECP256k1:
            return "ECDSA"
        }
    }

    var id: String {
        switch self {
        case .unknown:
            return "unknown"
        case .ECDSA_P256:
            return "ECDSA_P256"
        case .ECDSA_SECP256k1:
            return "ECDSA_secp256k1"
        }
    }

    var code: Int {
        switch self {
        case .unknown:
            return -1
        case .ECDSA_P256:
            return 2
        case .ECDSA_SECP256k1:
            return 3
        }
    }

    var index: Int {
        switch self {
        case .unknown:
            return 0
        case .ECDSA_P256:
            return 1
        case .ECDSA_SECP256k1:
            return 2
        }
    }

    var curve: String {
        switch self {
        case .unknown:
            return "unknown"
        case .ECDSA_P256:
            return "P-256"
        case .ECDSA_SECP256k1:
            return "secp256k1"
        }
    }

    init(code: Int) {
        self = SignatureAlgorithm.allCases.first { $0.code == code } ?? .unknown
    }

    init(cadence index: Int) {
        self = SignatureAlgorithm.allCases.first { $0.index == index } ?? .unknown
    }
}

enum HashAlgorithm: CaseIterable {
    case unknown
    case SHA2_256
    case SHA2_384
    case SHA3_256
    case SHA3_384

    var algorithm: String {
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

    var outputSize: Int {
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

    var id: String {
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

    var code: Int {
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

    var index: Int {
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

    init(code: Int) {
        self = HashAlgorithm.allCases.first { $0.code == code } ?? .unknown
    }

    init(cadence index: Int) {
        self = HashAlgorithm.allCases.first { $0.index == index } ?? .unknown
    }
}
