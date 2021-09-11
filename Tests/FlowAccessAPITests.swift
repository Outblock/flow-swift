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
        let id = Flow.Id(hex: "0x3cb82cf886ac5b4c683280b122a3ae7dde97721ebdf3e94c3fc8965d936839f4")
        let blockHeader = try flowAPI.getBlockById(id: id).wait()
        XCTAssertNotNil(blockHeader)
        XCTAssertEqual(blockHeader?.height, 16_925_837)
    }

    func testGetAccountByHeight() throws {
        let address = Flow.Address(hex: testAddress)
        let account = try flowAPI.getAccountByBlockHeight(address: address, height: 16_925_668).wait()
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
        let id = Flow.Id(hex: "53cc748124358855ec4d975ce6511ba016f5d2dfcead1527fd858579fc7baf76")
        let collection = try flowAPI.getCollectionById(id: id).wait()
        XCTAssertNotNil(collection)
    }

    func testTransactionById() throws {
        // Example for mainnet
        let id = Flow.Id(hex: "6d6c20405f3dd2001361cd994493a56d31f4daa1c7ce420a2cd4259454b4a0da")
        let transaction = try flowAPI.getTransactionById(id: id).wait()
        XCTAssertEqual(transaction?.arguments.first?.type, Flow.Cadence.FType.path)
        XCTAssertEqual(transaction?.arguments.first?.value, Flow.Cadence.ValueType.path(value: Flow.Argument.Path(domain: "public", identifier: "zelosAccountingTokenReceiver")))
        XCTAssertEqual(transaction?.arguments.last?.type, Flow.Cadence.FType.ufix64)
        XCTAssertEqual(transaction?.arguments.last?.value, Flow.Cadence.ValueType.ufix64(value: 99.0))
        XCTAssertEqual(transaction?.payerAddress.bytes.hexValue, "1f56a1e665826a52")
        XCTAssertNotNil(transaction)
    }

    func testTransactionResultById() throws {
        // Example for mainnet
        let id = Flow.Id(hex: "6d6c20405f3dd2001361cd994493a56d31f4daa1c7ce420a2cd4259454b4a0da")
        let result = try flowAPI.getTransactionResultById(id: id).wait()
        XCTAssertEqual(result?.events.count, 3)
        XCTAssertEqual(result?.events.first?.type, "A.c38aea683c0c4d38.Eternal.Withdraw")
        XCTAssertEqual(result?.events.first?.payload.fields?.type, Flow.Cadence.FType.event)
        XCTAssertEqual(result?.events.first?.payload.fields?.value, Flow.Cadence.ValueType.event(value: Flow.Argument.Event(id: "A.c38aea683c0c4d38.Eternal.Withdraw", fields: [Flow.Argument.EventName(name: "id", value: Flow.Argument(type: .uint64, value: .uint64(value: 11800))), Flow.Argument.EventName(name: "from", value: Flow.Argument(type: .optional, value: .optional(value: Flow.Argument(type: .address, value: .address(value: "0x873becfb539f038d")))))])))
        XCTAssertNotNil(result)
    }
}
