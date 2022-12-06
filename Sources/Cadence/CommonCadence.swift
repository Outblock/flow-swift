//
//  CommonCadence
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
import Combine
import Foundation

extension Flow {
    /// A collection of common operations in Flow
    /// It includes `addKeyToAccount`, `addContractToAccount`, `createAccount`, `removeAccountKeyByIndex`, `removeContractFromAccount`, `updateContractOfAccount`
    enum CommonCadence {
        /// The cadence code for adding key to account
        static let addKeyToAccount = """
            import Crypto
            transaction(publicKey: String, signatureAlgorithm: UInt8, hashAlgorithm: UInt8, weight: UFix64) {
                prepare(signer: AuthAccount) {
                    let key = PublicKey(
                        publicKey: publicKey.decodeHex(),
                        signatureAlgorithm: SignatureAlgorithm(rawValue: signatureAlgorithm)!
                    )
                    signer.keys.add(
                        publicKey: key,
                        hashAlgorithm: HashAlgorithm(rawValue: hashAlgorithm)!,
                        weight: weight
                    )
                }
            }
        """

        /// The cadence code for adding contract to account
        static let addContractToAccount = """
            transaction(name: String, code: String) {
                prepare(signer: AuthAccount) {
                    signer.contracts.add(name: name, code: code.decodeHex())
                }
            }
        """

        /// The cadence code for creating account
        static let createAccount = """
            import Crypto
            transaction(publicKey: String, signatureAlgorithm: UInt8, hashAlgorithm: UInt8, weight: UFix64, contracts: {String: String}) {
                prepare(signer: AuthAccount) {
                    let key = PublicKey(
                        publicKey: publicKey.decodeHex(),
                        signatureAlgorithm: SignatureAlgorithm(rawValue: signatureAlgorithm)!
                    )
                    let account = AuthAccount(payer: signer)
                    account.keys.add(
                        publicKey: key,
                        hashAlgorithm: HashAlgorithm(rawValue: hashAlgorithm)!,
                        weight: weight
                    )

                    for contract in contracts.keys {
                        acct.contracts.add(name: contract, code: contracts[contract]!.decodeHex())
                    }
                }
            }
        """

        /// The cadence code for removing account key by index
        static let removeAccountKeyByIndex = """
            transaction(keyIndex: Int) {
                prepare(signer: AuthAccount) {
                    signer.removePublicKey(keyIndex)
                }
            }
        """

        /// The cadence code for removing contract from account
        static let removeContractFromAccount = """
            transaction(name: String) {
                prepare(signer: AuthAccount) {
                    signer.contracts.remove(name: name)
                }
            }
        """

        /// The cadence code for updating contract from account
        static let updateContractOfAccount = """
            transaction(name: String, code: String) {
                prepare(signer: AuthAccount) {
                    signer.contracts.update__experimental(name: name, code: code.decodeHex())
                }
            }
        """

        static let accountStorage = """
        pub struct StorageInfo {
            pub let capacity: UInt64
            pub let used: UInt64
            pub let available: UInt64

            init(capacity: UInt64, used: UInt64, available: UInt64) {
                self.capacity = capacity
                self.used = used
                self.available = available
            }
        }

        pub fun main(addr: Address): StorageInfo {
          let acct = getAccount(addr)
          return StorageInfo(capacity: acct.storageCapacity,
                            used: acct.storageUsed,
                            available: acct.storageCapacity - acct.storageUsed)
        }
        """

