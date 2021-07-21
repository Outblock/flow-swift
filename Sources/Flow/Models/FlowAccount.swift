//
//  File.swift
//
//
//  Created by lmcmz on 21/7/21.
//

import BigInt
import Foundation

struct FlowAccount {
    let address: FlowAddress
    let balance: BigInt
    var keys: [FlowAccountKey]
    var contracts: [String: FlowCode]

    init(value: Flow_Entities_Account) {
        address = FlowAddress(bytes: value.address.byteArray)
        balance = BigInt(value.balance)
        keys = value.keys.compactMap { FlowAccountKey(value: $0) }
        contracts = value.contracts.compactMapValues { FlowCode(bytes: $0.byteArray) }
    }
}

struct FlowAccountKey {
    var id: Int = -1
    let publicKey: FlowPublicKey
    let signAlgo: SignatureAlgorithm
    let hashAlgo: HashAlgorithm
    let weight: Int
    var sequenceNumber: Int = -1
    var revoked: Bool = false

    init(value: Flow_Entities_AccountKey) {
        id = Int(value.index)
        publicKey = FlowPublicKey(bytes: value.publicKey.byteArray)
        signAlgo = SignatureAlgorithm(code: Int(value.signAlgo))
        hashAlgo = HashAlgorithm(code: Int(value.hashAlgo))
        weight = Int(value.weight)
        sequenceNumber = Int(value.sequenceNumber)
        revoked = value.revoked
    }
}
