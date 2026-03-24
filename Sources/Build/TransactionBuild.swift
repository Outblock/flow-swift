	//
	//  TransactionBuild.swift
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
	//  Edited for Swift 6 concurrency & actors by Nicholas Reich on 2026-03-19.
	//

import BigInt
import Foundation

	// MARK: - Top-level builder helpers (DSL)

public func cadence(text: () -> String) -> Flow.TransactionBuild {
	Flow.TransactionBuild.script(Flow.Script(text: text()))
}

public func cadence(text: () -> Flow.Script) -> Flow.TransactionBuild {
	Flow.TransactionBuild.script(text())
}

public func arguments(text: () -> [Flow.Cadence.FValue]) -> Flow.TransactionBuild {
	Flow.TransactionBuild.argument(text().compactMap { Flow.Argument(value: $0) })
}

public func arguments(text: () -> [Flow.Argument]) -> Flow.TransactionBuild {
	Flow.TransactionBuild.argument(text())
}

public func payer(text: () -> String) -> Flow.TransactionBuild {
	Flow.TransactionBuild.payer(Flow.Address(hex: text()))
}

public func payer(text: () -> Flow.Address) -> Flow.TransactionBuild {
	Flow.TransactionBuild.payer(text())
}

public func authorizers(text: () -> [Flow.Address]) -> Flow.TransactionBuild {
	Flow.TransactionBuild.authorizers(text())
}

public func authorizers(text: () -> Flow.Address) -> Flow.TransactionBuild {
	Flow.TransactionBuild.authorizers([text()])
}

public func proposer(text: () -> String) -> Flow.TransactionBuild {
	let address = Flow.Address(hex: text())
	return Flow.TransactionBuild.proposer(Flow.TransactionProposalKey(address: address))
}

public func proposer(text: () -> Flow.Address) -> Flow.TransactionBuild {
	Flow.TransactionBuild.proposer(Flow.TransactionProposalKey(address: text()))
}

public func proposer(text: () -> Flow.TransactionProposalKey) -> Flow.TransactionBuild {
	Flow.TransactionBuild.proposer(text())
}

public func gasLimit(text: () -> BigUInt) -> Flow.TransactionBuild {
	Flow.TransactionBuild.gasLimit(text())
}

public func gasLimit(text: () -> Int) -> Flow.TransactionBuild {
	Flow.TransactionBuild.gasLimit(BigUInt(text()))
}

public func refBlock(text: () -> String?) -> Flow.TransactionBuild {
	guard let blockId = text() else {
		return Flow.TransactionBuild.refBlock(nil)
	}
	return Flow.TransactionBuild.refBlock(Flow.ID(hex: blockId))
}

public func refBlock(text: () -> Flow.ID) -> Flow.TransactionBuild {
	Flow.TransactionBuild.refBlock(text())
}

	// MARK: - TransactionBuild DSL

public extension Flow {

	enum TransactionBuild {
		case script(Flow.Script)
		case argument([Flow.Argument])
		case payer(Flow.Address)
		case authorizers([Flow.Address])
		case proposer(Flow.TransactionProposalKey)
		case gasLimit(BigUInt)
		case refBlock(Flow.ID?)
		case error

		@resultBuilder
		enum TransactionBuilder {
			public static func buildBlock() -> [Flow.TransactionBuild] { [] }

			public static func buildArray(
				_ components: [[Flow.TransactionBuild]]
			) -> [Flow.TransactionBuild] {
				components.flatMap { $0 }
			}

			public static func buildBlock(
				_ components: Flow.TransactionBuild...
			) -> [Flow.TransactionBuild] {
				components
			}
		}
	}
}

	// MARK: - Build & send helpers

@FlowActor
public extension Flow {

