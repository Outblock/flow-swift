	//
	//  RLPTests.swift
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

import BigInt
@testable import Flow
import Foundation
import Testing

@Suite
struct RLPTests {
	let baseTx = Flow.Transaction(
		script: Flow.Script(
			text: "transaction { execute { log(\"Hello, World!\") } }"
		),
		arguments: [],
		referenceBlockId: Flow.ID(
			hex: "f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b"
		),
		gasLimit: BigUInt(42),
		proposalKey: Flow.TransactionProposalKey(
			address: Flow.Address(hex: "01"),
			keyIndex: 4,
			sequenceNumber: 10
		),
		payer: Flow.Address(hex: "01"),
		authorizers: [Flow.Address(hex: "01")],
		payloadSignatures: [
			Flow.TransactionSignature(
				address: Flow.Address(hex: "01"),
				signerIndex: 4,
				keyIndex: 4,
				signature: Flow.Signature(
					hex:
						"f7225388c1d69d57e6251c9fda50cbbf9e05131e5adb81e5aa0422402f048162"
				)
				.data
			),
		],
		envelopeSignatures: []
	)

	@Test("RLP signable envelope with empty payload signatures")
	func emptyPayloadSigs() {
		let tx = baseTx.buildUpOn(payloadSignatures: [])
		guard let data = tx.signableEnvelope else {
			Issue.record("RLP encode error")
			return
		}

		#expect(
			data.hexValue
			== "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f875f872b07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b2a880000000000000001040a880000000000000001c9880000000000000001c0"
		)
	}

	@Test("RLP signable envelope with zero payload signature key index")
	func zeroPayloadSigsKey() {
		let tx = baseTx.buildUpOn(
			payloadSignatures: [
				baseTx.payloadSignatures.first!.buildUpon(keyIndex: 0),
			]
		)
		guard let data = tx.signableEnvelope else {
			Issue.record("RLP encode error")
			return
		}

		#expect(
			data.hexValue
			== "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f899f872b07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b2a880000000000000001040a880000000000000001c9880000000000000001e4e38080a0f7225388c1d69d57e6251c9fda50cbbf9e05131e5adb81e5aa0422402f048162"
		)
	}

	@Test("RLP signable envelope ordered by signer")
	func outOfOrderBySigner() {
		let tx = baseTx.buildUpOn(
			authorizers: [
				Flow.Address(hex: "01"),
				Flow.Address(hex: "02"),
				Flow.Address(hex: "03"),
			],
			payloadSignatures: [
				Flow.TransactionSignature(
					address: Flow.Address(hex: "03"),
					signerIndex: 0,
					keyIndex: 0,
					signature: "c".hexValue.data
				),
				Flow.TransactionSignature(
					address: Flow.Address(hex: "01"),
					signerIndex: 0,
					keyIndex: 0,
					signature: "a".hexValue.data
				),
				Flow.TransactionSignature(
					address: Flow.Address(hex: "02"),
					signerIndex: 0,
					keyIndex: 0,
					signature: "b".hexValue.data
				),
			]
		)

		guard let data = tx.signableEnvelope else {
			Issue.record("RLP encode error")
			return
		}

		#expect(
			data.hexValue
			== "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f893f884b07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b2a880000000000000001040a880000000000000001db880000000000000001880000000000000002880000000000000003ccc3808080c3018080c3028080"
		)
	}

	@Test("RLP signable envelope ordered by key index")
	func outOfOrderByKey() {
		let tx = baseTx.buildUpOn(
			authorizers: [Flow.Address(hex: "01")],
			payloadSignatures: [
				Flow.TransactionSignature(
					address: Flow.Address(hex: "01"),
					signerIndex: 2,
					keyIndex: 2,
					signature: "c".hexValue.data
				),
				Flow.TransactionSignature(
					address: Flow.Address(hex: "01"),
					signerIndex: 0,
					keyIndex: 0,
					signature: "a".hexValue.data
				),
				Flow.TransactionSignature(
					address: Flow.Address(hex: "01"),
					signerIndex: 1,
					keyIndex: 1,
					signature: "b".hexValue.data
				),
			]
		)

		guard let data = tx.signableEnvelope else {
			Issue.record("RLP encode error")
			return
		}

		#expect(
			data.hexValue
			== "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f881f872b07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b2a880000000000000001040a880000000000000001c9880000000000000001ccc3808080c3800180c3800280"
		)
	}

	@Test("RLP signable payload and envelope for complete transaction")
	func completeTx() {
		guard let signablePayload = baseTx.signablePlayload else {
			Issue.record("RLP encode error")
			return
		}

		#expect(
			signablePayload.hexValue
			== "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f872b07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b2a880000000000000001040a880000000000000001c9880000000000000001"
		)

		guard let encodedEnvelope = baseTx.signableEnvelope else {
			Issue.record("RLP encode error")
			return
		}

		#expect(
			encodedEnvelope.hexValue
			== "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f899f872b07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b2a880000000000000001040a880000000000000001c9880000000000000001e4e38004a0f7225388c1d69d57e6251c9fda50cbbf9e05131e5adb81e5aa0422402f048162"
		)
	}

	@Test("RLP encoding with empty Cadence script")
	func emptyCadence() {
		let tx = baseTx.buildUpOn(script: Flow.Script(text: ""))
		guard let signablePayload = tx.signablePlayload else {
			Issue.record("RLP encode error")
			return
		}

		#expect(
			signablePayload.hexValue
			== "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f84280c0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b2a880000000000000001040a880000000000000001c9880000000000000001"
		)

		guard let encodedEnvelope = tx.signableEnvelope else {
			Issue.record("RLP encode error")
			return
		}

		#expect(
			encodedEnvelope.hexValue
			== "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f869f84280c0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b2a880000000000000001040a880000000000000001c9880000000000000001e4e38004a0f7225388c1d69d57e6251c9fda50cbbf9e05131e5adb81e5aa0422402f048162"
		)
	}

	@Test("RLP encoding with nil reference block")
	func nilRefBlock() {
		let tx = baseTx.buildUpOn(referenceBlockId: Flow.ID(hex: ""))
		guard let signablePayload = tx.signablePlayload else {
			Issue.record("RLP encode error")
			return
		}

		#expect(
			signablePayload.hexValue
			== "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f872b07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a000000000000000000000000000000000000000000000000000000000000000002a880000000000000001040a880000000000000001c9880000000000000001"
		)

		guard let encodedEnvelope = tx.signableEnvelope else {
			Issue.record("RLP encode error")
			return
		}

		#expect(
			encodedEnvelope.hexValue
			== "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f899f872b07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a000000000000000000000000000000000000000000000000000000000000000002a880000000000000001040a880000000000000001c9880000000000000001e4e38004a0f7225388c1d69d57e6251c9fda50cbbf9e05131e5adb81e5aa0422402f048162"
		)
	}

	@Test("RLP encoding with zero compute limit")
	func zeroComputeLimit() {
		let tx = baseTx.buildUpOn(gasLimit: 0)
		guard let signablePayload = tx.signablePlayload else {
			Issue.record("RLP encode error")
			return
		}

		#expect(
			signablePayload.hexValue
			== "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f872b07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b80880000000000000001040a880000000000000001c9880000000000000001"
		)

		guard let encodedEnvelope = tx.signableEnvelope else {
			Issue.record("RLP encode error")
			return
		}

		#expect(
			encodedEnvelope.hexValue
			== "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f899f872b07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b80880000000000000001040a880000000000000001c9880000000000000001e4e38004a0f7225388c1d69d57e6251c9fda50cbbf9e05131e5adb81e5aa0422402f048162"
		)
	}

	@Test("RLP encoding with zero proposal key index")
	func zeroProposalKey() {
		let tx = baseTx.buildUpOn(
			proposalKey: Flow.TransactionProposalKey(
				address: Flow.Address(hex: "01"),
				keyIndex: 0,
				sequenceNumber: 10
			)
		)
		guard let signablePayload = tx.signablePlayload else {
			Issue.record("RLP encode error")
			return
		}

		#expect(
			signablePayload.hexValue
			== "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f872b07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b2a880000000000000001800a880000000000000001c9880000000000000001"
		)

		guard let encodedEnvelope = tx.signableEnvelope else {
			Issue.record("RLP encode error")
			return
		}

		#expect(
			encodedEnvelope.hexValue
			== "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f899f872b07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b2a880000000000000001800a880000000000000001c9880000000000000001e4e38004a0f7225388c1d69d57e6251c9fda50cbbf9e05131e5adb81e5aa0422402f048162"
		)
	}

	@Test("RLP encoding with zero sequence number")
	func zeroSequenceNumber() {
		let tx = baseTx.buildUpOn(
			proposalKey: Flow.TransactionProposalKey(
				address: Flow.Address(hex: "01"),
				keyIndex: 4,
				sequenceNumber: 0
			)
		)
		guard let signablePayload = tx.signablePlayload else {
			Issue.record("RLP encode error")
			return
		}

		#expect(
			signablePayload.hexValue
			== "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f872b07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b2a8800000000000000010480880000000000000001c9880000000000000001"
		)

		guard let encodedEnvelope = tx.signableEnvelope else {
			Issue.record("RLP encode error")
			return
		}

		#expect(
			encodedEnvelope.hexValue
			== "464c4f572d56302e302d7472616e73616374696f6e0000000000000000000000f899f872b07472616e73616374696f6e207b2065786563757465207b206c6f67282248656c6c6f2c20576f726c64212229207d207dc0a0f0e4c2f76c58916ec258f246851bea091d14d4247a2fc3e18694461b1816e13b2a8800000000000000010480880000000000000001c9880000000000000001e4e38004a0f7225388c1d69d57e6251c9fda50cbbf9e05131e5adb81e5aa0422402f048162"
		)
	}
}
