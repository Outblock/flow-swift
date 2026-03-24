//	//
//	//  AddressRegistorTests.swift
//	//  FlowTests
//	//
//	//  Created by Hao Fu on 1/4/2025.
//	//  Migrated from XCTest to Swift Testing by Nicholas Reich on 2026-03-19.
//	//
//
//import Flow
//import Testing
//
//@Suite
//struct AddressRegistorTests {
//	let addressA = Flow.Address(hex: "0x39416b4b085d94c7")
//	let addressB = Flow.Address(hex: "0x84221fe0294044d7")
//
//	@Test("Contract exists in address register")
//	func contract() {
//		let result = flow.addressRegister.contractExists("0xFlowToken", on: .mainnet)
//		let all = flow.addressRegister.getAddresses(for: .mainnet)
//		print(all)
//		#expect(result)
//	}
//
//	@Test("Import contract addresses into register")
//	func importContract() {
//		flow.addressRegister.importAddresses(for: .mainnet, from: ["0xABC": "0x123"])
//		let result = flow.addressRegister.contractExists("0xABC", on: .mainnet)
//		#expect(result)
//	}
//
//	@Test(
//		"EVM address resolution",
//		.timeLimit(.seconds(10))
//	)
//	func evmAddress() async throws {
//		let result = try await flow.getEVMAddress(address: addressA)
//		#expect(
//			result
//			== "0x000000000000000000000002993F5c597a37e150"
//				.lowercased()
//				.stripHexPrefix()
//		)
//	}
//
//	@Test(
//		"No child address for addressA",
//		.timeLimit(.seconds(10))
//	)
//	func noChildAddress() async throws {
//		let result = try await flow.getChildAddress(address: addressA)
//		#expect(result.count == 0)
//	}
//
//	@Test(
//		"Child addresses exist for addressB",
//		.timeLimit(.seconds(10))
//	)
//	func hasChildAddress() async throws {
//		let result = try await flow.getChildAddress(address: addressB)
//		print(result)
//		#expect(result.count > 0)
//	}
//
//	@Test(
//		"Child metadata exists for addressB",
//		.timeLimit(.seconds(10))
//	)
//	func childMetadata() async throws {
//		let result = try await flow.getChildMetadata(address: addressB)
//		#expect(result[result.keys.first!]?.name != nil)
//	}
//
//	@Test(
//		"No child metadata for addressA",
//		.timeLimit(.seconds(10))
//	)
//	func noChildMetadata() async throws {
//		let result = try await flow.getChildMetadata(address: addressA)
//		#expect(result.isEmpty)
//	}
//
//	@Test(
//		"Staking info is not empty",
//		.timeLimit(.seconds(10))
//	)
//	func stake() async throws {
//		let models = try await flow.getStakingInfo(address: addressB)
//		#expect(!models.isEmpty)
//	}
//
//	@Test(
//		"Token balance is not empty",
//		.timeLimit(.seconds(10))
//	)
//	func tokenBalance() async throws {
//		let models = try await flow.getTokenBalance(address: addressA)
//		#expect(!models.isEmpty)
//	}
//}
