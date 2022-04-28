//
//  CommonCadence
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
import Combine
import Foundation
import NIO

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

        /// The cadence code to verify user signature
        static let verifyUserSignature = """
        import Crypto

        pub fun main(
          message: String,
          rawPublicKeys: [String],
          weights: [UFix64],
          signAlgos: [UInt],
          signatures: [String],
        ): Bool {

          let keyList = Crypto.KeyList()

          var i = 0
          for rawPublicKey in rawPublicKeys {
            keyList.add(
              PublicKey(
                publicKey: rawPublicKey.decodeHex(),
                signatureAlgorithm: signAlgos[i] == 2 ? SignatureAlgorithm.ECDSA_P256 : SignatureAlgorithm.ECDSA_secp256k1
              ),
              hashAlgorithm: HashAlgorithm.SHA3_256,
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
    func addKeyToAccount(address: Flow.Address, accountKey: Flow.AccountKey, signers: [FlowSigner]) throws -> EventLoopFuture<Flow.ID> {
        return try sendTransaction(signers: signers) {
            cadence {
                CommonCadence.addKeyToAccount
            }
            arguments {
                [
                    .string(accountKey.publicKey.hex),
                    .uint8(UInt8(accountKey.signAlgo.index)),
                    .uint8(UInt8(accountKey.hashAlgo.code)),
                    .ufix64(1000)
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
                              signers: [FlowSigner]) throws -> EventLoopFuture<Flow.ID>
    {
        let script = Flow.Script(text: code)
        return try sendTransaction(signers: signers) {
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
                       signers: [FlowSigner]) throws -> EventLoopFuture<Flow.ID>
    {
        let contractArg = contracts.compactMap { name, cadence in
            Flow.Argument.Dictionary(key: .init(value: .string(name)),
                                     value: .init(value: .string(Flow.Script(text: cadence).hex)))
        }

        return try sendTransaction(signers: signers) {
            cadence {
                CommonCadence.createAccount
            }
            arguments {
                [
                    .string(accountKey.publicKey.hex),
                    .uint8(UInt8(accountKey.signAlgo.index)),
                    .uint8(UInt8(accountKey.hashAlgo.code)),
                    .ufix64(1000),
                    .dictionary(contractArg)
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
                                 signers: [FlowSigner]) throws -> EventLoopFuture<Flow.ID>
    {
        return try sendTransaction(signers: signers) {
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

    func removeContractFromAccount(address: Flow.Address,
                                   contractName: String,
                                   signers: [FlowSigner]) throws -> EventLoopFuture<Flow.ID>
    {
        return try sendTransaction(signers: signers) {
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
                                 signers: [FlowSigner]) throws -> EventLoopFuture<Flow.ID>
    {
        return try sendTransaction(signers: signers) {
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

    func verifyUserSignature(message: String,
                             signatures: [Flow.TransactionSignature]) throws -> EventLoopFuture<Flow.ScriptResponse>
    {
        let futures: [EventLoopFuture<Flow.Account>] = signatures.compactMap { signature in
            flow.accessAPI.getAccountAtLatestBlock(address: signature.address).unwrap(orError: FError.invaildAccountInfo)
        }

        return EventLoopFuture.whenAllComplete(futures, on: flow.accessAPI.clientChannel.eventLoop).map { results in
            results.compactMap { result -> Flow.Account? in
                switch result {
                case let .success(account):
                    return account
                case .failure:
                    // TODO: Handle error here
                    return nil
                }
            }
        }.flatMap { accounts -> EventLoopFuture<Flow.ScriptResponse> in

            var weights: [Flow.Cadence.FValue] = []
            var signAlgos: [Flow.Cadence.FValue] = []
            var sigs: [Flow.Cadence.FValue] = []
            var publicKeys: [Flow.Cadence.FValue] = []
            signatures.forEach { sig in
                if let account = accounts.first(where: { $0.address == sig.address }),
                   let key = account.keys[safe: sig.keyIndex]
                {
                    weights.append(.ufix64(Double(key.weight)))
                    signAlgos.append(.uint(UInt(key.signAlgo.code)))
                    sigs.append(.string(sig.signature.hexValue))
                    publicKeys.append(.string(key.publicKey.hex))
                }
            }

            let arguments: [Flow.Argument] = [.string(message),
                                              .array(publicKeys.toArguments()),
                                              .array(weights.toArguments()),
                                              .array(signAlgos.toArguments()),
                                              .array(sigs.toArguments())].toArguments()
            return flow.accessAPI.executeScriptAtLatestBlock(script:
                Flow.Script(text: CommonCadence.verifyUserSignature),
                arguments: arguments)
        }
    }
}
