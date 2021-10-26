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
    /// It includes `addKeyToAccount, addContractToAccount, createAccount, removeAccountKeyByIndex, removeContractFromAccount, updateContractOfAccount`
    class CommonCadence {

        /// The cadence code for adding key to account
        static let addKeyToAccount = """
            transaction(publicKey: String) {
                prepare(signer: AuthAccount) {
                    signer.addPublicKey(publicKey.decodeHex())
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
            transaction(publicKeys: [String], contracts: {String: String}) {
                prepare(signer: AuthAccount) {
                    let acct = AuthAccount(payer: signer)
                    for key in publicKeys {
                        acct.addPublicKey(key.decodeHex())
                    }
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
    }
}

extension Flow {

    /// Add public key to account
    /// - parameters:
    ///     - address: The address of Account in `Flow.Address` type.
    ///     - accountKey: The public key to be added in `Flow.AccountKey` type.
    ///     - signers: A list of `FlowSigner` will sign the transaction.
    /// - returns: A future value will receive transaction id  in `Flow.ID` value.
    public func addKeyToAccount(address: Flow.Address, accountKey: Flow.AccountKey, signers: [FlowSigner]) throws -> EventLoopFuture<Flow.ID> {

        guard let encodedKey = accountKey.encoded else {
            let promise = flow.accessAPI.clientChannel.eventLoop.makePromise(of: Flow.ID.self)
            promise.fail(Flow.FError.encodeFailure)
            return promise.futureResult
        }

        return try self.sendTransaction(signers: signers) {
            cadence {
                CommonCadence.addKeyToAccount
            }
            arguments {
                .init(value: .string(encodedKey.hexValue))
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
    public func addContractToAccount(address: Flow.Address,
                                     contractName: String,
                                     code: String,
                                     signers: [FlowSigner]) throws -> EventLoopFuture<Flow.ID> {
        let script = Flow.Script(script: code)
        return try self.sendTransaction(signers: signers) {
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
    public func createAccount(address: Flow.Address,
                              publicKeys: [Flow.AccountKey],
                              contracts: [String: String] = [:],
                              signers: [FlowSigner]) throws -> EventLoopFuture<Flow.ID> {
        let contractArg = contracts.compactMap { name, cadence in
            Flow.Argument.Dictionary(key: .init(value: .string(name)),
                                     value: .init(value: .string(Flow.Script(script: cadence).hex)))
        }

        let pubKeyArg = publicKeys.compactMap { $0.encoded?.hexValue }.compactMap { Flow.Argument(value: .string($0)) }

        return try self.sendTransaction(signers: signers) {
            cadence {
                CommonCadence.createAccount
            }
            arguments {
                [.array(pubKeyArg), .dictionary(contractArg)]
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
    public func removeAccountKeyByIndex(address: Flow.Address,
                                        keyIndex: Int,
                                        signers: [FlowSigner]) throws -> EventLoopFuture<Flow.ID> {
        return try self.sendTransaction(signers: signers) {
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

    public func removeContractFromAccount(address: Flow.Address,
                                          contractName: String,
                                          signers: [FlowSigner]) throws -> EventLoopFuture<Flow.ID> {
        return try self.sendTransaction(signers: signers) {
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

    public func updateContractOfAccount(address: Flow.Address,
                                        contractName: String,
                                        script: String,
                                        signers: [FlowSigner]) throws -> EventLoopFuture<Flow.ID> {
        return try self.sendTransaction(signers: signers) {
            cadence {
                CommonCadence.updateContractOfAccount
            }
            arguments {
                [.string(contractName), .string(Flow.Script(script: script).hex)]
            }
            proposer {
                address
            }
            authorizers {
                address
            }
        }
    }
}
