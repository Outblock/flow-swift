	//
	//  FlowAccessAPIOnTestnetTests.swift
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
	//  Migrated from XCTest to Swift Testing by Nicholas Reich on 2026-03-19.
	//

@testable import BigInt
import CryptoKit
@testable import Flow
import Foundation
import Testing

@Suite
final class FlowAccessAPIOnTestnetTests {
	var flowAPI: FlowAccessProtocol!

	let addressA = Flow.Address(hex: "0xc6de0d94160377cd")
	let publicKeyA = try! P256.KeyAgreement.PublicKey(
		rawRepresentation:
			"d487802b66e5c0498ead1c3f576b718949a3500218e97a6a4a62bf69a8b0019789639bc7acaca63f5889c1e7251c19066abb09fcd6b273e394a8ac4ee1a3372f"
			.hexValue
	)
	let privateKeyA = try! P256.Signing.PrivateKey(
		rawRepresentation:
			"c9c0f04adddf7674d265c395de300a65a777d3ec412bba5bfdfd12cffbbb78d9"
			.hexValue
	)

	let addressB = Flow.Address(hex: "0x10711015c370a95c")
	let publicKeyB = try! P256.KeyAgreement.PublicKey(
		rawRepresentation:
			"6278ff9fdf75c5830e4aafbb8cc25af50b62869d7bc9b249e76aae31490199732b769d1df627d36e5e336aeb4cb06b0fad80ae13a25aca37ec0017e5d8f1d8a5"
			.hexValue
	)
	let privateKeyB = try! P256.Signing.PrivateKey(
		rawRepresentation:
			"38ebd09b83e221e406b176044a65350333b3a5280ed3f67227bd80d55ac91a0f"
			.hexValue
	)

	let addressC = Flow.Address(hex: "0xe242ccfb4b8ea3e2")
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

		/// All test signers as a list of FlowSigner values.
	public var signers: [any FlowSigner] {
		[
			// Address A
			ECDSA_P256_Signer(address: addressA, keyIndex: 5, privateKey: privateKeyB),
			ECDSA_P256_Signer(address: addressA, keyIndex: 0, privateKey: privateKeyA),

			// Address B
			ECDSA_P256_Signer(address: addressB, keyIndex: 2, privateKey: privateKeyA),
			ECDSA_P256_Signer(address: addressB, keyIndex: 1, privateKey: privateKeyC),

			// Address C
			ECDSA_P256_Signer(address: addressC, keyIndex: 3, privateKey: privateKeyB),
			ECDSA_P256_Signer(address: addressC, keyIndex: 2, privateKey: privateKeyB),
			ECDSA_P256_Signer(address: addressC, keyIndex: 0, privateKey: privateKeyC),
		]
	}

	init() async {
		flowAPI = await FlowActor.shared.flow
			.createHTTPAccessAPI(chainID: .testnet)
		await FlowActor.shared.flow.configure(chainID: .testnet)
	}

	@Test("Flow testnet ping succeeds", .timeLimit(.minutes(1)))
	func flowPing() async throws {
		let isConnected = try await flowAPI.ping()
		#expect(isConnected)
	}

	@Test("Flow testnet fee parameters script executes", .timeLimit(.minutes(1)))
	func flowFee() async throws {
		let result = try await FlowActor.shared.flow.accessAPI.executeScriptAtLatestBlock(
			script: .init(
				text: """
 import FlowFees from 0x912d5440f7e3769e
 
 access(all) fun main(): FlowFees.FeeParameters {
  return FlowFees.getFeeParameters()
 }
 """
			)
		)

		#expect(result.fields != nil)
	}

	@Test("Flow testnet network parameters", .timeLimit(.minutes(1)))
	func networkParameters() async throws {
		let chainID = try await flowAPI.getNetworkParameters()
		#expect(chainID == Flow.ChainID.testnet)

		let txId = Flow.ID(
			hex: "8f7f939020ca904b4d2067089e063b2f46dd1234d5e43f88bda0e4200142f21a"
		)

			// Just ensure we can fetch a result for this transaction without error.
		_ = try await FlowActor.shared.flow.accessAPI.getTransactionResultById(id: txId)
	}

