	//
	//  CadenceTargetTests.swift
	//  FlowTests
	//
	//  Created by Hao Fu on 23/4/2025.
	//  Migrated from XCTest to Swift Testing by Nicholas Reich on 2026-03-19.
	//

import Foundation
import CryptoKit
import Flow
import Testing

enum TestCadenceTarget: CadenceTargetType {
	case getCOAAddr(address: Flow.Address)
	case logTx(test: String)

	var cadenceBase64: String {
		switch self {
			case .getCOAAddr:
				return """
			aW1wb3J0IEVWTSBmcm9tIDB4RVZNCgphY2Nlc3MoYWxsKSBmdW4gbWFpbihmbG93QWRkcmVzczogQWRkcmVzcyk6IFN0cmluZz8gewogICAgaWYgbGV0IGFkZHJlc3M6IEVWTS5FVk1BZGRyZXNzID0gZ2V0QXV0aEFjY291bnQ8YXV0aChCb3Jyb3dWYWx1ZSkgJkFjY291bnQ+KGZsb3dBZGRyZXNzKQogICAgICAgIC5zdG9yYWdlLmJvcnJvdzwmRVZNLkNhZGVuY2VPd25lZEFjY291bnQ+KGZyb206IC9zdG9yYWdlL2V2bSk/LmFkZHJlc3MoKSB7CiAgICAgICAgbGV0IGJ5dGVzOiBbVUludDhdID0gW10KICAgICAgICBmb3IgYnl0ZSBpbiBhZGRyZXNzLmJ5dGVzIHsKICAgICAgICAgICAgYnl0ZXMuYXBwZW5kKGJ5dGUpCiAgICAgICAgfQogICAgICAgIHJldHVybiBTdHJpbmcuZW5jb2RlSGV4KGJ5dGVzKQogICAgfQogICAgcmV0dXJuIG5pbAp9Cg==
			"""
			case .logTx:
				return """
			dHJhbnNhY3Rpb24odGVzdDogU3RyaW5nKSB7CiAgICBwcmVwYXJlKHNpZ25lcjE6ICZBY2NvdW50LCBzaWduZXIyOiAmQWNjb3VudCwgc2lnbmVyMzogJkFjY291bnQpIHsKICAgICAgICBsb2coc2lnbmVyMS5hZGRyZXNzKQogICAgICAgIGxvZyhzaWduZXIyLmFkZHJlc3MpCiAgICAgICAgbG9nKHNpZ25lcjMuYWRkcmVzcykKICAgICAgICBsb2codGVzdCkKICAgIH0KfQ==
			"""
		}
	}

	var type: CadenceType {
		switch self {
			case .getCOAAddr: return .query
			case .logTx:      return .transaction
		}
	}

	var arguments: [Flow.Argument] {
		switch self {
			case .getCOAAddr(let address):
				return [Flow.Argument(value: .address(address))]
			case .logTx(let test):
				return [Flow.Argument(value: .string(test))]
		}
	}

	var returnType: Decodable.Type {
		if type == .transaction { return Flow.ID.self }
		switch self {
			case .getCOAAddr: return String?.self
			default:          return Flow.ID.self
		}
	}
}

/// Minimal test fixtures for signing a tx on testnet.
private struct TestnetFixtures {
	let addressA: Flow.Address
	let addressB: Flow.Address
	let addressC: Flow.Address
	let signers: [ECDSA_P256_Signer]

	init() {
			// Replace these with real test addresses/keys if you need a live integration test.
		self.addressA = Flow.Address(hex: "0x0000000000000001")
		self.addressB = Flow.Address(hex: "0x0000000000000002")
		self.addressC = Flow.Address(hex: "0x0000000000000003")

			// Dummy private key just to satisfy the type; use a valid key for real network tests.
		let dummyKeyData = Data(repeating: 1, count: 32)
		let privateKey = try! P256.Signing.PrivateKey(rawRepresentation: dummyKeyData)

		let signer = ECDSA_P256_Signer(
			address: addressA,
			keyIndex: 0,
			privateKey: privateKey
		)
		self.signers = [signer]
	}
}

@Suite
struct CadenceTargetTests {

	init() async {
		await flow.configure(chainID: .testnet)
	}

	@Test("Cadence target query returns non-nil result")
	func query() async throws {
		let result: String? = try await flow.query(
			TestCadenceTarget.getCOAAddr(
				address: .init(hex: "0x84221fe0294044d7")
			),
			chainID: .mainnet
		)
		#expect(result != nil)
	}

	@Test("Cadence target transaction sends and returns ID")
	func transaction() async throws {
		let fixtures = TestnetFixtures()

		let id = try await flow.sendTransaction(
			TestCadenceTarget.logTx(test: "Hi!"),
			signers: fixtures.signers,
			chainID: .testnet
		)

		print(id.hex)
		#expect(id.hex.isEmpty == false)
	}
}
