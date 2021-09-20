//
//  Signer.swift
//
//
//  Created by lmcmz on 21/7/21.
//

import Foundation

protocol FlowSigner {
    var hasher: Hasher { get set }

    func sign(bytes: Bytes) -> Bytes

    func signWithDomain(bytes: Bytes, domain: Bytes) -> Bytes

    func signAsUser(bytes: Bytes) -> Bytes

    func signAsTransaction(bytes: Bytes) -> Bytes
}

protocol FlowHasher {
    func hash(bytes: Bytes) -> Bytes
    func hashAsHexString(bytes: Bytes) -> String
}

extension FlowHasher {
    func hashAsHexString(bytes: Bytes) -> String {
        return hash(bytes: bytes).hexValue
    }
}

extension Flow {
    struct PublicKey: FlowEntity, Equatable {
        var data: Data

        init(hex: String) {
            data = hex.hexValue.data
        }

        init(data: Data) {
            self.data = data
        }

        init(bytes: [UInt8]) {
            data = bytes.data
        }
    }

    struct Code: FlowEntity, Equatable {
        var data: Data
    }
}
