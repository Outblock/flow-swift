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

@testable import Flow
import Foundation
import XCTest

final class FlowAccessAPIOnMainnetTests: XCTestCase {
    var flowAPI: Flow.AccessAPI!
    var address = Flow.Address(hex: "0x4eb165aa383fd6f9")

    override func setUp() {
        super.setUp()
        flowAPI = flow.createAccessAPI(chainID: .mainnet)
    }

    func testFlowPing() throws {
        let isConnected = try flowAPI.ping().wait()
        XCTAssertTrue(isConnected)
    }

    func testNetworkParameters() throws {
        let ChainID = try flowAPI.getNetworkParameters().wait()
        XCTAssertEqual(ChainID, Flow.ChainID.mainnet)
    }

    func testBlockHeader() throws {
        let blockHeader = try flowAPI.getLatestBlockHeader().wait()
        XCTAssertNotNil(blockHeader)
    }

    func testGetAccount() throws {
        let account = try flowAPI.getAccountAtLatestBlock(address: address).wait()
        XCTAssertNotNil(account?.keys.first)
        XCTAssertEqual(address, account?.address)
    }

    func testGetBlockHeaderByID() throws {
        let block = try flowAPI.getLatestBlock(sealed: true).wait()
        XCTAssertNotNil(block)

        let blockHeader = try flowAPI.getBlockById(id: block.id).wait()
        XCTAssertNotNil(blockHeader)
        XCTAssertEqual(blockHeader?.height, block.height)
    }

    func testGetAccountByHeight() throws {
        let block = try flowAPI.getLatestBlock(sealed: true).wait()
        XCTAssertNotNil(block)
        let account = try flowAPI.getAccountByBlockHeight(address: address, height: block.height).wait()

        XCTAssertNotNil(account?.keys.first)
        XCTAssertEqual(address, account?.address)
    }

    func testGetLatestBlock() throws {
        let block = try flowAPI.getLatestBlock(sealed: true).wait()
        XCTAssertNotNil(block)
    }

    func testGetLatestProtocolStateSnapshot() throws {
        let snapshot = try flowAPI.getLatestProtocolStateSnapshot().wait()
        XCTAssertNotNil(snapshot)
    }

    func testExecuteScriptAtLastestBlock() throws {
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
        """)
        let snapshot = try flowAPI.executeScriptAtLatestBlock(script: script).wait()
        XCTAssertNotNil(snapshot)
        XCTAssertEqual(Flow.Cadence.FType.array, snapshot.fields?.type)

        guard case let .array(value: value) = snapshot.fields!.value else { XCTFail(); return }
        guard case let .struct(value: firstStruct) = value.first!.value else { XCTFail(); return }

        XCTAssertEqual(firstStruct.fields.first!.name, "x")
        XCTAssertEqual(firstStruct.fields.first!.value.value.toInt(), 1)
        XCTAssertEqual(firstStruct.fields.last!.name, "y")
        XCTAssertEqual(firstStruct.fields.last!.value.value.toInt(), 2)
    }

    func testGetCollectionById() throws {
        // Can't find a valid collection ID as example
//        let id = Flow.ID(hex: "53cc748124358855ec4d975ce6511ba016f5d2dfcead1527fd858579fc7baf76")
//        let collection = try flowAPI.getCollectionById(id: id).wait()
//        XCTAssertNotNil(collection)
    }

    func testTransactionResultById() throws {
        let id = Flow.ID(hex: "6d6c20405f3dd2001361cd994493a56d31f4daa1c7ce420a2cd4259454b4a0da")
        let result = try flowAPI.getTransactionResultById(id: id).wait()
        XCTAssertEqual(result.events.count, 3)
        XCTAssertEqual(result.events.first?.type, "A.c38aea683c0c4d38.Eternal.Withdraw")
        XCTAssertEqual(result.events.first?.payload.fields?.type, .event)
        XCTAssertEqual(result.events.first?.payload.fields?.value,
                       .event(.init(id: "A.c38aea683c0c4d38.Eternal.Withdraw",
                                    fields: [.init(name: "id", value: .init(value: .uint64(11800))),
                                             .init(name: "from", value: .init(value: .optional(value: .init(value: .address(.init(hex: "0x873becfb539f038d"))))))])))
        XCTAssertNotNil(result)
    }

    func testTransactionById() throws {
        let id = Flow.ID(hex: "6d6c20405f3dd2001361cd994493a56d31f4daa1c7ce420a2cd4259454b4a0da")
        let transaction = try flowAPI.getTransactionById(id: id).wait()
        XCTAssertEqual(transaction?.arguments.first?.type, .path)
        XCTAssertEqual(transaction?.arguments.first?.value, .path(.init(domain: "public", identifier: "zelosAccountingTokenReceiver")))
        XCTAssertEqual(transaction?.arguments.last?.type, .ufix64)
        XCTAssertEqual(transaction?.arguments.last?.value.toUFix64(), 99.0)
        XCTAssertEqual(transaction?.payerAddress.bytes.hexValue, "1f56a1e665826a52")
        XCTAssertNotNil(transaction)
    }
}
