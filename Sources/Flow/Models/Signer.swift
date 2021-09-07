//
//  Signer.swift
//
//
//  Created by lmcmz on 21/7/21.
//

import Foundation

protocol FlowSigner {
    var hasher: Hasher { get set }

    func sign(bytes: ByteArray) -> ByteArray

    func signWithDomain(bytes: ByteArray, domain: ByteArray) -> ByteArray

    func signAsUser(bytes: ByteArray) -> ByteArray

    func signAsTransaction(bytes: ByteArray) -> ByteArray
}

protocol FlowHasher {
    func hash(bytes: ByteArray) -> ByteArray
    func hashAsHexString(bytes: ByteArray) -> String
}

extension FlowHasher {
    func hashAsHexString(bytes: ByteArray) -> String {
        return hash(bytes: bytes).hexValue
    }
}

extension Flow {
    struct FlowPublicKey: BytesHolder, Equatable {
        var bytes: ByteArray

        init(hex: String) {
            bytes = hex.hexValue
        }

        init(bytes: [UInt8]) {
            self.bytes = bytes
        }
    }

    struct FlowCode: BytesHolder, Equatable {
        var bytes: ByteArray
    }
}
