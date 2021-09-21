// import FlowFoundation
// @testable import FlowSwift
// import XCTest

// final class FlowClientTestsBlocks: XCTestCase {
//    let client = FlowClient()
//    var latestBlock: FlowBlock = FlowBlock()
//
//    public override func setUp() {
//        latestBlock = try! client.getLatestBlock(isSealed: true).wait()
//    }
//
//    func testRetrieveBlockById() {
//        let expectation = XCTestExpectation(description: "retrieve a block by ID")
//        client.getBlockById(id: latestBlock.id) { response in
//            XCTAssertNil(response.error, "getBlockById error: \(String(describing: response.error?.localizedDescription)).")
//            expectation.fulfill()
//
//            let block = response.result as! FlowBlock
//            print(block.pretty)
//            XCTAssertEqual(self.latestBlock, block)
//        }
//        wait(for: [expectation], timeout: 5)
//    }
//
//    func testRetrieveBlockByHeight() {
//        let expectation = XCTestExpectation(description: "retrieve a block by height")
//        client.getBlockByHeight(height: latestBlock.height) { response in
//            XCTAssertNil(response.error, "getBlockByHeight error: \(String(describing: response.error?.localizedDescription)).")
//            expectation.fulfill()
//
//            let block = response.result as! FlowBlock
//            print(block.pretty)
//            XCTAssertEqual(self.latestBlock, block)
//        }
//        wait(for: [expectation], timeout: 5)
//    }
//
//    func testRetrieveLatestBlock() {
//        let expectation = XCTestExpectation(description: "retrieve the latest block")
//
//        client.getLatestBlock(isSealed: true) { latestBlockResponse in
//            XCTAssertNil(latestBlockResponse.error, "getLatestBlock error: \(String(describing: latestBlockResponse.error?.localizedDescription)).")
//            // let latestBlock = latestBlockResponse.result as! FlowBlock
//        }
//        wait(for: [expectation], timeout: 5)
//    }
// }
