	//
	//  FlowAddressTests.swift
	//  FlowTests
	//
	//  Created by Hao Fu on 27/9/2022.
	//  Migrated to Swift Testing by Nicholas Reich on 2026-03-19.
	//

import BigInt
import CryptoKit
@testable import Flow
import Foundation
import Testing

@Suite
struct FlowAddressTests {
	@Test("Mainnet address from hex with 0x prefix")
	func addressHexType() async throws {
		let hex = "0xc7efa8c33fceee03"
		let address = Flow.Address(hex: hex)
		#expect(address.hex == hex)
		#expect(address.bytes.count == 8)
		#expect(address.description == hex)

		let isValid = await flow.isAddressVaildate(address: address, network: .mainnet)
		#expect(isValid == true)
	}

	@Test("Testnet address from hex with 0x prefix")
	func addressHexTypeTestnet() async throws {
		let hex = "0xc6de0d94160377cd"
		let address = Flow.Address(hex: hex)

		let isValid = await flow.isAddressVaildate(address: address, network: .testnet)
		#expect(isValid == true)
	}

	@Test("Address from hex without 0x prefix")
	func addressType() async throws {
		let hex = "c7efa8c33fceee03"
		let address = Flow.Address(hex: hex)
		#expect(address.hex == hex.addHexPrefix())
		#expect(address.bytes.count == 8)
		#expect(address.description == hex.addHexPrefix())

		let isValid = await flow.isAddressVaildate(address: address)
		#expect(isValid == true)
	}

	@Test("Invalid short address is normalized but not valid on-chain")
	func invalidAddressType() async throws {
		let hex = "0x03"
		let address = Flow.Address(hex: hex)
		#expect(address.hex != hex)
		#expect(address.bytes.count == 8)
		#expect(address.description != hex)

		let isValid = await flow.isAddressVaildate(address: address)
		#expect(isValid == false)
	}

	@Test("Invalid long address is truncated and not valid on-chain")
	func invalidLongAddressType() async throws {
		let hex = "0x56519083C3cfeAE833B93a93c843C993bE1D74EA"
		let address = Flow.Address(hex: hex)
		#expect(address.hex == "0x56519083C3cfeAE8".lowercased())
		#expect(address.hex != hex)
		#expect(address.bytes.count == 8)
		#expect(address.description != hex)

		let isValid = await flow.isAddressVaildate(address: address)
		#expect(isValid == false)
	}
}