		/// Core builder with explicit chainID (no default using self/await).
	func buildTransaction(
		chainID: Flow.ChainID,
		skipEmptyCheck: Bool = false,
		@Flow.TransactionBuild.TransactionBuilder builder: () -> [Flow.TransactionBuild]
	) async throws -> Flow.Transaction {

		await FlowLogger.shared.logAsync(
			.debug,
			message: "Starting transaction build for chain: \(chainID)"
		)

			// Start with an empty script.
		var script = Flow.Script(data: Data())
		var args: [Flow.Argument] = []
		var auths: [Flow.Address] = []
		var payer: Flow.Address?
		var proposer: Flow.TransactionProposalKey?
		var gasLimit = BigUInt(9999)
		var refBlock: Flow.ID?

		let components = builder()

		for txValue in components {
			switch txValue {
				case let .script(value):
						// Resolve imports for the current chain.
					let updated = self.addressRegister.resolveImports(in: value.text, for: chainID)
					script = Flow.Script(text: updated)

					if let scriptString = String(data: value.data, encoding: .utf8) {
						await FlowLogger.shared.logAsync(
							.debug,
							message: "Adding script: \(scriptString)"
						)
					}

				case let .argument(value):
					args = value
					let argDescriptions = value
						.map { $0.jsonString ?? "<invalid>" }
						.joined(separator: ", ")
					await FlowLogger.shared.logAsync(
						.debug,
						message: "Adding arguments: [\(argDescriptions)]"
					)

				case let .authorizers(value):
					auths = value
					let authHex = value.map { $0.hex }.joined(separator: ", ")
					await FlowLogger.shared.logAsync(
						.debug,
						message: "Adding authorizers: [\(authHex)]"
					)

				case let .payer(value):
					payer = value
					await FlowLogger.shared.logAsync(
						.debug,
						message: "Setting payer: \(value.hex)"
					)

				case let .proposer(value):
					proposer = value
					await FlowLogger.shared.logAsync(
						.debug,
						message: "Setting proposer: address=\(value.address.hex), keyIndex=\(value.keyIndex)"
					)

				case let .gasLimit(value):
					gasLimit = value
					await FlowLogger.shared.logAsync(
						.debug,
						message: "Setting gas limit: \(value)"
					)

				case let .refBlock(value):
					refBlock = value
					await FlowLogger.shared.logAsync(
						.debug,
						message: "Setting reference block: \(value?.hex ?? "latest")"
					)

				case .error:
					await FlowLogger.shared.logAsync(
						.warning,
						message: "Encountered error case in transaction build"
					)
			}
		}

		guard var proposalKey = proposer else {
			await FlowLogger.shared.logAsync(
				.error,
				message: "Transaction build failed: Empty proposer"
			)
			throw Flow.FError.emptyProposer
		}

		let api = await FlowActors.access.currentClient()

		await FlowLogger.shared.logAsync(.debug, message: "Resolving reference block ID")
		let id = try await resolveBlockId(api: api, refBlock: refBlock)
		await FlowLogger.shared.logAsync(.debug, message: "Resolved block ID: \(id.hex)")

		await FlowLogger.shared.logAsync(
			.debug,
			message: "Resolving proposal key: address=\(proposalKey.address.hex), keyIndex=\(proposalKey.keyIndex)"
		)
		let key = try await resolveProposalKey(api: api, proposalKey: proposalKey)
		await FlowLogger.shared.logAsync(
			.debug,
			message: "Resolved proposal key with sequence number: \(key.sequenceNumber)"
		)
		proposalKey = key

		if !skipEmptyCheck {
			guard !script.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
				await FlowLogger.shared.logAsync(
					.error,
					message: "Transaction build failed: Invalid script format"
				)
				throw Flow.FError.invalidScript
			}
		}

		let transaction = Flow.Transaction(
			script: script,
			arguments: args,
			referenceBlockId: id,
			gasLimit: gasLimit,
			proposalKey: proposalKey,
			payer: payer ?? proposalKey.address,
			authorizers: auths
		)

		await FlowLogger.shared.logAsync(
			.info,
			message: """
   Transaction built successfully:
   - Script size: \(script.data.count) bytes
   - Arguments count: \(args.count)
   - Reference block: \(id.hex)
   - Gas limit: \(gasLimit)
   - Proposer: \(proposalKey.address.hex)
   - Payer: \((payer ?? proposalKey.address).hex)
   - Authorizers count: \(auths.count)
   """
		)

