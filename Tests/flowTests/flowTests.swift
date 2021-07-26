@testable import Flow
import XCTest

final class flowTests: XCTestCase {
    var flowAPI: FlowAccessAPI!
    var testAddress = "36bb8baed19294f3"

    override func setUp() {
        super.setUp()
        let flowInstance = Flow.shared
        flowAPI = flowInstance.newAccessApi(host: "access.devnet.nodes.onflow.org")
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
            XCTAssertEqual(chainId, FlowChainId.testnet)
        } catch {
            print(error)
            XCTAssertNotNil(nil, "getNetworkParameters failed")
        }
    }

    func testBlockHeader() {
        do {
            let blockHeader = try flowAPI.getLatestBlockHeader().wait()
            print(blockHeader)
        } catch {
            print(error)
            XCTAssertNotNil(nil, "getNetworkParameters failed")
        }
    }

    func testGetAccount() {
        do {
            let address = FlowAddress(hex: testAddress)
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
            let address = FlowAddress(hex: testAddress)
            let account = try flowAPI.getAccountByBlockHeight(address: address, height: 39_896_150).wait()
            XCTAssertNotNil(account?.keys.first)
            XCTAssertEqual(address, account?.address)
        } catch {
            print(error)
            XCTAssertNotNil(nil, "testGetAccount failed")
        }
    }
}
