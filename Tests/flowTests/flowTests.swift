@testable import Flow
import XCTest

final class flowTests: XCTestCase {
    var flowAPI: FlowAccessAPI!
    var testAddress = "36bb8baed19294f3"

    override func setUp() {
        super.setUp()
        let flowInstance = Flow.shared
        flowAPI = flowInstance.newAccessApi(chainId: .testnet)
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
            let id = FlowId(hex: "d35f636db8becc4ac9833b1c63a9fd4624269b933217aa2e0fc2e786130b73a6")
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

//    func testSendTransaction() {
//        do {
//            let transaction = Flow.Transaction(value: <#T##Flow_Entities_Transaction#>)
//            let snapshot = try flowAPI.sendTransaction(transaction: transaction).wait()
//            XCTAssertNotNil(snapshot)
//        } catch {
//            print(error)
//            XCTAssertNotNil(nil, "testGetAccount failed")
//        }
//    }
}
