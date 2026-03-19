//
//  File.swift
//  Flow
//
//  Created by Hao Fu on 23/4/2025.
//updated Swift 6 Concurrency Nic Reich 3/19/26

import Foundation


public enum CadenceType: String {
	case query
	case transaction
}

public protocol CadenceTargetType {
		/// Base64-encoded Cadence script
	var cadenceBase64: String { get }

		/// Script type (query or transaction)
	var type: CadenceType { get }

		/// Return type for decoding
	var returnType: Decodable.Type { get }

		/// Script arguments
	var arguments: [Flow.Argument] { get }
}

	// Generic execution extensions on Flow
extension Flow {
		// Query with generic return type
	public func query<T: Decodable>(
		_ target: CadenceTargetType,
		chainID: Flow.ChainID = .mainnet
	) async throws -> T {
		guard let data = Data(base64Encoded: target.cadenceBase64) else {
			throw NSError(domain: "Invalid Cadence Base64 String", code: 9900001)
		}

		let script = Flow.Script(data: data)
		let api = Flow.FlowHTTPAPI(chainID: chainID)
		return try await api.executeScriptAtLatestBlock(
			script: script,
			arguments: target.arguments
		).decode()
	}

		// Transaction with generic argument building
	public func sendTransaction<T: CadenceTargetType>(
		_ target: T,
		signers: [FlowSigner],
		chainID: Flow.ChainID = .mainnet
	) async throws -> Flow.ID {
		guard let data = Data(base64Encoded: target.cadenceBase64) else {
			throw NSError(domain: "Invalid Cadence Base64 String", code: 9900001)
		}

		var tx = try await buildTransaction(
			chainID: chainID,
			skipEmptyCheck: true
		)
		tx.script = .init(data: data)
		tx.arguments = target.arguments

		let signedTx = try await signTransaction(
			unsignedTransaction: tx,
			signers: signers
		)
		return try await sendTransaction(transaction: signedTx)
	}
}
