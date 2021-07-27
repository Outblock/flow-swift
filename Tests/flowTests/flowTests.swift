@testable import Flow
import XCTest

final class flowTests: XCTestCase {
    var flowAPI: FlowAccessAPI!
    var testAddress = "36bb8baed19294f3"

    override func setUp() {
        super.setUp()
        let flowInstance = Flow.shared
        flowAPI = flowInstance.newAccessApi(chainId: .mainnet)
    }

    func testFlowPing() {
        do {
            let isConnected = try flowAPI.ping().wait()
            XCTAssertTrue(isConnected)
        } catch {
            print(error)
            XCTAssertNotNil(nil, "getNetworkParameters failed")
        }
    }

    func testNetworkParameters() {
        do {
            let chainId = try flowAPI.getNetworkParameters().wait()
            XCTAssertEqual(chainId, Flow.ChainId.testnet)
        } catch {
            print(error)
            XCTAssertNotNil(nil, "getNetworkParameters failed")
        }
    }

    func testBlockHeader() {
        do {
            let blockHeader = try flowAPI.getLatestBlockHeader().wait()
            XCTAssertNotNil(blockHeader)
        } catch {
            print(error)
            XCTAssertNotNil(nil, "getNetworkParameters failed")
        }
    }

    func testGetAccount() {
        do {
            let address = Flow.Address(hex: testAddress)
            let account = try flowAPI.getAccountAtLatestBlock(address: address).wait()
            XCTAssertNotNil(account?.keys.first)
            XCTAssertEqual(address, account?.address)
        } catch {
            print(error)
            XCTAssertNotNil(nil, "testGetAccount failed")
        }
    }

    func testGetBlockHeaderByID() {
        do {
            let id = Flow.Id(hex: "d35f636db8becc4ac9833b1c63a9fd4624269b933217aa2e0fc2e786130b73a6")
            let blockHeader = try flowAPI.getBlockById(id: id).wait()
            XCTAssertNotNil(blockHeader)
            XCTAssertEqual(blockHeader?.height, 39_896_150)
        } catch {
            print(error)
            XCTAssertNotNil(nil, "testGetAccount failed")
        }
    }

    func testGetAccountByHeight() {
        do {
            let address = Flow.Address(hex: testAddress)
            let account = try flowAPI.getAccountByBlockHeight(address: address, height: 39_896_150).wait()
            XCTAssertNotNil(account?.keys.first)
            XCTAssertEqual(address, account?.address)
        } catch {
            print(error)
            XCTAssertNotNil(nil, "testGetAccount failed")
        }
    }

    func testGetLatestBlock() {
        do {
            let block = try flowAPI.getLatestBlock(sealed: true).wait()
            XCTAssertNotNil(block)
        } catch {
            print(error)
            XCTAssertNotNil(nil, "testGetAccount failed")
        }
    }

    func testGetLatestProtocolStateSnapshot() {
        do {
            let snapshot = try flowAPI.getLatestProtocolStateSnapshot().wait()
            XCTAssertNotNil(snapshot)
        } catch {
            print(error)
            XCTAssertNotNil(nil, "testGetAccount failed")
        }
    }

    func testSendTransaction() {
        // TODO:
    }

    func testGetCollectionById() {
        do {
            // Example for mannet
            let id = Flow.Id(hex: "6d6c20405f3dd2001361cd994493a56d31f4daa1c7ce420a2cd4259454b4a0da")
            let collection = try flowAPI.getCollectionById(id: id).wait()
            XCTAssertNotNil(collection)
        } catch {
            print(error)
            XCTAssertNotNil(nil, "testGetAccount failed")
        }
    }

    func testTransactionById() {
        do {
            // Example for mannet
            let id = Flow.Id(hex: "6d6c20405f3dd2001361cd994493a56d31f4daa1c7ce420a2cd4259454b4a0da")
            let transaction = try flowAPI.getTransactionById(id: id).wait()
            XCTAssertEqual(transaction?.payerAddress.bytes.hexValue, "1f56a1e665826a52")
            XCTAssertNotNil(transaction)
        } catch {
            print(error)
            XCTAssertNotNil(nil, "testGetAccount failed")
        }
    }

    func testTransactionResultById() {
        do {
            // Example for mannet
            let id = Flow.Id(hex: "6d6c20405f3dd2001361cd994493a56d31f4daa1c7ce420a2cd4259454b4a0da")
            let result = try flowAPI.getTransactionResultById(id: id).wait()
            XCTAssertEqual(result?.events.count, 3)
            XCTAssertEqual(result?.events.first?.type, "A.c38aea683c0c4d38.Eternal.Withdraw")
            XCTAssertNotNil(result)
        } catch {
            print(error)
            XCTAssertNotNil(nil, "testGetAccount failed")
        }
    }
}
