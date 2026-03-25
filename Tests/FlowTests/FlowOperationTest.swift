	//
	//  FlowOperationTests.swift
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
	//
	//  Migrated to Swift Testing by Nicholas Reich on 2026-03-19.
	//

@testable import BigInt
import Combine
import CryptoKit
@testable import Flow
import Foundation
import Testing

	// To avoid unnecessary network calls, all examples remain disabled.
	// To enable, port them to the new Flow transaction-building APIs and
	// turn them into @Test methods.

@Suite
struct FlowOperationTests {
	var address = Flow.Address(hex: "0xe242ccfb4b8ea3e2")
	let publicKey = try! P256.KeyAgreement.PublicKey(
		rawRepresentation:
			"adbf18dae6671e6b6a92edf00c79166faba6babf6ec19bd83eabf690f386a9b13c8e48da67973b9cf369f56e92ec25ede5359539f687041d27d0143afd14bca9"
			.hexValue
	)
	let privateKey = try! P256.Signing.PrivateKey(
		rawRepresentation:
			"1eb79c40023143821983dc79b4e639789ea42452e904fda719f5677a1f144208"
			.hexValue
	)

	let privateKeyA = try! P256.Signing.PrivateKey(
		rawRepresentation:
			"c9c0f04adddf7674d265c395de300a65a777d3ec412bba5bfdfd12cffbbb78d9"
			.hexValue
	)

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

	init() async {
		await flow.configure(chainID: .testnet)
		signers.append(
			ECDSA_P256_Signer(address: address, keyIndex: 0, privateKey: privateKey)
		)
	}

		// MARK: - Example operations (disabled)

	/*
	 // Legacy examples using old Flow convenience APIs. These no longer exist on
	 // the Flow type and must be rewritten using the modern transaction builder.

	 func exampleAddContractToAccount() async throws {
	 let txID = try await flow.addContractToAccount(
	 address: address,
	 contractName: scriptName,
	 code: script,
	 signers: signers
	 )
	 print("addContractToAccount -> \(txID.hex)")
	 }

	 func exampleRemoveAccountKeyByIndex() async throws {
	 let txID = try await flow.removeAccountKeyByIndex(
	 address: address,
	 keyIndex: 4,
	 signers: signers
	 )
	 print("removeAccountKeyByIndex -> \(txID.hex)")
	 }

	 func exampleAddKeyToAccount() async throws {
	 let accountKey = Flow.AccountKey(
	 publicKey: Flow.PublicKey(hex: privateKeyA.publicKey.rawRepresentation.hexValue),
	 signAlgo: .ECDSA_P256,
	 hashAlgo: .SHA2_256,
	 weight: 1000
	 )

	 let txID = try await flow.addKeyToAccount(
	 address: address,
	 accountKey: accountKey,
	 signers: signers
	 )
	 print("addKeyToAccount -> \(txID.hex)")
	 }

	 func exampleUpdateContractOfAccount() async throws {
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

	 let txID = try await flow.updateContractOfAccount(
	 address: address,
	 contractName: scriptName,
	 script: script2,
	 signers: signers
	 )
	 print("updateContractOfAccount -> \(txID.hex)")
	 }

	 func exampleCreateAccount() async throws {
	 let accountKey = Flow.AccountKey(
	 publicKey: Flow.PublicKey(
	 hex: privateKeyA.publicKey.rawRepresentation.hexValue
	 ),
	 signAlgo: .ECDSA_P256,
	 hashAlgo: .SHA2_256,
	 weight: 1000
	 )

	 let txID = try await flow.createAccount(
	 address: address,
	 accountKey: accountKey,
	 contracts: [scriptName: script],
	 signers: signers
	 )

	 print("testCreateAccount -> \(txID.hex)")
	 let result = try await txID.onceSealed()
	 let event = result.events.first { $0.type == "flow.AccountCreated" }
	 let field = event?.payload.fields?.value
	 .toEvent()?
	 .fields
	 .first { $0.name == "address" }
	 let address = field?.value.value.toAddress()
	 print("created address -> \(address?.hex ?? "")")
	 }

	 func exampleRemoveContractFromAccount() async throws {
	 let txID = try await flow.removeContractFromAccount(
	 address: address,
	 contractName: scriptName,
	 signers: signers
	 )
	 print("removeContractFromAccount -> \(txID.hex)")
	 }

	 func exampleVerifyUserSignature() async throws {
	 flow.configure(chainID: .testnet)
	 let message = "464c4f57..."
	 let signature =
	 "0a467f133a971a8e022da54f988c033c05639cddd3bd8a525e566b53ee8e55a112cab1d3f1c628d7d290ec4c00782d8333ba0d8b17ec76408950968db0073aa5"
	 .hexValue
	 .data

	 let result = try await flow.verifyUserSignature(
	 message: message,
	 signatures: [
	 Flow.TransactionSignature(
	 address: Flow.Address(hex: "0xe242ccfb4b8ea3e2"),
	 keyIndex: 0,
	 signature: signature
	 ),
	 ]
	 )

	 print("verifyUserSignature -> \(result)")
	 }
	 */
}
