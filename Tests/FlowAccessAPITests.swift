@testable import Flow
import XCTest

final class FlowAccessAPITests: XCTestCase {
    var flowAPI: FlowAccessAPI!
    var testAddress = "7907881e2e2cdfb7"

    override func setUp() {
        super.setUp()
        let flowInstance = Flow.shared
        flowAPI = flowInstance.newAccessApi(chainId: .mainnet)
    }

    func testFlowPing() throws {
        let isConnected = try flowAPI.ping().wait()
        XCTAssertTrue(isConnected)
    }

    func testNetworkParameters() throws {
        let chainId = try flowAPI.getNetworkParameters().wait()
        XCTAssertEqual(chainId, Flow.ChainId.mainnet)
    }

    func testBlockHeader() throws {
        let blockHeader = try flowAPI.getLatestBlockHeader().wait()
        XCTAssertNotNil(blockHeader)
    }

    func testGetAccount() throws {
        let address = Flow.Address(hex: testAddress)
        let account = try flowAPI.getAccountAtLatestBlock(address: address).wait()
        XCTAssertNotNil(account?.keys.first)
        XCTAssertEqual(address, account?.address)

    }

    func testGetBlockHeaderByID() throws {
        let id = Flow.Id(hex: "7e846452f05e1094c3be73c5253cc9e5f97db63468a80b424c83f4b18ec9a290")
        let blockHeader = try flowAPI.getBlockById(id: id).wait()
        XCTAssertNotNil(blockHeader)
        XCTAssertEqual(blockHeader?.height, 16925668)
    }

    func testGetAccountByHeight() throws {
        let address = Flow.Address(hex: testAddress)
        let account = try flowAPI.getAccountByBlockHeight(address: address, height: 16925668).wait()
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

    func testSendTransaction() throws {
        // TODO:
    }

    func testGetCollectionById() throws {
        // Example for mainnet
        let id = Flow.Id(hex: "6d6c20405f3dd2001361cd994493a56d31f4daa1c7ce420a2cd4259454b4a0da")
        let collection = try flowAPI.getCollectionById(id: id).wait()
        XCTAssertNotNil(collection)
    }

    func testTransactionById() throws {

        // Example for mainnet
        let id = Flow.Id(hex: "6d6c20405f3dd2001361cd994493a56d31f4daa1c7ce420a2cd4259454b4a0da")
        let transaction = try flowAPI.getTransactionById(id: id).wait()
        XCTAssertEqual(transaction?.payerAddress.bytes.hexValue, "1f56a1e665826a52")
        XCTAssertNotNil(transaction)
    }

    func testTransactionResultById() throws {
        // Example for mainnet
        let id = Flow.Id(hex: "6d6c20405f3dd2001361cd994493a56d31f4daa1c7ce420a2cd4259454b4a0da")
        let result = try flowAPI.getTransactionResultById(id: id).wait()
        XCTAssertEqual(result?.events.count, 3)
        XCTAssertEqual(result?.events.first?.type, "A.c38aea683c0c4d38.Eternal.Withdraw")
        XCTAssertNotNil(result)
    }
}
