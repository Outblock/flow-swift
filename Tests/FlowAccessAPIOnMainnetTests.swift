//
//  FlowAccessAPIOnMainnetTests
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

import CryptoKit
@testable import Flow
import Foundation
import XCTest

final class FlowAccessAPIOnMainnetTests: XCTestCase {
    var flowAPI: FlowAccessProtocol!
    var address = Flow.Address(hex: "0x2b06c41f44a05656")

    override func setUp() {
        super.setUp()
        flow.configure(chainID: .mainnet)
        flowAPI = flow.createHTTPAccessAPI(chainID: .mainnet)
    }

    func testFlowPing() async throws {
        let isConnected = try await flowAPI.ping()
        XCTAssertTrue(isConnected)
    }

    func testNetworkParameters() async throws {
        let ChainID = try await flowAPI.getNetworkParameters()
        XCTAssertEqual(ChainID, Flow.ChainID.mainnet)
    }

    func testBlockHeader() async throws {
        let blockHeader = try await flowAPI.getLatestBlockHeader()
        XCTAssertNotNil(blockHeader)
    }

    func testGetAccount() async throws {
        let account = try await flowAPI.getAccountAtLatestBlock(address: address)
        XCTAssertNotNil(account.keys.first)
        XCTAssertEqual(address, account.address)
    }

    func testGetAccount2() async throws {
        let account = try await flowAPI.getAccountAtLatestBlock(address: address.hex)
        XCTAssertNotNil(account.keys.first)
        XCTAssertEqual(address, account.address)
    }

    func testGetBlockHeaderByID() async throws {
        let block = try await flowAPI.getLatestBlock(sealed: true)
        XCTAssertNotNil(block)

        let blockHeader = try await flowAPI.getBlockById(id: block.id)
        XCTAssertNotNil(blockHeader)
        XCTAssertEqual(blockHeader.height, block.height)
    }

    func testGetBlockHeaderByHeight() async throws {
        let blockHeader = try await flowAPI.getBlockHeaderByHeight(height: 41_344_631)
        XCTAssertEqual("cf036cb6069caa7d61b867f0ad546033d024e031f20b08f7c6e0e74fb4a6a718", blockHeader.id.hex)
        XCTAssertNotNil(blockHeader)
    }

    func testGetAccountByHeight() async throws {
        let block = try await flowAPI.getLatestBlock(sealed: true)
        XCTAssertNotNil(block)
        let account = try await flowAPI.getAccountByBlockHeight(address: address, height: block.height)

        XCTAssertNotNil(account.keys.first)
        XCTAssertEqual(address, account.address)
    }

    func testGetLatestBlock() async throws {
        let block = try await flowAPI.getLatestBlock(sealed: true)
        XCTAssertNotNil(block)
    }

    func testQueryToken() async throws {
        let script = Flow.Script(text: """
            access(all) struct SomeStruct {
                access(all) var x: Int
                access(all) var y: Int
                  init(x: Int, y: Int) {
                    self.x = x
                    self.y = y
                  }
            }

            access(all) fun main(): [SomeStruct] {
              return [SomeStruct(x: 1, y: 2), SomeStruct(x: 3, y: 4)]
            }
            """
        )

        let snapshot = try await flowAPI.executeScriptAtLatestBlock(script: script)
        XCTAssertNotNil(snapshot)
        XCTAssertEqual(Flow.Cadence.FType.array, snapshot.fields?.type)

        struct SomeStruct: Codable {
            var x: Int
            var y: Int
        }

        guard let result: [SomeStruct] = try? snapshot.decode() else {
            XCTFail()
            return
        }
        print(result)

        guard case let .array(value: value) = snapshot.fields!.value else { XCTFail(); return }
        guard case let .struct(value: firstStruct) = value.first! else { XCTFail(); return }

        XCTAssertEqual(firstStruct.fields.first!.name, "x")
        XCTAssertEqual(result.first?.x, 1)
        XCTAssertEqual(firstStruct.fields.last!.name, "y")
        XCTAssertEqual(result.first?.y, 2)
    }

