//
//  File.swift
//  File
//
//  Created by lmcmz on 13/10/21.
//

import Combine
import Foundation

extension Flow {
    class CommonCadence {
        static let addKeyToAccount = """
            transaction(publicKey: String) {
                prepare(signer: AuthAccount) {
                    signer.addPublicKey(publicKey.decodeHex())
                }
            }
        """

        static let addContractToAccount = """
            transaction(name: String, code: String) {
                prepare(signer: AuthAccount) {
                    signer.contracts.add(name: name, code: code.decodeHex())
                }
            }
        """

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

        static let removeAccountKeyByIndex = """
            transaction(keyIndex: Int) {
                prepare(signer: AuthAccount) {
                    signer.removePublicKey(keyIndex)
                }
            }
        """

        static let removeContractFromAccount = """
            transaction(name: String) {
                prepare(signer: AuthAccount) {
                    signer.contracts.remove(name: name)
                }
            }
        """

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
    public func addKeyToAccount(address: Flow.Address, accountKey: Flow.AccountKey, signers: [FlowSigner]) -> Future<Flow.ID, Error> {
        return Future { promise in
            guard let encodedKey = accountKey.encoded else {
                promise(.failure(Flow.FError.encodeFailure))
                return
            }

            do {
                let txId = try self.sendTransaction(signers: signers) {
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
                }.wait()
                promise(.success(txId))
            } catch {
                promise(.failure(error))
            }
        }
    }

    public func addContractToAccount(address: Flow.Address, contractName: String, code: String, signers: [FlowSigner]) -> Future<Flow.ID, Error> {
        return Future { promise in
            let script = Flow.Script(script: code)
            do {
                let txId = try self.sendTransaction(signers: signers) {
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
                }.wait()
                promise(.success(txId))
            } catch {
                promise(.failure(error))
            }
        }
    }

    public func createAccount(address: Flow.Address,
                              publicKeys: [Flow.AccountKey],
                              contracts: [String: String],
                              signers: [FlowSigner]) -> Future<Flow.ID, Error> {
        return Future { promise in
            do {
                let contractArg = contracts.compactMap { name, cadence in
                    Flow.Argument.Dictionary(key: .init(value: .string(name)),
                                             value: .init(value: .string(Flow.Script(script: cadence).hex)))
                }

                let pubKeyArg = publicKeys.compactMap { $0.encoded?.hexValue }.compactMap { Flow.Argument(value: .string($0)) }

                let txId = try self.sendTransaction(signers: signers) {
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
                }.wait()
                promise(.success(txId))
            } catch {
                promise(.failure(error))
            }
        }
    }

    public func removeAccountKeyByIndex(address: Flow.Address,
                                        keyIndex: Int,
                                        signers: [FlowSigner]) -> Future<Flow.ID, Error> {
        return Future { promise in
            do {
                let txId = try self.sendTransaction(signers: signers) {
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
                }.wait()
                promise(.success(txId))
            } catch {
                promise(.failure(error))
            }
        }
    }

    public func removeContractFromAccount(address: Flow.Address,
                                          contractName: String,
                                          signers: [FlowSigner]) -> Future<Flow.ID, Error> {
        return Future { promise in
            do {
                let txId = try self.sendTransaction(signers: signers) {
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
                }.wait()
                promise(.success(txId))
            } catch {
                promise(.failure(error))
            }
        }
    }

    public func updateContractOfAccount(address: Flow.Address,
                                        contractName: String,
                                        script: String,
                                        signers: [FlowSigner]) -> Future<Flow.ID, Error> {
        return Future { promise in
            do {
                let txId = try self.sendTransaction(signers: signers) {
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
                }.wait()
                promise(.success(txId))
            } catch {
                promise(.failure(error))
            }
        }
    }
}
