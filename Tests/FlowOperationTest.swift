@testable import BigInt
import Combine
import CryptoKit
@testable import Flow
import XCTest

final class FlowOperationTests: XCTestCase {
    var address = Flow.Address(hex: "0xe242ccfb4b8ea3e2")
    let publicKey = try! P256.KeyAgreement.PublicKey(rawRepresentation: "adbf18dae6671e6b6a92edf00c79166faba6babf6ec19bd83eabf690f386a9b13c8e48da67973b9cf369f56e92ec25ede5359539f687041d27d0143afd14bca9".hexValue)
    let privateKey = try! P256.Signing.PrivateKey(rawRepresentation: "1eb79c40023143821983dc79b4e639789ea42452e904fda719f5677a1f144208".hexValue)

    let privateKeyA = try! P256.Signing.PrivateKey(rawRepresentation: "c9c0f04adddf7674d265c395de300a65a777d3ec412bba5bfdfd12cffbbb78d9".hexValue)

    private var cancellables = Set<AnyCancellable>()

    let scriptName = "HelloWorld"
    let script = """
    pub contract HelloWorld {
    
        pub let greeting: String
    
        pub fun hello(): String {
            return self.greeting
        }

        init() {
            self.greeting = "Hello World!"
        }
    }
    """

    var signers: [ECDSA_P256_Signer] = []

    override func setUp() {
        super.setUp()
        flow.configure(chainID: .testnet)
        signers.append(ECDSA_P256_Signer(address: address, keyIndex: 0, privateKey: privateKey))
    }

    func testCreateAccount() {
        let expectation = XCTestExpectation(description: "Wait for sending transaction")

        let accountKey = Flow.AccountKey(publicKey: Flow.PublicKey(hex: privateKeyA.publicKey.rawRepresentation.hexValue),
                                         signAlgo: .ECDSA_P256,
                                         hashAlgo: .SHA2_256,
                                         weight: 1000)

        flow.createAccount(address: address, publicKeys: [accountKey], contracts: [scriptName: script], signers: signers)
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTFail(error.localizedDescription)
                }
            } receiveValue: { txID in
                XCTAssertNotNil(txID)
                expectation.fulfill()
                print(txID.hex)
            }.store(in: &cancellables)

        wait(for: [expectation], timeout: 10.0)
    }

    func testAddContractToAccount() {
        let expectation = XCTestExpectation(description: "Wait for sending transaction")
        flow.addContractToAccount(address: address, contractName: scriptName, code: script, signers: signers)
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTFail(error.localizedDescription)
                }
            } receiveValue: { txID in
                XCTAssertNotNil(txID)
                expectation.fulfill()
                print(txID.hex)
            }.store(in: &cancellables)

        wait(for: [expectation], timeout: 10.0)
    }

    func testRemoveAccountKeyByIndex() {
        let expectation = XCTestExpectation(description: "Wait for sending transaction")
        flow.removeAccountKeyByIndex(address: address, keyIndex: 4, signers: signers)
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTFail(error.localizedDescription)
                }
            } receiveValue: { txID in
                XCTAssertNotNil(txID)
                expectation.fulfill()
                print(txID.hex)
            }.store(in: &cancellables)

        wait(for: [expectation], timeout: 10.0)
    }

    func testAddKeyToAccount() {
        let accountKey = Flow.AccountKey(publicKey: Flow.PublicKey(hex: privateKeyA.publicKey.rawRepresentation.hexValue),
                                         signAlgo: .ECDSA_P256,
                                         hashAlgo: .SHA2_256,
                                         weight: 1000)

        let expectation = XCTestExpectation(description: "Wait for sending transaction")
        flow.addKeyToAccount(address: address, accountKey: accountKey, signers: signers)
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTFail(error.localizedDescription)
                }
            } receiveValue: { txID in
                XCTAssertNotNil(txID)
                expectation.fulfill()
                print(txID.hex)
            }.store(in: &cancellables)

        wait(for: [expectation], timeout: 10.0)
    }

    func testUpdateContractOfAccount() {
        let expectation = XCTestExpectation(description: "Wait for sending transaction")

        let script2 = """
        pub contract HelloWorld {
        
            pub let greeting: String
        
            init() {
                self.greeting = "Hello World!"
            }
        }
        """

        flow.updateContractOfAccount(address: address, contractName: scriptName, script: script2, signers: signers)
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTFail(error.localizedDescription)
                }
            } receiveValue: { txID in
                XCTAssertNotNil(txID)
                expectation.fulfill()
                print(txID.hex)
            }.store(in: &cancellables)

        wait(for: [expectation], timeout: 10.0)
    }

    func testRemoveContractFromAccount() {
        let expectation = XCTestExpectation(description: "Wait for sending transaction")
        flow.removeContractFromAccount(address: address, contractName: scriptName, signers: signers)
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTFail(error.localizedDescription)
                }
            } receiveValue: { txID in
                XCTAssertNotNil(txID)
                expectation.fulfill()
                print(txID.hex)
            }.store(in: &cancellables)

        wait(for: [expectation], timeout: 10.0)
    }
}
