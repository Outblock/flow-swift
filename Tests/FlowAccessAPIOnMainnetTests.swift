	//
	//  FlowAccessAPIOnMainnetTests.swift
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

import CryptoKit
@testable import Flow
import Foundation
import Testing

@Suite
struct FlowAccessAPIOnMainnetTests {
	var flowAPI: FlowAccessProtocol!
	var address = Flow.Address(hex: "0x2b06c41f44a05656")

	init() async {
		await flow.configure(chainID: .mainnet)
		flowAPI = flow.createHTTPAccessAPI(chainID: .mainnet)
	}

	@Test(
		"Flow mainnet ping succeeds",
		.timeLimit(.minutes(1))
	)
	func flowPing() async throws {
		let isConnected = try await flowAPI.ping()
		#expect(isConnected)
	}

	@Test(
		"Flow mainnet network parameters",
		.timeLimit(.minutes(1))
	)
	func networkParameters() async throws {
		let chainID = try await flowAPI.getNetworkParameters()
		#expect(chainID == Flow.ChainID.mainnet)
	}

	@Test(
		"Flow mainnet latest block header",
		.timeLimit(.minutes(1))
	)
	func blockHeader() async throws {
		let blockHeader = try await flowAPI.getLatestBlockHeader()
		#expect(blockHeader.id.bytes.isEmpty == false)
	}

	@Test(
		"Flow mainnet get account with fixed values",
		.timeLimit(.minutes(1))
	)
	func getAccount() async throws {
		let account = try await flowAPI.getAccountAtLatestBlock(
			address: .init(hex: "0x84221fe0294044d7")
		)
		#expect(account.keys.first != nil)
		#expect(account.keys.first?.sequenceNumber == 754)
		#expect(account.keys.first?.weight == 1000)
	}

	@Test(
		"Flow mainnet get account by stored address",
		.timeLimit(.minutes(1))
	)
	func getAccount2() async throws {
		let account = try await flowAPI.getAccountAtLatestBlock(address: address.hex)
		#expect(account.keys.first != nil)
		#expect(account.address == address)
	}

	@Test(
		"Flow mainnet get block header by ID",
		.timeLimit(.minutes(1))
	)
	func getBlockHeaderByID() async throws {
		let block = try await flowAPI.getLatestBlock(sealed: true)
		let blockHeader = try await flowAPI.getBlockById(id: block.id)
		#expect(blockHeader.height == block.height)
	}

