//
//  CadenceTargetTestnetTests.swift
//  Flow
//
//  Created by Nicholas Reich on 3/25/26.
//
import Testing
import Flow

@Suite
struct CadenceTargetTestnetTests {
  init() async {
    await FlowActor.shared.flow.configure(chainID: .testnet)
  }

  @Test(.timeLimit(.minutes(1)))
  func transaction() async throws {
    let fixtures = TestnetFixtures()
    let id = try await flow.sendTransaction(
      TestCadenceTarget.logTx(test: "Hi!"),
      signers: fixtures.signers,
      chainID: .testnet
    )
    #expect(id.hex.isEmpty == false)
  }
}
