//
//  FlowAccount
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

import BigInt
import Foundation

public extension Flow {
    /// The data structure of account in Flow blockchain
    struct Account: Codable {
        /// The address of account in `Flow.Address` type
        public let address: Address

        /// The balance of account in `BigInt` type
        public let balance: BigInt

        /// The list of public key in `Flow.AccountKey` type
        public var keys: [AccountKey]

        /// The dictionary of all cadence contracts
        public var contracts: [String: Code]?

        public init(address: Flow.Address, balance: BigInt, keys: [Flow.AccountKey], contracts: [String: Flow.Code]) {
            self.address = address
            self.balance = balance
            self.keys = keys
            self.contracts = contracts
        }

        public init(address: Flow.Address, balance: UInt64, keys: [Flow.AccountKey], contracts: [String: Flow.Code]) {
            self.address = address
            self.balance = BigInt(balance)
            self.keys = keys
            self.contracts = contracts
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            address = try container.decode(Flow.Address.self, forKey: .address)
            let balanceString = try container.decode(String.self, forKey: .balance)
            balance = BigInt(balanceString) ?? BigInt(-1)
            keys = try container.decode([Flow.AccountKey].self, forKey: .keys)
            contracts = try? container.decode([String: Flow.Code].self, forKey: .contracts)
        }
    }

    /// The data structure of account key in flow account
    struct AccountKey: Codable {
        /// The index of key
        public var index: Int = -1

        /// The public key for
        public let publicKey: PublicKey

        /// The signature algorithm in `SignatureAlgorithm` type
        public let signAlgo: SignatureAlgorithm

        /// The hash algorithm in `HashAlgorithm` type
        public let hashAlgo: HashAlgorithm

        /// The weight for the account key
        public let weight: Decimal

        /// The sequence number for the key, it must be equal or larger than zero
        public var sequenceNumber: Int64 = -1

        /// Indicate the key is revoked or not
        public var revoked: Bool = false

        enum CodingKeys: String, CodingKey {
            case index
            case publicKey
            case signAlgo = "signingAlgorithm"
            case hashAlgo = "hashingAlgorithm"
            case weight
            case sequenceNumber
            case revoked
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let indexString = try container.decode(String.self, forKey: .index)
            index = Int(indexString) ?? -1
            publicKey = try container.decode(Flow.PublicKey.self, forKey: .publicKey)
            signAlgo = try container.decode(Flow.SignatureAlgorithm.self, forKey: .signAlgo)
            hashAlgo = try container.decode(Flow.HashAlgorithm.self, forKey: .hashAlgo)
            let weightString = try container.decode(String.self, forKey: .weight)
            weight = Decimal(string: weightString) ?? -1
            let sequenceNumberString = try container.decode(String.self, forKey: .sequenceNumber)
            sequenceNumber = Int64(sequenceNumberString) ?? -1
            revoked = try container.decode(Bool.self, forKey: .revoked)
        }

        public init(index: Int = -1,
                    publicKey: Flow.PublicKey,
                    signAlgo: SignatureAlgorithm,
                    hashAlgo: HashAlgorithm,
                    weight: Decimal,
                    sequenceNumber: Int64 = -1,
                    revoked: Bool = false)
        {
            self.index = index
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