        /// The cadence code to verify user signature
        static let verifyUserSignature = """
        import Crypto

        pub fun main(
          message: String,
          rawPublicKeys: [String],
          weights: [UFix64],
          signAlgos: [UInt8],
          hashAlgos: [UInt8],
          signatures: [String],
        ): Bool {

          let keyList = Crypto.KeyList()

          var i = 0
          for rawPublicKey in rawPublicKeys {
            keyList.add(
              PublicKey(
                publicKey: rawPublicKey.decodeHex(),
                signatureAlgorithm: SignatureAlgorithm(rawValue: signAlgos[i])!
              ),
              hashAlgorithm: HashAlgorithm(rawValue: hashAlgos[i])!,
              weight: weights[i],
            )
            i = i + 1
          }

          let signatureSet: [Crypto.KeyListSignature] = []

          var j = 0
          for signature in signatures {
            signatureSet.append(
              Crypto.KeyListSignature(
                keyIndex: j,
                signature: signature.decodeHex()
              )
            )
            j = j + 1
          }

          let signedData = message.decodeHex()

          return keyList.verify(
            signatureSet: signatureSet,
            signedData: signedData
          )
        }
        """
    }
}

public extension Flow {
    /// Add public key to account
    /// - parameters:
    ///     - address: The address of Account in `Flow.Address` type.
    ///     - accountKey: The public key to be added in `Flow.AccountKey` type.
    ///     - signers: A list of `FlowSigner` will sign the transaction.
    /// - returns: A future value will receive transaction id  in `Flow.ID` value.
    func addKeyToAccount(address: Flow.Address, accountKey: Flow.AccountKey, signers: [FlowSigner]) async throws -> Flow.ID {
        return try await sendTransaction(signers: signers) {
            cadence {
                CommonCadence.addKeyToAccount
            }
            arguments {
                [
                    .string(accountKey.publicKey.hex),
                    .uint8(UInt8(accountKey.signAlgo.index)),
                    .uint8(UInt8(accountKey.hashAlgo.code)),
                    .ufix64(1000),
                ]
            }
            proposer {
                address
            }
            authorizers {
                address
            }
        }
    }

    /// Add cadence contract to account
    /// - parameters:
    ///     - address: The address of Account in `Flow.Address` type.
    ///     - contractName: The name of the cadence script.
    ///     - code: Cadence code of the contract.
    ///     - signers: A list of `FlowSigner` will sign the transaction.
    /// - returns: A future value will receive transaction id  in `Flow.ID` value.
    func addContractToAccount(address: Flow.Address,
                              contractName: String,
                              code: String,
                              signers: [FlowSigner]) async throws -> Flow.ID
    {
        let script = Flow.Script(text: code)
        return try await sendTransaction(signers: signers) {
            cadence {
                CommonCadence.addContractToAccount
            }
            arguments {
                [.init(value: .string(contractName)), .init(value: .string(script.hex))]
            }
            proposer {
                address
            }
            authorizers {
                address
            }
        }
    }

    /// Create a account in Flow blockchain
    /// - parameters:
    ///     - address: The proposer address of Account in `Flow.Address` type.
    ///     - publicKeys: A list of publicKeys to be added in the new account.
    ///     - contracts: A collection of cadence contracts, contract name is the `key`, cadence code is the `value`.
    ///     - signers: A list of `FlowSigner` will sign the transaction.
    /// - returns: A future value will receive transaction id  in `Flow.ID` value.
    func createAccount(address: Flow.Address,
                       accountKey: Flow.AccountKey,
                       contracts: [String: String] = [:],
                       signers: [FlowSigner]) async throws -> Flow.ID
    {
        let contractArg = contracts.compactMap { name, cadence in
            Flow.Argument.Dictionary(key: .init(value: .string(name)),
                                     value: .init(value: .string(Flow.Script(text: cadence).hex)))
        }

        return try await sendTransaction(signers: signers) {
            cadence {
                CommonCadence.createAccount
            }
            arguments {
                [
                    .string(accountKey.publicKey.hex),
                    .uint8(UInt8(accountKey.signAlgo.index)),
                    .uint8(UInt8(accountKey.hashAlgo.code)),
                    .ufix64(1000),
                    .dictionary(contractArg),
                ]
            }
            proposer {
                address
            }
            authorizers {
                address
            }
        }
    }

