// import Flow
// @testable import FlowSwift
// import XCTest

// final class FlowClientTestsEvents: XCTestCase {
//    let client = FlowClient()
//    var latestBlock: FlowBlock = FlowBlock()
//
//    public override func setUp() {
//        // make a transaction to create an event
//
//        let keychain: MemoryKeychain = MemoryKeychain()
//        try! keychain.addKey(address: FlowAddress("f8d6e0586b0a20c7"),
//                             key: FlowKey(address: FlowAddress("f8d6e0586b0a20c7"),
//                                          keyId: 0,
//                                          key: "38b6f958c11a79312b1e44ba825299c03b9eaa362d571662366cdb4e08b59c32",
//                                          signingAlgorithm: FlowSignatureAlgorithm.ECDSA_P256,
//                                          hashAlgorithm: FlowHashAlgorithm.SHA3_256))
//
//        let script = "transaction {prepare(acct: AuthAccount) {} execute {}}"
//
//        _ = try! client.sendTransaction(script: script,
//                                        singleSigner: "f8d6e0586b0a20c7",
//                                        keychain: keychain).wait()
//
//        latestBlock = try! client.getLatestBlock(isSealed: true).wait()
//    }
//
//    func testRetrieveEvents() {
//        let expectation = XCTestExpectation(description: "retrieve the latest block")
//        let results = try! client.getEventsForHeightRange("xxx",
//                                                          start: 0,
//                                                          end: 200).wait()
//        XCTAssertEqual(results.events.count, 1)
//
//        wait(for: [expectation], timeout: 5)
//    }
//
//    // MARK: - Accounts
//
//    /* retrieve an account by address
//     create a new account
//     deploy a new contract to the account
//     remove a contract from the account
//     update an existing contract on the account
//     */
//
//    // MARK: - Transactions
//
//    // retrieve a transaction by ID
//    // sign a transaction (single payer, proposer, authorizer or combination of multiple)
//    // submit a signed transaction
//    // sign a transaction with arguments and submit it
// }
