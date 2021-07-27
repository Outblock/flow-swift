//
//  FlowAccount.swift
//
//
//  Created by lmcmz on 21/7/21.
//

import BigInt
import Foundation

extension Flow {
    struct Account {
        let address: Address
        let balance: BigInt
        var keys: [AccountKey]
        var contracts: [String: FlowCode]

        init(value: Flow_Entities_Account) {
            address = Address(bytes: value.address.byteArray)
            balance = BigInt(value.balance)
            keys = value.keys.compactMap { AccountKey(value: $0) }
            contracts = value.contracts.compactMapValues { FlowCode(bytes: $0.byteArray) }
        }
    }

    struct AccountKey {
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
}
