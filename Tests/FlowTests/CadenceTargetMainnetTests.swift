	//
	//  CadenceTargetMainnetTests.swift
	//  Flow
	//
	//  Created by Nicholas Reich on 3/25/26.
	//
import Testing
import Flow

@Suite
struct CadenceTargetMainnetTests {
	init() async {
		await FlowActor.shared.flow.configure(chainID: .mainnet)
	}

	@Test(.timeLimit(.minutes(1)))
	func query() async throws {
		let result: String? = try await flow.query(
			TestCadenceTarget.getCOAAddr(address: .init(hex: "0x84221fe0294044d7")),
			chainID: .mainnet
		)
		#expect(result != nil)
	}
}

