@testable import BigInt
import CryptoKit
@testable import Flow
import XCTest

final class FlowAccessAPITests: XCTestCase {
    var flowAPI: FlowAccessAPI!
    var testAddress = "7907881e2e2cdfb7"
    var mainnetAddress = "0x4eb165aa383fd6f9"

    let addressA = Flow.Address(hex: "0xc6de0d94160377cd")
    let publicKeyA = try! P256.KeyAgreement.PublicKey(rawRepresentation: "d487802b66e5c0498ead1c3f576b718949a3500218e97a6a4a62bf69a8b0019789639bc7acaca63f5889c1e7251c19066abb09fcd6b273e394a8ac4ee1a3372f".hexValue)
    let privateKeyA = try! P256.Signing.PrivateKey(rawRepresentation: "c9c0f04adddf7674d265c395de300a65a777d3ec412bba5bfdfd12cffbbb78d9".hexValue)

    var addressB = Flow.Address(hex: "0x10711015c370a95c")
    let publicKeyB = try! P256.KeyAgreement.PublicKey(rawRepresentation: "6278ff9fdf75c5830e4aafbb8cc25af50b62869d7bc9b249e76aae31490199732b769d1df627d36e5e336aeb4cb06b0fad80ae13a25aca37ec0017e5d8f1d8a5".hexValue)
    let privateKeyB = try! P256.Signing.PrivateKey(rawRepresentation: "38ebd09b83e221e406b176044a65350333b3a5280ed3f67227bd80d55ac91a0f".hexValue)

    var addressC = Flow.Address(hex: "0xe242ccfb4b8ea3e2")
    let publicKeyC = try! P256.KeyAgreement.PublicKey(rawRepresentation: "adbf18dae6671e6b6a92edf00c79166faba6babf6ec19bd83eabf690f386a9b13c8e48da67973b9cf369f56e92ec25ede5359539f687041d27d0143afd14bca9".hexValue)
    let privateKeyC = try! P256.Signing.PrivateKey(rawRepresentation: "1eb79c40023143821983dc79b4e639789ea42452e904fda719f5677a1f144208".hexValue)

    override func setUp() {
        super.setUp()
        flowAPI = flow.newAccessApi(chainId: .mainnet)
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
        let address = Flow.Address(hex: mainnetAddress)
        let account = try flowAPI.getAccountAtLatestBlock(address: address).wait()
        XCTAssertNotNil(account?.keys.first)
        XCTAssertEqual(address, account?.address)
    }

    func testGetBlockHeaderByID() throws {
        let block = try flowAPI.getLatestBlock(sealed: true).wait()
        XCTAssertNotNil(block)

        let blockHeader = try flowAPI.getBlockById(id: block.id).wait()
        XCTAssertNotNil(blockHeader)
        XCTAssertEqual(blockHeader?.height, block.height)
    }

