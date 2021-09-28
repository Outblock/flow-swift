//
//  File.swift
//  File
//
//  Created by lmcmz on 29/9/21.
//

import CryptoKit
import Flow
import Foundation

struct ECDSA_P256_Signer: FlowSigner {
    var address: Flow.Address
    var keyIndex: Int
    var hash: Flow.HashAlgorithm = .SHA2_256
    var signature: Flow.SignatureAlgorithm = .ECDSA_P256

    var privateKey: P256.Signing.PrivateKey

    init(address: Flow.Address, keyIndex: Int, privateKey: P256.Signing.PrivateKey) {
        self.address = address
        self.keyIndex = keyIndex
        self.privateKey = privateKey
    }

    func signature(signableData: Data) throws -> Data {
        do {
            return try privateKey.signature(for: signableData).rawRepresentation
        } catch {
            throw error
        }
    }
}
