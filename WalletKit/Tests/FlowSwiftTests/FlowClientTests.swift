import Flow
@testable import FlowSwift
import XCTest

final class FlowClientTests: XCTestCase {
    let client = FlowClient()

    func testFlowClientConnection() {
        let expectation = XCTestExpectation(description: "test Flow Client connection.")

        client.ping { response in
            XCTAssertNil(response.error, "Client connection error: \(String(describing: response.error?.localizedDescription)).")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    func testRetrieveCollectionById() {
        let expectation = XCTestExpectation(description: "retrieve the latest block")

        client.getLatestBlock(isSealed: true) { latestBlockResponse in
            XCTAssertNil(latestBlockResponse.error, "getLatestBlock error: \(String(describing: latestBlockResponse.error?.localizedDescription)).")
            // let latestBlock = latestBlockResponse.result as! FlowBlock
        }
        wait(for: [expectation], timeout: 5)
    }
}
