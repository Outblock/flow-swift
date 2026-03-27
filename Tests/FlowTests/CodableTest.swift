	//
	//  CodableTests.swift
	//  FlowTests
	//
	//  Copyright 2022 Outblock Pty Ltd
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
	//  Migrated from XCTest to Swift Testing by Nicholas Reich on 2026-03-19.
	//

@testable import BigInt
import CryptoKit
@testable import Flow
import Testing
import Foundation

@Suite
struct CodableTests {
	var flowAPI: FlowAccessProtocol!

	var addressC = Flow.Address(hex: "0xe242ccfb4b8ea3e2")
	let publicKeyC = try! P256.KeyAgreement.PublicKey(
		rawRepresentation:
			"adbf18dae6671e6b6a92edf00c79166faba6babf6ec19bd83eabf690f386a9b13c8e48da67973b9cf369f56e92ec25ede5359539f687041d27d0143afd14bca9"
			.hexValue
	)
	let privateKeyC = try! P256.Signing.PrivateKey(
		rawRepresentation:
			"1eb79c40023143821983dc79b4e639789ea42452e904fda719f5677a1f144208"
			.hexValue
	)

		// Async init so we can safely await the actor-isolated Flow singleton.
	init() async {
		flowAPI = await FlowActor.shared.flow.createHTTPAccessAPI(chainID: .testnet)
		await FlowActor.shared.flow.configure(chainID: .testnet)
	}

	@Test(
		"Transaction encoding to JSON works",
		.timeLimit(.minutes(1))
	)
	func encodeTx() async throws {
			// Admin key
		let address = addressC
		let signers: [any FlowSigner] = [
			ECDSA_P256_Signer(address: address, keyIndex: 0, privateKey: privateKeyC),
		]

			// User public key
		let accountKey = Flow.AccountKey(
			publicKey: Flow.PublicKey(
				hex: privateKeyC.publicKey.rawRepresentation.hexValue
			),
			signAlgo: .ECDSA_P256,
			hashAlgo: .SHA2_256,
			weight: 1000
		)

			// Configure Flow via the actor-isolated singleton (idempotent)
		await FlowActor.shared.flow.configure(chainID: .testnet)

			// Build transaction using the FlowActor-isolated builder
		let unsignedTx = try await FlowActor.shared.flow.buildTransaction(
			chainID: .testnet
		) {
			cadence {
	"""
	transaction(publicKey: String) {
	 prepare(signer: AuthAccount) {
	  let account = AuthAccount(payer: signer)
	  account.keys.add(publicKey.decodeHex())
	 }
	}
	"""
			}
			proposer {
				Flow.TransactionProposalKey(address: addressC, keyIndex: 0)
			}
			authorizers {
				address
			}
			arguments {
				[
					Flow.Argument(
						value: .string(accountKey.encoded!.hexValue)
					),
				]
			}
			gasLimit {
				1000
			}
		}

			// Sign via FlowActor helper
		let signedTx = try await FlowActor.shared.flow.signTransaction(
			unsignedTransaction: unsignedTx,
			signers: signers
		)

			// Encode to JSON and pretty-print
		let encoder = JSONEncoder()
		encoder.keyEncodingStrategy = .convertToSnakeCase
		let jsonData = try encoder.encode(signedTx)
		let object = try JSONSerialization.jsonObject(with: jsonData)
		let data = try JSONSerialization.data(
			withJSONObject: object,
			options: [.prettyPrinted]
		)
		let jsonString = String(data: data, encoding: .utf8)

		#expect(jsonString?.isEmpty == false)
	}
}