	@Test("Flow testnet can create account via script", .timeLimit(.minutes(1)))
	func canCreateAccount() async throws {
		await FlowActor.shared.flow.configure(chainID: .testnet)

		let signerGroup: [any FlowSigner] = [
			ECDSA_P256_Signer(address: addressA, keyIndex: 0, privateKey: privateKeyA),
		]

		let accountKey = Flow.AccountKey(
			publicKey: Flow.PublicKey(
				hex:
					"bfa6d9893d4d9b5e53b0b9d79ac44b4e20f57b6443f02e5f12b366ed4e1fb4e7decca4e58b76308cee1a22a4c0c01f6fce698dc62c80120f65e8cdf57a0ffdff"
			),
			signAlgo: .ECDSA_P256,
			hashAlgo: .SHA2_256,
			weight: 1001
		)

		let proposerAddress = addressA
		let pkHex = accountKey.publicKey.hex
		let signAlgoIndex = UInt8(accountKey.signAlgo.index)
		let hashAlgoCode = UInt8(accountKey.hashAlgo.code)

			// Build, sign, and send via the FlowActor-managed helpers.
		let unsignedTx = try await FlowActor.shared.flow.buildTransaction(chainID: .testnet) {
			cadence {
 """
 import Crypto
 
 transaction(publicKey: String, signatureAlgorithm: UInt8, hashAlgorithm: UInt8, weight: UFix64) {
  prepare(signer: auth(BorrowValue | Storage) &Account) {
   let key = PublicKey(
 publicKey: publicKey.decodeHex(),
 signatureAlgorithm: SignatureAlgorithm(rawValue: signatureAlgorithm)!
   )
 
   let account = Account(payer: signer)
   account.keys.add(
 publicKey: key,
 hashAlgorithm: HashAlgorithm(rawValue: hashAlgorithm)!,
 weight: weight
   )
  }
 }
 """
			}
			proposer {
				Flow.TransactionProposalKey(address: proposerAddress, keyIndex: 0)
			}
			authorizers {
				proposerAddress
			}
			arguments {
				[
					Flow.Argument(value: .string(pkHex)),
					Flow.Argument(value: .uint8(signAlgoIndex)),
					Flow.Argument(value: .uint8(hashAlgoCode)),
					Flow.Argument(value: .ufix64(Decimal(1000))),
				]
			}
			gasLimit { 1000 }
		}

		let signedTx = try await FlowActor.shared.flow.signTransaction(
			unsignedTransaction: unsignedTx,
			signers: signerGroup
		)

		let txId = try await FlowActor.shared.flow.sendTransaction(
			signedTransaction: signedTx
		)
		#expect(txId.hex.isEmpty == false)

		let txResult = try await FlowActor.shared.flow.once(
			txId,
			status: .sealed
		)
		let createdAddress = txResult.getCreatedAddress()!
		#expect(!createdAddress.isEmpty)

		let accountInfo = try await FlowActor.shared.flow.getAccountAtLatestBlock(
			address: Flow.Address(hex: createdAddress)
		)
		#expect(accountInfo.keys.isEmpty == false)
	}

	@Test("Flow testnet multiple signer transaction", .timeLimit(.minutes(1)))
	func multipleSigner() async throws {
		let addrA = addressA
		let addrB = addressB
		let addrC = addressC

		let txID = try await FlowActor.shared.flow.sendTransaction(
			chainID: .testnet,
			signers: signers
		) {
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
			arguments {
				[
					Flow.Argument(value: .string("Test")),
					Flow.Argument(
						value: .struct(
							.init(
								id: "A.e242ccfb4b8ea3e2.HelloWorld.SomeStruct",
								fields: [
									.init(name: "x", value: .init(value: .int(1))),
									.init(name: "y", value: .init(value: .int(2))),
								]
							)
						)
					),
				]
			}
			proposer { Flow.TransactionProposalKey(address: addrA, keyIndex: 5) }
			payer { addrB }
			authorizers { [addrC, addrB, addrA] }
		}

		let result = try await FlowActor.shared.flow.once(
			txID,
			status: .sealed
		)
		#expect(result.status == Flow.Transaction.Status.sealed)
	}
}
