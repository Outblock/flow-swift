//
//  FlowAccount.swift
//
//
//  Created by lmcmz on 21/7/21.
//

import BigInt
import Foundation

extension Flow {
    public struct Account {
        public let address: Address
        public let balance: BigInt
        public var keys: [AccountKey]
        public var contracts: [String: Code]

        init(value: Flow_Entities_Account) {
            address = Address(bytes: value.address.bytes)
            balance = BigInt(value.balance)
            keys = value.keys.compactMap { AccountKey(value: $0) }
            contracts = value.contracts.compactMapValues { Code(data: $0) }
        }
    }

    public struct AccountKey {
        public var id: Int = -1
        public let publicKey: PublicKey
        public let signAlgo: SignatureAlgorithm
        public let hashAlgo: HashAlgorithm
        public let weight: Int
        public var sequenceNumber: Int = -1
        public var revoked: Bool = false

        init(value: Flow_Entities_AccountKey) {
            id = Int(value.index)
            publicKey = PublicKey(bytes: value.publicKey.bytes)
            signAlgo = SignatureAlgorithm(code: Int(value.signAlgo))
            hashAlgo = HashAlgorithm(code: Int(value.hashAlgo))
            weight = Int(value.weight)
            sequenceNumber = Int(value.sequenceNumber)
            revoked = value.revoked
        }

        public init(id: Int = -1,
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

        public var encoded: Data? {
            let encodeList = [publicKey.bytes.data, signAlgo.code, hashAlgo.code, weight] as [Any]
            return RLP.encode(encodeList)
        }
    }
}