		return transaction
	}

		/// Convenience overload: uses current Flow.chainID.
	func buildTransaction(
		skipEmptyCheck: Bool = false,
		@Flow.TransactionBuild.TransactionBuilder builder: () -> [Flow.TransactionBuild]
	) async throws -> Flow.Transaction {
		let currentChainID = await self.chainID
		return try await buildTransaction(
			chainID: currentChainID,
			skipEmptyCheck: skipEmptyCheck,
			builder: builder
		)
	}

	func buildTransaction(
		chainID: Flow.ChainID,
		script: String,
		agrument: [Flow.Argument] = [],
		authorizer: [Flow.Address] = [],
		payerAddress: Flow.Address,
		proposerKey: Flow.TransactionProposalKey,
		limit: BigUInt = BigUInt(9999),
		blockID: Flow.ID? = nil
	) async throws -> Flow.Transaction {
		let updatedScript = self.addressRegister.resolveImports(in: script, for: chainID)
		return try await buildTransaction(chainID: chainID) {
			cadence { updatedScript }
			arguments { agrument }
			proposer { proposerKey }
			gasLimit { limit }
			authorizers { authorizer }
			payer { payerAddress }
			refBlock { blockID?.hex }
		}
	}

	func buildTransaction(
		script: String,
		agrument: [Flow.Argument] = [],
		authorizer: [Flow.Address] = [],
		payerAddress: Flow.Address,
		proposerKey: Flow.TransactionProposalKey,
		limit: BigUInt = BigUInt(9999),
		blockID: Flow.ID? = nil
	) async throws -> Flow.Transaction {
		let currentChainID = await self.chainID
		return try await buildTransaction(
			chainID: currentChainID,
			script: script,
			agrument: agrument,
			authorizer: authorizer,
			payerAddress: payerAddress,
			proposerKey: proposerKey,
			limit: limit,
			blockID: blockID
		)
	}

	func sendTransaction(
		chainID: Flow.ChainID,
		signedTransaction: Flow.Transaction
	) async throws -> Flow.ID {
		let api = await FlowActors.access.currentClient()
		return try await api.sendTransaction(transaction: signedTransaction)
	}

	func sendTransaction(
		signedTransaction: Flow.Transaction
	) async throws -> Flow.ID {
		try await sendTransaction(chainID: self.chainID, signedTransaction: signedTransaction)
	}

	func sendTransaction(
		chainID: Flow.ChainID,
		signers: [FlowSigner],
		@Flow.TransactionBuild.TransactionBuilder builder: () -> [Flow.TransactionBuild]
	) async throws -> Flow.ID {
		let api = await FlowActors.access.currentClient()
		let unsignedTx = try await buildTransaction(chainID: chainID, builder: builder)
		let signedTx = try await self.signTransaction(
			unsignedTransaction: unsignedTx,
			signers: signers
		)
		return try await api.sendTransaction(transaction: signedTx)
	}

	func sendTransaction(
		signers: [FlowSigner],
		@Flow.TransactionBuild.TransactionBuilder builder: () -> [Flow.TransactionBuild]
	) async throws -> Flow.ID {
		try await sendTransaction(chainID: self.chainID, signers: signers, builder: builder)
	}
}

	// MARK: - Helper functions

private func resolveBlockId(
	api: FlowAccessProtocol,
	refBlock: Flow.ID?
) async throws -> Flow.ID {
	if let blockID = refBlock {
		await FlowLogger.shared.logAsync(
			.debug,
			message: "Using provided block ID: \(blockID.hex)"
		)
		return blockID
	} else {
		await FlowLogger.shared.logAsync(.debug, message: "Fetching latest sealed block")
		let block = try await api.getLatestBlock(sealed: true)
		await FlowLogger.shared.logAsync(
			.debug,
			message: "Using latest block ID: \(block.id.hex)"
		)
		return block.id
	}
}

private func resolveProposalKey(
	api: FlowAccessProtocol,
	proposalKey: Flow.TransactionProposalKey
) async throws -> Flow.TransactionProposalKey {
	if proposalKey.sequenceNumber == -1 {
		await FlowLogger.shared.logAsync(
			.debug,
			message: "Fetching sequence number for account: \(proposalKey.address.hex)"
		)
		let account = try await api.getAccountAtLatestBlock(address: proposalKey.address)

		guard let accountKey = account.keys[safe: proposalKey.keyIndex] else {
			await FlowLogger.shared.logAsync(
				.error,
				message: "Failed to get account key at index: \(proposalKey.keyIndex)"
			)
			throw Flow.FError.preparingTransactionFailed
		}

		let newKey = Flow.TransactionProposalKey(
			address: account.address,
			keyIndex: proposalKey.keyIndex,
			sequenceNumber: Int64(accountKey.sequenceNumber)
		)

		await FlowLogger.shared.logAsync(
			.debug,
			message: "Resolved sequence number: \(accountKey.sequenceNumber)"
		)
		return newKey
	}

	return proposalKey
}

