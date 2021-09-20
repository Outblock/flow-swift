import Flow
@testable import FlowSwift
import XCTest

final class FlowClientTestsCollections: XCTestCase {
    let client = FlowClient()
    var latestBlock: FlowBlock = FlowBlock()

    public override func setUp() {
        // make a transaction to create a collection on latest block

        let keychain: MemoryKeychain = MemoryKeychain()
        try! keychain.addKey(address: FlowAddress("f8d6e0586b0a20c7"),
                             key: FlowKey(address: FlowAddress("f8d6e0586b0a20c7"),
                                          keyId: 0,
                                          key: "38b6f958c11a79312b1e44ba825299c03b9eaa362d571662366cdb4e08b59c32",
                                          signingAlgorithm: FlowSignatureAlgorithm.ECDSA_P256,
                                          hashAlgorithm: FlowHashAlgorithm.SHA3_256))

        let script = "transaction {prepare(acct: AuthAccount) {} execute {}}"

        _ = try! client.sendTransaction(script: script,
                                        singleSigner: "f8d6e0586b0a20c7",
                                        keychain: keychain).wait()

        latestBlock = try! client.getLatestBlock(isSealed: true).wait()
    }

    func testRetrieveCollectionByID() {
        let expectation = XCTestExpectation(description: "retrieve the latest block")

        let collectionId = latestBlock.collectionGuarantees[0].collectionId
        client.getCollectionById(id: collectionId) { response in
            XCTAssertNil(response.error, "getCollectionByID error: \(String(describing: response.error?.localizedDescription)).")

            // check here
            let collection = response.result as! FlowCollection
            XCTAssertEqual(collection.id, collectionId)

            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    // MARK: - Events

    // retrieve events by name in the block height range

    // MARK: - Scripts

    //  submit a script and parse the response
    // submit a script with arguments and parse the response

    // MARK: - Accounts

    /* retrieve an account by address
     create a new account
     deploy a new contract to the account
     remove a contract from the account
     update an existing contract on the account
     */

    // MARK: - Transactions

    // retrieve a transaction by ID
    // sign a transaction (single payer, proposer, authorizer or combination of multiple)
    // submit a signed transaction
    // sign a transaction with arguments and submit it
}