	@Test(
		"Flow mainnet get block header by height",
		.timeLimit(.minutes(1))
	)
	func getBlockHeaderByHeight() async throws {
		let blockHeader = try await flowAPI.getBlockHeaderByHeight(height: 41_344_631)
		#expect(
			blockHeader.id.hex
			== "cf036cb6069caa7d61b867f0ad546033d024e031f20b08f7c6e0e74fb4a6a718"
		)
	}

	@Test(
		"Flow mainnet get account by block height",
		.timeLimit(.minutes(1))
	)
	func getAccountByHeight() async throws {
		let block = try await flowAPI.getLatestBlock(sealed: true)
		let account = try await flowAPI.getAccountByBlockHeight(
			address: address,
			height: block.height
		)

		#expect(account.keys.first != nil)
		#expect(account.address == address)
	}

	@Test(
		"Flow mainnet get latest block",
		.timeLimit(.minutes(1))
	)
	func getLatestBlock() async throws {
		let block = try await flowAPI.getLatestBlock(sealed: true)
		#expect(block.id.bytes.isEmpty == false)
	}

	@Test(
		"Flow mainnet query complex struct array",
		.timeLimit(.minutes(1))
	)
	func queryToken() async throws {
		let script = Flow.Script(
			text: """
			access(all) struct SomeStruct {
				access(all) var x: Int
				access(all) var y: Int
				init(x: Int, y: Int) {
					self.x = x
					self.y = y
				}
			}
			
			access(all) fun main(): [SomeStruct] {
				return [SomeStruct(x: 1, y: 2), SomeStruct(x: 3, y: 4)]
			}
			"""
		)

		let snapshot = try await flowAPI.executeScriptAtLatestBlock(script: script)
		#expect(snapshot.fields != nil)
		#expect(Flow.Cadence.FType.array == snapshot.fields?.type)

		struct SomeStruct: Codable {
			var x: Int
			var y: Int
		}

		guard let result: [SomeStruct] = try? snapshot.decode() else {
			Issue.record("Failed to decode SomeStruct array")
			return
		}

		print(result)

		guard case let .array(value: value) = snapshot.fields!.value else {
			Issue.record("Expected array Cadence value")
			return
		}
		guard case let .struct(value: firstStruct) = value.first! else {
			Issue.record("Expected struct Cadence value")
			return
		}

		#expect(firstStruct.fields.first?.name == "x")
		#expect(result.first?.x == 1)
		#expect(firstStruct.fields.last?.name == "y")
		#expect(result.first?.y == 2)
	}

	@Test(
		"Flow mainnet execute script with arguments",
		.timeLimit(.minutes(1))
	)
	func executeScriptAtLatestBlock2() async throws {
		let script = Flow.Script(
			text: """
			access(all) struct User {
				access(all) var balance: UFix64
				access(all) var address: Address
				access(all) var name: String
			
				init(name: String, address: Address, balance: UFix64) {
					self.name = name
					self.address = address
					self.balance = balance
				}
			}
			
			access(all) fun main(name: String): User {
				return User(
					name: name,
					address: 0x1,
					balance: 10.0
				)
			}
			"""
		)

		struct User: Codable {
			let balance: Double
			let address: String
			let name: String
		}

		let snapshot = try await flowAPI.executeScriptAtLatestBlock(
			script: script,
			arguments: [.string("Hello")]
		)

		let result: User = try snapshot.decode()
		print(result)

		#expect(result.name == "Hello")
		#expect(result.balance == 10.0)
		#expect(result.address == "0x0000000000000001")
	}

	@Test(
		"Flow mainnet verify signature script",
		.timeLimit(.minutes(1))
	)
	func verifySignature() async throws {
		let script = Flow.Script(
			text: """
			import Crypto
			
			access(all) fun main(
				publicKey: String,
				signature: String,
				message: String
			): Bool {
			
				let signatureBytes = signature.decodeHex()
				let messageBytes = message.utf8
			
				let pk = PublicKey(
					publicKey: publicKey.decodeHex(),
					signatureAlgorithm: SignatureAlgorithm.ECDSA_P256
				)
			
				return pk.verify(
					signature: signatureBytes,
					signedData: messageBytes,
					domainSeparationTag: "FLOW-V0.0-user",
					hashAlgorithm: HashAlgorithm.SHA2_256
				)
			}
			"""
		)

		let pubk =
		"5e2bff8d76a5cb2e59b621324c015b98b6131f5715fa8f4e66b6e75276056eb2d28ce8f1c113f562ed8d09bdd4edf6e30dd2ebdc4a4515f48be024e1749b58cc"
		let sig =
		"bd7fdac4282f2afca4b509fb809700b89b79472cbdf58ce8a4e3b0e16633cd854cf1165f632ee61eb23c830ba6b5f8f8f1b3e1f4880212c8bda4874568cbf717"
		let uid = "3h7BjWUYuqQMI8O96Lxwol4Lxl62"

		let snapshot = try await flowAPI.executeScriptAtLatestBlock(
			script: script,
			arguments: [
				.init(value: .string(pubk)),
				.init(value: .string(sig)),
				.init(value: .string(uid)),
			]
		)
		#expect(snapshot.fields?.value == .bool(true))
	}

	@Test(
		"Flow mainnet transaction result by ID",
		.timeLimit(.minutes(1))
	)
	func transactionResultById() async throws {
		let id = Flow.ID(
			hex: "6d6c20405f3dd2001361cd994493a56d31f4daa1c7ce420a2cd4259454b4a0da"
		)
		let result = try await flowAPI.getTransactionResultById(id: id)

		#expect(result.events.count == 3)
		#expect(result.events.first?.type == "A.c38aea683c0c4d38.Eternal.Withdraw")

		struct TestType: Codable {
			let id: UInt64
			let from: String
		}

		let test: TestType = try result.events.first!.payload.decode()

		#expect(result.events.first?.payload.fields?.type == .event)
		#expect(test.id == 11800)
		#expect(test.from.addHexPrefix() == "0x873becfb539f038d")
	}

	@Test(
		"Flow mainnet transaction by ID (basic smoke)",
		.timeLimit(.minutes(1))
	)
	func transactionById() async throws {
		let id = Flow.ID(
			hex: "40b18af87cbd776b934203583a89700a3f9e22c062510a04db386e9d18355b7c"
		)
		let transaction = try await flowAPI.getTransactionResultById(id: id)
		#expect(transaction.events.isEmpty == false)
	}
}
