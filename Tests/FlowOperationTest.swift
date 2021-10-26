//
//  FlowOperationTest
//
//  Copyright 2021 Zed Labs Pty Ltd
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

@testable import BigInt
import Combine
import CryptoKit
@testable import Flow
import XCTest

// To avoid unnecessary network call, we have disabled all unit test in here.
// If you wanna to run it, please change the func name from `exampleXXX` to `testXXX`.
// For example:
// func exampleAddContractToAccount() -> func testAddContractToAccount()

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

    func exampleAddContractToAccount() {
        let texID = try! flow.addContractToAccount(address: address, contractName: scriptName, code: script, signers: signers).wait()
        XCTAssertNotNil(texID)
    }

    func exampleRemoveAccountKeyByIndex() {
        let txID = try! flow.removeAccountKeyByIndex(address: address, keyIndex: 4, signers: signers).wait()
        XCTAssertNotNil(txID)
    }

    func exampleAddKeyToAccount() {
        let accountKey = Flow.AccountKey(publicKey: Flow.PublicKey(hex: privateKeyA.publicKey.rawRepresentation.hexValue),
                                         signAlgo: .ECDSA_P256,
                                         hashAlgo: .SHA2_256,
                                         weight: 1000)


        let txID  = try! flow.addKeyToAccount(address: address, accountKey: accountKey, signers: signers).wait()
        XCTAssertNotNil(txID)

    }

    func exampleUpdateContractOfAccount() {
        let script2 = """
        pub contract HelloWorld {
        
        pub struct SomeStruct {
          pub var x: Int
          pub var y: Int

          init(x: Int, y: Int) {
            self.x = x
            self.y = y
          }
        }
        
            pub let greeting: String
        
            init() {
                self.greeting = "Hello World!"
            }
        }
        """

        let txID = try! flow.updateContractOfAccount(address: address, contractName: scriptName, script: script2, signers: signers).wait()
        XCTAssertNotNil(txID)
    }
    
    func exampleCreateAccount() {
        let accountKey = Flow.AccountKey(publicKey: Flow.PublicKey(hex: privateKeyA.publicKey.rawRepresentation.hexValue),
                                         signAlgo: .ECDSA_P256,
                                         hashAlgo: .SHA2_256,
                                         weight: 1000)

        let txID = try! flow.createAccount(address: address,
                                           publicKeys: [accountKey],
                                           contracts: [scriptName: script],
                                           signers: signers).wait()
        
        print("testCreateAccount -> \(txID.hex)")
        XCTAssertNotNil(txID)
        let result = try! txID.onceSealed().wait()
        let event = result.events.first{ $0.type == "flow.AccountCreated" }
        let field = event?.payload.fields?.value.toEvent()?.fields.first{$0.name == "address"}
        let address = field?.value.value.toAddress()
        XCTAssertNotNil(address?.hex)
    }

    func exampleRemoveContractFromAccount() {
        let txID = try! flow.removeContractFromAccount(address: address, contractName: scriptName, signers: signers)
        XCTAssertNotNil(txID)
    }
}
