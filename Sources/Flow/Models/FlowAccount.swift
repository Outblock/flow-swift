//
//  FlowAccount
//
//  Copyright 2021 Zed Labs Pty Ltd
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

import BigInt
import Foundation

extension Flow {
    /// The data structure of account in Flow blockchain
    public struct Account {
        /// The address of account in `Flow.Address` type
        public let address: Address

        /// The balance of account in `BigInt` type
        public let balance: BigInt

        /// The list of public key in `Flow.AccountKey` type
        public var keys: [AccountKey]

        /// The dictionary of all cadence contracts
        public var contracts: [String: Code]

        init(value: Flow_Entities_Account) {
            address = Address(bytes: value.address.bytes)
            balance = BigInt(value.balance)
            keys = value.keys.compactMap { AccountKey(value: $0) }
            contracts = value.contracts.compactMapValues { Code(data: $0) }
        }
    }

    /// The data structure of account key in flow account
    public struct AccountKey {
        /// The index of key
        public var id: Int = -1

        /// The public key for
        public let publicKey: PublicKey

        /// The signature algorithm in `SignatureAlgorithm` type
        public let signAlgo: SignatureAlgorithm

        /// The hash algorithm in `HashAlgorithm` type
        public let hashAlgo: HashAlgorithm

        /// The weight for the account key
        public let weight: Int

        /// The sequence number for the key, it must be equal or larger than zero
        public var sequenceNumber: Int = -1

        // TODO: add doc here
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

        /// Encode the account key with RLP encoding
        public var encoded: Data? {
            let encodeList = [publicKey.bytes.data, signAlgo.code, hashAlgo.code, weight] as [Any]
            return RLP.encode(encodeList)
        }
    }
}
