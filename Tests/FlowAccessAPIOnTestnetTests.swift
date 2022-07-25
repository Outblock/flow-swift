//
//  FlowAccessAPIOnTestnetTests
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

@testable import BigInt
import Combine
import CryptoKit
@testable import Flow
import XCTest

final class FlowAccessAPIOnTestnetTests: XCTestCase {
    var flowAPI: FlowAccessProtocol!

    let addressA = Flow.Address(hex: "0xc6de0d94160377cd")
    let publicKeyA = try! P256.KeyAgreement.PublicKey(rawRepresentation: "d487802b66e5c0498ead1c3f576b718949a3500218e97a6a4a62bf69a8b0019789639bc7acaca63f5889c1e7251c19066abb09fcd6b273e394a8ac4ee1a3372f".hexValue)
    let privateKeyA = try! P256.Signing.PrivateKey(rawRepresentation: "c9c0f04adddf7674d265c395de300a65a777d3ec412bba5bfdfd12cffbbb78d9".hexValue)

    var addressB = Flow.Address(hex: "0x10711015c370a95c")
    let publicKeyB = try! P256.KeyAgreement.PublicKey(rawRepresentation: "6278ff9fdf75c5830e4aafbb8cc25af50b62869d7bc9b249e76aae31490199732b769d1df627d36e5e336aeb4cb06b0fad80ae13a25aca37ec0017e5d8f1d8a5".hexValue)
    let privateKeyB = try! P256.Signing.PrivateKey(rawRepresentation: "38ebd09b83e221e406b176044a65350333b3a5280ed3f67227bd80d55ac91a0f".hexValue)

    var addressC = Flow.Address(hex: "0xe242ccfb4b8ea3e2")
    let publicKeyC = try! P256.KeyAgreement.PublicKey(rawRepresentation: "adbf18dae6671e6b6a92edf00c79166faba6babf6ec19bd83eabf690f386a9b13c8e48da67973b9cf369f56e92ec25ede5359539f687041d27d0143afd14bca9".hexValue)
    let privateKeyC = try! P256.Signing.PrivateKey(rawRepresentation: "1eb79c40023143821983dc79b4e639789ea42452e904fda719f5677a1f144208".hexValue)

    override func setUp() {
        super.setUp()
        flowAPI = flow.createHTTPAccessAPI(chainID: .testnet)
        flow.configure(chainID: .testnet)
    }

    func testFlowPing() async throws {
        let isConnected = try await flowAPI.ping()
        XCTAssertTrue(isConnected)
    }

    func testFlowFee() async throws {
        let result = try! await flow.accessAPI.executeScriptAtLatestBlock(script: .init(text: """
        import FlowFees from 0x912d5440f7e3769e

               pub fun main(): FlowFees.FeeParameters {
                 return FlowFees.getFeeParameters()
               }
        """))
        print(result)
    }

//    func testNetworkParameters() async throws {
//        let ChainID = try await flowAPI.getNetworkParameters()
//        XCTAssertEqual(ChainID, Flow.ChainID.testnet)
//
//        let pk = P256.KeyAgreement.PrivateKey()
//        print(pk.rawRepresentation.hexValue)
//        print(pk.publicKey.rawRepresentation.hexValue)
//    }

    func testCanCreateAccount() async throws {
        // Example in Testnet

        flow.configure(chainID: .testnet)
        let signer = [ECDSA_P256_Signer(address: addressA, keyIndex: 0, privateKey: privateKeyA)]

        // User publick key
        let accountKey = Flow.AccountKey(publicKey: Flow.PublicKey(hex: "74c4e3ec6803c7b7f399a27e457b4060ae0b3b2fd4cf1933ddaa7891fdc74e2b2c4a6ba2db1a447b7e086c0e42df15c4b47ffd607b74dd990525d2e7f94368cf"),
                                         signAlgo: .ECDSA_P256,
                                         hashAlgo: .SHA2_256,
                                         weight: 1000)

        var unsignedTx = try! await flow.buildTransaction {
            cadence {
                """
                import Crypto
                transaction(publicKey: String, signatureAlgorithm: UInt8, hashAlgorithm: UInt8, weight: UFix64) {
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
                    }
                }
                """
            }

            proposer {
                Flow.TransactionProposalKey(address: addressA, keyIndex: 0)
            }

            authorizers {
                self.addressA
            }

            arguments {
                [
                    .string(accountKey.publicKey.hex),
                    .uint8(UInt8(accountKey.signAlgo.index)),
                    .uint8(UInt8(accountKey.hashAlgo.code)),
                    .ufix64(1000),
                ]
            }

            // optional
            gasLimit {
                1000
            }
        }

        let signedTx = try! await unsignedTx.sign(signers: signer)

        let txId = try! await flow.sendTransaction(signedTransaction: signedTx)
        XCTAssertNotNil(txId)
        print("txid --> \(txId.hex)")
    }

    func testMultipleSigner() async throws {
        // Example in Testnet
        let signers = [
            // Address A
            ECDSA_P256_Signer(address: addressA, keyIndex: 5, privateKey: privateKeyB), // weight: 500
            ECDSA_P256_Signer(address: addressA, keyIndex: 0, privateKey: privateKeyA), // weight: 1000
            // Address B
            ECDSA_P256_Signer(address: addressB, keyIndex: 2, privateKey: privateKeyA), // weight: 800
            ECDSA_P256_Signer(address: addressB, keyIndex: 1, privateKey: privateKeyC), // weight: 500
            // Address C
            ECDSA_P256_Signer(address: addressC, keyIndex: 3, privateKey: privateKeyB), // weight: 300
            ECDSA_P256_Signer(address: addressC, keyIndex: 2, privateKey: privateKeyB), // weight: 500
            ECDSA_P256_Signer(address: addressC, keyIndex: 0, privateKey: privateKeyC), // weight: 1000
        ]

        let txID = try! await flow.sendTransaction(chainID: .testnet, signers: signers) {
            cadence {
                """
                import HelloWorld from 0xe242ccfb4b8ea3e2

                   transaction(test: String, testInt: HelloWorld.SomeStruct) {
                       prepare(signer1: AuthAccount, signer2: AuthAccount, signer3: AuthAccount) {
                            log(signer1.address)
                            log(signer2.address)
                            log(signer3.address)
                            log(test)
                            log(testInt)
                       }
                   }
                """
            }

            arguments {
                [.string("Test"), .struct(.init(id: "A.e242ccfb4b8ea3e2.HelloWorld.SomeStruct",
                                                fields: [.init(name: "x", value: .init(value: .int(1))),
                                                         .init(name: "y", value: .init(value: .int(2)))]))]
            }

            proposer {
                .init(address: addressA, keyIndex: 5)
            }

            payer {
                self.addressB
            }

            authorizers {
                [self.addressC, self.addressB, self.addressA]
            }
        }

        print("tx id -> \(txID.hex)")
        let result = try await txID.onceSealed()
        XCTAssertEqual(result.status, .sealed)
    }
}