    /// Removing a public key from an account
    /// - parameters:
    ///     - address: The proposer address of Account in `Flow.Address` type.
    ///     - publicKeys: A list of publicKeys to be added in the new account.
    ///     - contracts: A collection of cadence contracts, contract name is the `key`, cadence code is the `value`.
    ///     - signers: A list of `FlowSigner` will sign the transaction.
    /// - returns: A future value will receive transaction id  in `Flow.ID` value.
    func removeAccountKeyByIndex(address: Flow.Address,
                                 keyIndex: Int,
                                 signers: [FlowSigner]) async throws -> Flow.ID
    {
        return try await sendTransaction(signers: signers) {
            cadence {
                CommonCadence.removeAccountKeyByIndex
            }
            arguments {
                [.int(keyIndex)]
            }
            proposer {
                address
            }
            authorizers {
                address
            }
        }
    }

    func isAddressVaildate(address: Flow.Address, network _: Flow.ChainID = .mainnet) async -> Bool {
        do {
            _ = try await flow.accessAPI.getAccountAtLatestBlock(address: address)
            return true
        } catch {
            return false
        }
    }

    func isAddressVaildate(address: String, network: Flow.ChainID = .mainnet) async -> Bool {
        return await isAddressVaildate(address: Address(hex: address), network: network)
    }

    func removeContractFromAccount(address: Flow.Address,
                                   contractName: String,
                                   signers: [FlowSigner]) async throws -> Flow.ID
    {
        return try await sendTransaction(signers: signers) {
            cadence {
                CommonCadence.removeContractFromAccount
            }
            arguments {
                [.string(contractName)]
            }
            proposer {
                address
            }
            authorizers {
                address
            }
        }
    }

    func updateContractOfAccount(address: Flow.Address,
                                 contractName: String,
                                 script: String,
                                 signers: [FlowSigner]) async throws -> Flow.ID
    {
        return try await sendTransaction(signers: signers) {
            cadence {
                CommonCadence.updateContractOfAccount
            }
            arguments {
                [.string(contractName), .string(Flow.Script(text: script).hex)]
            }
            proposer {
                address
            }
            authorizers {
                address
            }
        }
    }

    struct StorageInfo: Codable {
        public let capacity: UInt64
        public let used: UInt64
        public let available: UInt64
    }

    func checkStorageInfo(address: Flow.Address) async throws -> StorageInfo {
        return try await flow.executeScriptAtLatestBlock(cadence: CommonCadence.accountStorage, arguments: [.address(address)]).decode()
    }

    func verifyUserSignature(message: String,
                             signatures: [Flow.TransactionSignature]) async throws -> Bool
    {
        let addresses = Set(signatures.compactMap { $0.address })
        let accounts = try await addresses.map(flow.getAccountAtLatestBlock)

        var weights: [Flow.Cadence.FValue] = []
        var signAlgos: [Flow.Cadence.FValue] = []
        var hashAlgos: [Flow.Cadence.FValue] = []
        var sigs: [Flow.Cadence.FValue] = []
        var publicKeys: [Flow.Cadence.FValue] = []
        signatures.forEach { sig in
            if let account = accounts.first(where: { $0.address == sig.address }),
               let key = account.keys[safe: sig.keyIndex]
            {
                weights.append(.ufix64(Decimal(key.weight)))
                signAlgos.append(.uint8(UInt8(key.signAlgo.index)))
                hashAlgos.append(.uint8(UInt8(key.hashAlgo.code)))
                sigs.append(.string(sig.signature.hexValue))
                publicKeys.append(.string(key.publicKey.hex))
            }
        }

        let arguments: [Flow.Argument] = [.string(message),
                                          .array(publicKeys),
                                          .array(weights),
                                          .array(signAlgos),
                                          .array(hashAlgos),
                                          .array(sigs)].toArguments()

        let result = try await flow.executeScriptAtLatestBlock(cadence: CommonCadence.verifyUserSignature, arguments: arguments)
        print(result)
        return try result.decode()
    }
}
