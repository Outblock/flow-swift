//
//  File.swift
//  
//
//  Created by Hao Fu on 28/4/2022.
//

import Foundation
@testable import BigInt
import CryptoKit
@testable import Flow
import XCTest
import Combine

final class DomainTests: XCTestCase {
    
    var flowAPI: Flow.AccessAPI!

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
        flowAPI = flow.createAccessAPI(chainID: .testnet)
        flow.configure(chainID: .testnet)
    }
    
    func getSigners() -> [FlowSigner] {
        return [
            // Address A
    //            ECDSA_P256_Signer(address: addressA, keyIndex: 5, privateKey: privateKeyB), // weight: 500
            ECDSA_P256_Signer(address: self.addressA, keyIndex: 0, privateKey: privateKeyA), // weight: 1000
            // Address B
            ECDSA_P256_Signer(address: self.addressB, keyIndex: 2, privateKey: privateKeyA), // weight: 800
            ECDSA_P256_Signer(address: self.addressB, keyIndex: 1, privateKey: privateKeyC), // weight: 500
            // Address C
    //            ECDSA_P256_Signer(address: addressC, keyIndex: 3, privateKey: privateKeyB), // weight: 300
    //            ECDSA_P256_Signer(address: addressC, keyIndex: 2, privateKey: privateKeyB), // weight: 500
            ECDSA_P256_Signer(address: self.addressC, keyIndex: 0, privateKey: privateKeyC), // weight: 1000
        ]
    }
    
    func testSingleSign() {
        var unsignedTx = try! flow.buildTransaction {
            cadence {
                """
                import HelloWorld from 0xe242ccfb4b8ea3e2
                transaction(test: String) {
                   prepare(signer: AuthAccount) {
                        log(signer.address)
                        log(test)
                   }
                }
                """
            }

            proposer {
                Flow.TransactionProposalKey(address: addressC, keyIndex: 0)
            }

            authorizers {
                [self.addressA]
            }
            
            arguments {
                [.string("Test")]
            }

            // optional
            gasLimit {
                1000
            }
        }

        let signedTx = try! unsignedTx.sign(signers: getSigners())
        let txId = try! flow.sendTransaction(signedTransaction: signedTx).wait()
        XCTAssertNotNil(txId)
        print("txid --> \(txId.hex)")
    }
    
    @available(iOS 15.0, *)
    func testMultiplePartySign() async throws {
        // Example in Testnet

        var unsignedTx = try! flow.buildTransaction {
            cadence {
                """
                import Domains from 0xb05b2abb42335e88
                import Flowns from 0xb05b2abb42335e88
                import NonFungibleToken from 0x631e88ae7f1d7c20
                import FungibleToken from 0x9a0766d93b6608b7

                transaction(name: String) {
                 let client: &{Flowns.AdminPrivate}
                 let receiver: Capability<&{NonFungibleToken.Receiver}>
                 prepare(user: AuthAccount, lilico: AuthAccount, flowns: AuthAccount) {
                   let userAcc = getAccount(user.address)
                    // check user balance
                   let userBalRef = userAcc.getCapability(/public/flowTokenBalance).borrow<&{FungibleToken.Balance}>()
                   if balanceRef.balance < 0.001 {
                     let vaultRef = flowns.borrow<&FungibleToken.Vault>(from: /storage/flowTokenVault)
                     let userReceiverRef =  userAcc.getCapability(/public/flowTokenReceiver).borrow<&{FungibleToken.Receiver}>()
                     userReceiverRef.deposit(from: <- vaultRef.withdraw(amount: 0.001))
                   }
                 
                   // init user's domain collection
                   if user.getCapability<&{NonFungibleToken.Receiver}>(Domains.CollectionPublicPath).check() == false {
                     if user.borrow<&Domains.Collection>(from: Domains.CollectionStoragePath) != nil {
                       user.unlink(Domains.CollectionPublicPath)
                       user.link<&Domains.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, Domains.CollectionPublic}>(Domains.CollectionPublicPath, target: Domains.CollectionStoragePath)
                     } else {
                       user.save(<- Domains.createEmptyCollection(), to: Domains.CollectionStoragePath)
                       user.link<&Domains.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, Domains.CollectionPublic}>(Domains.CollectionPublicPath, target: Domains.CollectionStoragePath)
                     }
                   }

                   self.receiver = userAcc.getCapability<&{NonFungibleToken.Receiver}>(Domains.CollectionPublicPath)
                   
                   self.client = flowns.borrow<&{Flowns.AdminPrivate}>(from: Flowns.FlownsAdminStoragePath) ?? panic("Could not borrow admin client")
                 }
                 execute {
                   self.client.mintDomain(domainId: 1, name: name, duration: 3153600000.00, receiver: self.receiver)
                 }
                }
                """
            }

            proposer {
                Flow.TransactionProposalKey(address: addressC, keyIndex: 0)
            }

            authorizers {
                [self.addressC, self.addressA, .init(hex: "0xb05b2abb42335e88")]
            }
            
            payer {
                self.addressA
            }

            arguments {
                [.string("Test")]
            }

            // optional
            gasLimit {
                1000
            }
        }

        let notFinishedTx = try! unsignedTx.signPayload(signers: getSigners())
        
        let model = TestModel(transaction: notFinishedTx, message: notFinishedTx.signablePlayload?.hexValue ?? "")
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try! encoder.encode(model)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        
        print("<-------------  RAW TRANSACTION  ------------->")
        print(jsonString)
        print("<-------------  RAW TRANSACTION END  ------------->")
        
        
//      Replace me
        var unpaidTx:Flow.Transaction = try await API.fetch(url: URL(string: "https://739c-118-113-135-6.ap.ngrok.io/api/auth/sign")!, method: .post, data: jsonData)
        let signedTx = try! unpaidTx.signEnvelope(signers: getSigners())
        
        
        let jsonData2 = try! encoder.encode(signedTx)
        let jsonString2 = String(data: jsonData2, encoding: .utf8)!
        
        print("<-------------  SIGNED TRANSACTION  ------------->")
        print(jsonString2)
        print("<-------------  SIGNED TRANSACTION END  ------------->")
        
        let txId = try! flow.sendTransaction(signedTransaction: signedTx).wait()
        XCTAssertNotNil(txId)
        print("txid --> \(txId.hex)")
    }
}

struct TestModel: Codable {
    let transaction: Flow.Transaction
    let message: String
}

final class API {
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }
    
    enum APIError: Error {
        case buildURL
        case requestFailed
    }
    
    @available(iOS 15.0, *)
    static func fetch<T: Decodable>(url: URL, method: HTTPMethod = .get, params: [String: String]? = [:], data: Data? = nil) async throws -> T {
        guard let fullURL = buildURL(url: url, params: params) else {
            throw APIError.buildURL
        }
        var request = URLRequest(url: fullURL)
        request.httpMethod = method.rawValue

        if let httpBody = data {
            request.httpBody = httpBody
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("*/*", forHTTPHeaderField: "Accept")
        }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let jsonString = String(data: data, encoding: .utf8)!
        print("<-------------  FETCH RESPONSE  ------------->")
        print(jsonString)
        print("<-------------  FETCH RESPONSE END ------------->")
        
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(T.self, from: data)
            return response
        } catch {
            print(error)
            throw error
        }
    }
    
    static func buildURL(url: URL, params: [String: String]?) -> URL? {
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }

        var queryItems: [URLQueryItem] = []

        for (name, value) in params ?? [:] {
            queryItems.append(
                URLQueryItem(name: name, value: value)
            )
        }

        urlComponents.queryItems = queryItems
        return urlComponents.url
    }
}