    func testExecuteScriptAtLastestBlock2() async throws {
        let script = Flow.Script(text: """
            access(all) struct User {
                access(all) var balance: UFix64
                access(all) var address: Address
                access(all) var name: String

                init(name: String, address: Address, balance: UFix64) {
                    self.name = name
                    self.address = address
                    self.balance = balance
                }
            }

            access(all) fun main(name: String): User {
                return User(
                    name: name,
                    address: 0x1,
                    balance: 10.0
                )
            }
            """
        )

        struct User: Codable {
            let balance: Double
            let address: String
            let name: String
        }

        let snapshot = try await flowAPI.executeScriptAtLatestBlock(script: script, arguments: [.string("Hello")])
        XCTAssertNotNil(snapshot)

        let result: User = try snapshot.decode()
        print(result)

        XCTAssertEqual(result.name, "Hello")
        XCTAssertEqual(result.balance, 10.0)
        XCTAssertEqual(result.address, "0x0000000000000001")
    }

    func testVerifySignature() async throws {
        let script = Flow.Script(text: """
        import Crypto
        access(all) fun main(
          publicKey: String,
          signature: String,
          message: String
        ): Bool {

            let signatureBytes = signature.decodeHex()
            let messageBytes = message.utf8

            let pk = PublicKey(
                    publicKey: publicKey.decodeHex(),
                    signatureAlgorithm: SignatureAlgorithm.ECDSA_P256
            )

            return pk.verify(
                signature: signatureBytes,
                signedData: messageBytes,
                domainSeparationTag: "FLOW-V0.0-user",
                hashAlgorithm: HashAlgorithm.SHA2_256)
        }
        """)

        let pubk = "5e2bff8d76a5cb2e59b621324c015b98b6131f5715fa8f4e66b6e75276056eb2d28ce8f1c113f562ed8d09bdd4edf6e30dd2ebdc4a4515f48be024e1749b58cc"
        let sig = "bd7fdac4282f2afca4b509fb809700b89b79472cbdf58ce8a4e3b0e16633cd854cf1165f632ee61eb23c830ba6b5f8f8f1b3e1f4880212c8bda4874568cbf717"

        let uid = "3h7BjWUYuqQMI8O96Lxwol4Lxl62"

        let snapshot = try await flowAPI.executeScriptAtLatestBlock(script: script,
                                                                    arguments: [.init(value: .string(pubk)),
                                                                                .init(value: .string(sig)),
                                                                                .init(value: .string(uid))])
        XCTAssertNotNil(snapshot)
        XCTAssertEqual(.bool(true), snapshot.fields?.value)
    }

//    func testGetCollectionById() async throws {
//        // Can't find a valid collection ID as example
//        let id = Flow.ID(hex: "53cc748124358855ec4d975ce6511ba016f5d2dfcead1527fd858579fc7baf76")
//        let collection = try await flowAPI.getCollectionById(id: id)
//        XCTAssertNotNil(collection)
//    }

    func testTransactionResultById() async throws {
        let id = Flow.ID(hex: "6d6c20405f3dd2001361cd994493a56d31f4daa1c7ce420a2cd4259454b4a0da")
        let result = try await flowAPI.getTransactionResultById(id: id)

        XCTAssertEqual(result.events.count, 3)
        XCTAssertEqual(result.events.first?.type, "A.c38aea683c0c4d38.Eternal.Withdraw")

        struct TestType: Codable {
            let id: UInt64
            let from: String
        }

        let test: TestType = try result.events.first!.payload.decode()

        XCTAssertEqual(result.events.first?.payload.fields?.type, .event)
        XCTAssertEqual(test.id, 11800)
        XCTAssertEqual(test.from.addHexPrefix(), "0x873becfb539f038d")
        XCTAssertNotNil(result)
    }

    func testTransactionById() async throws {
        let id = Flow.ID(hex: "6d6c20405f3dd2001361cd994493a56d31f4daa1c7ce420a2cd4259454b4a0da")
        let transaction = try await flowAPI.getTransactionById(id: id)
        XCTAssertEqual(transaction.arguments.first?.type, .path)
        XCTAssertEqual(transaction.arguments.first?.value, .path(.init(domain: "public", identifier: "zelosAccountingTokenReceiver")))
        XCTAssertEqual(transaction.arguments.last?.type, .ufix64)
        XCTAssertEqual(transaction.arguments.last?.value.toUFix64(), 99.0)
        XCTAssertEqual(transaction.payer.bytes.hexValue, "1f56a1e665826a52")
        XCTAssertNotNil(transaction)
    }
}
