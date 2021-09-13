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
        var contracts: [String: Code]

        init(value: Flow_Entities_Account) {
            address = Address(bytes: value.address.byteArray)
            balance = BigInt(value.balance)
            keys = value.keys.compactMap { AccountKey(value: $0) }
            contracts = value.contracts.compactMapValues { Code(bytes: $0.byteArray) }
        }
    }

    struct AccountKey {
        var id: Int = -1
        let publicKey: PublicKey
        let signAlgo: SignatureAlgorithm
        let hashAlgo: HashAlgorithm
        let weight: Int
        var sequenceNumber: Int = -1
        var revoked: Bool = false

        init(value: Flow_Entities_AccountKey) {
            id = Int(value.index)
            publicKey = PublicKey(bytes: value.publicKey.byteArray)
            signAlgo = SignatureAlgorithm(code: Int(value.signAlgo))
            hashAlgo = HashAlgorithm(code: Int(value.hashAlgo))
            weight = Int(value.weight)
            sequenceNumber = Int(value.sequenceNumber)
            revoked = value.revoked
        }

        init(id: Int = -1,
             publicKey: Flow.PublicKey,
             signAlgo: SignatureAlgorithm,
             hashAlgo: HashAlgorithm,
             weight: Int,
             sequenceNumber: Int = -1,
             revoked: Bool = false) {
            self.id = id
            self.publicKey = publicKey
            self.signAlgo = signAlgo
            self.hashAlgo = hashAlgo
            self.weight = weight
            self.sequenceNumber = sequenceNumber
            self.revoked = revoked
        }

        var encoded: Data? {
            let encodeList = [publicKey.bytes.data, signAlgo.code, hashAlgo.code, weight] as [Any]
            return RLP.encode(encodeList)
        }
    }
}
