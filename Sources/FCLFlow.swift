	//
	//  FCLFlow.swift
	//  flow-swift-macos
	//

import Foundation

@FlowActor
public enum FCLFlow {

	public static func buildTransaction(
		chainID: Flow.ChainID? = nil,
		skipEmptyCheck: Bool = false,
		@Flow.TransactionBuild.TransactionBuilder builder: () -> [Flow.TransactionBuild]
	) async throws -> Flow.Transaction {
		let resolvedChainID: Flow.ChainID
		if let chainID {
			resolvedChainID = chainID
		} else {
			resolvedChainID = await Flow.shared.chainID
		}

		return try await Flow.shared.buildTransaction(
			chainID: resolvedChainID,
			skipEmptyCheck: skipEmptyCheck,
			builder: builder
		)
	}

	public static func send(
		chainID: Flow.ChainID? = nil,
		signers: [FlowSigner],
		@Flow.TransactionBuild.TransactionBuilder builder: () -> [Flow.TransactionBuild]
	) async throws -> Flow.ID {
		let resolvedChainID: Flow.ChainID
		if let chainID {
			resolvedChainID = chainID
		} else {
			resolvedChainID = await Flow.shared.chainID
		}

		return try await Flow.shared.sendTransaction(
			chainID: resolvedChainID,
			signers: signers,
			builder: builder
		)
	}
}
