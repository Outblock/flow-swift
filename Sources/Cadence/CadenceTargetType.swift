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

	// MARK: - Generic execution extensions on Flow

extension Flow {

		/// Query with generic return type
	public func query<T: Decodable>(
		_ target: CadenceTargetType,
		chainID: Flow.ChainID = .mainnet
	) async throws -> T {
		guard let data = Data(base64Encoded: target.cadenceBase64) else {
			throw NSError(domain: "Invalid Cadence Base64 String", code: 9900001)
		}

		let script = Flow.Script(data: data)

			// Use the shared access client managed by your global actor.
		let api = await FlowActors.access.currentClient()

		let response = try await api.executeScriptAtLatestBlock(
			script: script,
			arguments: target.arguments
		)

		return try response.decode()
	}

		/// Transaction with generic argument building
	public func sendTransaction<T: CadenceTargetType>(
		_ target: T,
		signers: [FlowSigner],
		chainID: Flow.ChainID = .mainnet
	) async throws -> Flow.ID {
		guard let data = Data(base64Encoded: target.cadenceBase64) else {
			throw NSError(domain: "Invalid Cadence Base64 String", code: 9900001)
		}

		let script = Flow.Script(data:  data)

			// Empty result-builder body: no additional TransactionBuild steps.
		var tx = try await buildTransaction(
			chainID: chainID,
			skipEmptyCheck: true
		) {
				// nothing
		}

		tx.script = script
		tx.arguments = target.arguments

		let signedTx = try await signTransaction(
			unsignedTransaction: tx,
			signers: signers
		)

		return try await sendTransaction(transaction: signedTx)
	}
}