    func testGetAccountByHeight() throws {
        let address = Flow.Address(hex: mainnetAddress)
        let block = try flowAPI.getLatestBlock(sealed: true).wait()
        XCTAssertNotNil(block)
        let account = try flowAPI.getAccountByBlockHeight(address: address, height: block.height).wait()
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

    func testExecuteScriptAtLastestBlock() throws {
        let script = Flow.Script(script: """
        pub struct SomeStruct {
          pub var x: Int
          pub var y: Int

          init(x: Int, y: Int) {
            self.x = x
            self.y = y
          }
        }

        pub fun main(): [SomeStruct] {
          return [SomeStruct(x: 1, y: 2), SomeStruct(x: 3, y: 4)]
        }
        """)
        let snapshot = try flowAPI.executeScriptAtLatestBlock(script: script, arguments: []).wait()
        XCTAssertNotNil(snapshot)
        XCTAssertEqual(Flow.Cadence.FType.array, snapshot.fields?.type)

        guard case let .array(value: value) = snapshot.fields!.value else { XCTFail(); return }
        guard case let .struct(value: firstStruct) = value.first!.value else { XCTFail(); return }

        XCTAssertEqual(firstStruct.fields.first!.name, "x")
        XCTAssertEqual(firstStruct.fields.first!.value.value.toInt(), 1)
        XCTAssertEqual(firstStruct.fields.last!.name, "y")
        XCTAssertEqual(firstStruct.fields.last!.value.value.toInt(), 2)
    }

    func testCanCreateAccount() throws {
        // Example in Testnet
        let address = addressC
        let signer = [ECDSA_P256_Signer(address: address, keyIndex: 0, privateKey: privateKeyC)]
        let accountKey = Flow.AccountKey(publicKey: Flow.PublicKey(hex: privateKeyA.publicKey.rawRepresentation.hexValue),
                                         signAlgo: .ECDSA_P256,
                                         hashAlgo: .SHA2_256,
                                         weight: 1000)

        let txId = try! flow.sendTransaction(chainId: .testnet, signers: signer) {
            cadence {
                """
                    transaction(publicKey: String) {
                        prepare(signer: AuthAccount) {
                            let account = AuthAccount(payer: signer)
                            account.addPublicKey(publicKey.decodeHex())
                        }
                    }
                """
            }

            proposer {
                address
            }

            authorizers {
                address
            }

            arguments {
                .init(value: .string(value: accountKey.encoded!.hexValue))
            }

            // optional
            gasLimit {
                1000
            }
        }.wait()

        XCTAssertNotNil(txId)
        print("txid --> \(txId.hex)")
    }

    func testGetCollectionById() throws {
//        let id = Flow.Id(hex: "53cc748124358855ec4d975ce6511ba016f5d2dfcead1527fd858579fc7baf76")
//        let collection = try flowAPI.getCollectionById(id: id).wait()
//        XCTAssertNotNil(collection)
    }

    func testTransactionById() throws {
        let id = Flow.Id(hex: "6d6c20405f3dd2001361cd994493a56d31f4daa1c7ce420a2cd4259454b4a0da")
        let transaction = try flowAPI.getTransactionById(id: id).wait()
        XCTAssertEqual(transaction?.arguments.first?.type, .path)
        XCTAssertEqual(transaction?.arguments.first?.value, .path(value: .init(domain: "public", identifier: "zelosAccountingTokenReceiver")))
        XCTAssertEqual(transaction?.arguments.last?.type, .ufix64)
        XCTAssertEqual(transaction?.arguments.last?.value, .ufix64(value: 99.0))
        XCTAssertEqual(transaction?.payerAddress.bytes.hexValue, "1f56a1e665826a52")
        XCTAssertNotNil(transaction)
    }

    func testTransactionResultById() throws {
        let id = Flow.Id(hex: "6d6c20405f3dd2001361cd994493a56d31f4daa1c7ce420a2cd4259454b4a0da")
        let result = try flowAPI.getTransactionResultById(id: id).wait()
        XCTAssertEqual(result?.events.count, 3)
        XCTAssertEqual(result?.events.first?.type, "A.c38aea683c0c4d38.Eternal.Withdraw")
        XCTAssertEqual(result?.events.first?.payload.fields?.type, .event)
        XCTAssertEqual(result?.events.first?.payload.fields?.value,
                       .event(value: .init(id: "A.c38aea683c0c4d38.Eternal.Withdraw",
                                           fields: [.init(name: "id", value: .init(value: .uint64(value: 11800))),
                                                    .init(name: "from", value: .init(value: .optional(value: .init(value: .address(value: .init(hex: "0x873becfb539f038d"))))))])))
        XCTAssertNotNil(result)
    }

    func testMultipleSigner() throws {
        // Example in Testnet

        let signers = [
            // Address A
            ECDSA_P256_Signer(address: addressA, keyIndex: 5, privateKey: privateKeyB), // weight: 500
            ECDSA_P256_Signer(address: addressA, keyIndex: 4, privateKey: privateKeyC), // weight: 500
            // Address B
            ECDSA_P256_Signer(address: addressB, keyIndex: 2, privateKey: privateKeyA), // weight: 800
            ECDSA_P256_Signer(address: addressB, keyIndex: 1, privateKey: privateKeyC), // weight: 500
            // Address C
            ECDSA_P256_Signer(address: addressC, keyIndex: 3, privateKey: privateKeyB), // weight: 300
            ECDSA_P256_Signer(address: addressC, keyIndex: 2, privateKey: privateKeyB), // weight: 500
            ECDSA_P256_Signer(address: addressC, keyIndex: 4, privateKey: privateKeyA), // weight: 300
        ]

        let txId = try! flow.sendTransactionWithWait(chainId: .testnet,
                                                     signers: signers) {
            cadence {
                """
                    transaction {
                        prepare(signer1: AuthAccount, signer2: AuthAccount, signer3: AuthAccount) {
                          log(signer1.address)
                          log(signer2.address)
                          log(signer3.address)
                      }
                    }
                """
            }

            proposer {
                .init(address: addressA, keyIndex: 4)
            }

            payer {
                self.addressB
            }

            authorizers {
                [self.addressC, self.addressB, self.addressA]
            }
        }

        XCTAssertNotNil(txId)
        print("txid --> \(txId.hex)")
    }
}
