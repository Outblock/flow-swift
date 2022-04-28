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
    
    @available(iOS 15.0, *)
    func testMultiplePartySign() async throws {
        // Example in Testnet

        // Admin key
        let signers = [
            // Address A
//            ECDSA_P256_Signer(address: addressA, keyIndex: 5, privateKey: privateKeyB), // weight: 500
            ECDSA_P256_Signer(address: addressA, keyIndex: 0, privateKey: privateKeyA), // weight: 1000
            // Address B
            ECDSA_P256_Signer(address: addressB, keyIndex: 2, privateKey: privateKeyA), // weight: 800
            ECDSA_P256_Signer(address: addressB, keyIndex: 1, privateKey: privateKeyC), // weight: 500
            // Address C
//            ECDSA_P256_Signer(address: addressC, keyIndex: 3, privateKey: privateKeyB), // weight: 300
//            ECDSA_P256_Signer(address: addressC, keyIndex: 2, privateKey: privateKeyB), // weight: 500
            ECDSA_P256_Signer(address: addressC, keyIndex: 0, privateKey: privateKeyC), // weight: 1000
        ]

        var unsignedTx = try! flow.buildTransaction {
            cadence {
                """
                import HelloWorld from 0xe242ccfb4b8ea3e2

                   transaction(test: String, testInt: HelloWorld.SomeStruct) {
                       prepare(signer1: AuthAccount, signer2: AuthAccount, signer3: AuthAccount) {
                            log(signer1.address)
                            log(signer2.address)
                            log(signer3.address)
                            log(test)
                            log(testInt)
                       }
                   }
                """
            }

            proposer {
                Flow.TransactionProposalKey(address: addressC, keyIndex: 0)
            }

            authorizers {
                [self.addressC, self.addressA, .init(hex: "0xe5be88e3e38c0e1d")]
            }
            
            payer {
                self.addressA
            }

            arguments {
                [.string("Test"), .struct(.init(id: "A.e242ccfb4b8ea3e2.HelloWorld.SomeStruct",
                                                fields: [.init(name: "x", value: .init(value: .int(1))),
                                                         .init(name: "y", value: .init(value: .int(2)))]))]
            }

            // optional
            gasLimit {
                1000
            }
        }

        let notFinishedSignedTx = try! unsignedTx.signPayload(signers: signers)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try! encoder.encode(notFinishedSignedTx)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        
        print("<-------------  RAW TRANSACTION  ------------->")
        print(jsonString)
        print("<-------------  RAW TRANSACTION END  ------------->")
        
        
//      Replace me
        var unpaidTx:Flow.Transaction = try await API.fetch(url: URL(string: "https://flowns")!, method: .post, data: jsonData)
        let signedTx = try! unpaidTx.signEnvelope(signers: signers)
        
        let txId = try! flow.sendTransaction(signedTransaction: signedTx).wait()
        XCTAssertNotNil(txId)
        print("txid --> \(txId.hex)")
    }
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
        let response = try decoder.decode(T.self, from: data)
        return response
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
