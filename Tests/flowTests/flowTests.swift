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
            let id = FlowId(hex: "0x1d9b2440e79953c5107226d1899bc997cd3a26d71daa97a937b0705fb9ae774e")
            let blockHeader = try flowAPI.getBlockById(id: id).wait()
            print(blockHeader)
//            XCTAssertNotNil(account?.keys.first)
//            XCTAssertEqual(address, account?.address)
        } catch {
            print(error)
            XCTAssertNotNil(nil, "testGetAccount failed")
        }
    }

    func testGetAccountByHeight() {
        do {
            let address = FlowAddress(hex: testAddress)
            let account = try flowAPI.getAccountByBlockHeight(address: address, height: 16_896_536).wait()
            XCTAssertNotNil(account?.keys.first)
            XCTAssertEqual(address, account?.address)
        } catch {
            print(error)
            XCTAssertNotNil(nil, "testGetAccount failed")
        }
    }
}
