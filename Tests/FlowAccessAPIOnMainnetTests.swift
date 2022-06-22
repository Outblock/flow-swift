//
//  FlowAccessAPIOnMainnetTests
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

import CryptoKit
@testable import Flow
import Foundation
import XCTest

final class FlowAccessAPIOnMainnetTests: XCTestCase {
    var flowAPI: FlowAccessProtocol!
    var address = Flow.Address(hex: "0x2b06c41f44a05656")

    override func setUp() {
        super.setUp()
        flowAPI = flow.createAccessAPI(chainID: .mainnet)
    }

    func testFlowPing() async throws {
        let isConnected = try await flowAPI.ping()
        XCTAssertTrue(isConnected)
    }

//    func testNetworkParameters() async throws {
//        let ChainID = try await flowAPI.getNetworkParameters()
//        XCTAssertEqual(ChainID, Flow.ChainID.mainnet)
//    }

    func testBlockHeader() async throws {
        let blockHeader = try await flowAPI.getLatestBlockHeader()
        XCTAssertNotNil(blockHeader)
    }

    func testGetAccount() async throws {
        let account = try await flowAPI.getAccountAtLatestBlock(address: address)
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
        let blockHeader = try await flowAPI.getBlockHeaderByHeight(height: 32002158)
        XCTAssertEqual("a2a06ff324325d118c52a3a23d7c31288192ae8ab78255a2c3cd35fbbf09c6ec", blockHeader.id.hex)
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

//    func testGetLatestProtocolStateSnapshot() async throws {
//        let snapshot = try await flowAPI.getLatestProtocolStateSnapshot()
//        XCTAssertNotNil(snapshot)
//    }

    func testExecuteScriptAtLastestBlock() async throws {
        let script = Flow.Script(text: """
            pub struct SomeStruct {
                  pub var x: Int
                  pub var y: Int
                  init(x: Int, y: Int) {
                    self.x = x
                    self.y = y
                  }
            }

            pub fun main(): [SomeStruct] {
              return [SomeStruct(x: 1, y: 2), SomeStruct(x: 3, y: 4)]
            }

            """
        )

        let snapshot = try await flowAPI.executeScriptAtLatestBlock(script: script)
        XCTAssertNotNil(snapshot)
        XCTAssertEqual(Flow.Cadence.FType.array, snapshot.fields?.type)

        guard case let .array(value: value) = snapshot.fields!.value else { XCTFail(); return }
        guard case let .struct(value: firstStruct) = value.first!.value else { XCTFail(); return }

        XCTAssertEqual(firstStruct.fields.first!.name, "x")
        XCTAssertEqual(firstStruct.fields.first!.value.value.toInt(), 1)
        XCTAssertEqual(firstStruct.fields.last!.name, "y")
        XCTAssertEqual(firstStruct.fields.last!.value.value.toInt(), 2)
    }

    func testVerifySignature() async throws {
        let script = Flow.Script(text: """
        import Crypto
        pub fun main(
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
//
//        guard case let .array(value: value) = snapshot.fields!.value else { XCTFail(); return }
//        guard case let .struct(value: firstStruct) = value.first!.value else { XCTFail(); return }
//
//        XCTAssertEqual(firstStruct.fields.first!.name, "x")
//        XCTAssertEqual(firstStruct.fields.first!.value.value.toInt(), 1)
//        XCTAssertEqual(firstStruct.fields.last!.name, "y")
//        XCTAssertEqual(firstStruct.fields.last!.value.value.toInt(), 2)
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
        XCTAssertEqual(result.events.first?.payload.fields?.type, .event)
        XCTAssertEqual(result.events.first?.payload.fields?.value,
                       .event(.init(id: "A.c38aea683c0c4d38.Eternal.Withdraw",
                                    fields: [.init(name: "id", value: .init(value: .uint64(11800))),
                                             .init(name: "from", value: .init(value: .optional(value: .init(value: .address(.init(hex: "0x873becfb539f038d"))))))])))
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
    
    func testGetEventByRange() async throws {
        let result = try await flowAPI.getEventsForHeightRange(type: "A.2d4c3caffbeab845.FLOAT.FLOATTransferred", range: 32002158...32002160)
        XCTAssertEqual(result.first!.events.first!.transactionIndex, 3)
        XCTAssertNotNil(result)
    }
    
    func testGetEventByIds() async throws {
        let result = try await flowAPI.getEventsForBlockIds(type: "A.2d4c3caffbeab845.FLOAT.FLOATTransferred", ids: Set(arrayLiteral: .init(hex: "a2a06ff324325d118c52a3a23d7c31288192ae8ab78255a2c3cd35fbbf09c6ec")))
        XCTAssertEqual(result.first!.events.first!.transactionIndex, 3)
        XCTAssertNotNil(result)
    }
}
