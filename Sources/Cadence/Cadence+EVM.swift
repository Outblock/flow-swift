import Foundation
import BigInt
extension CadenceLoader.Category {
	public enum EVM: String, CaseIterable, CadenceLoaderProtocol {
		case getAddress = "get_addr"
		case createCOA = "create_coa"
		case evmRun = "evm_run"

		var filename: String { rawValue }
	}
}

public extension Flow {
		/// Get EVM address for Flow account
	@MainActor
	func getEVMAddress(address: Flow.Address) async throws -> String? {
		let script = try CadenceLoader.load(
			CadenceLoader.Category.EVM.getAddress
		)
		return try await executeScriptAtLatestBlock(
			script: .init(text: script),
			arguments: [.address(address)]
		).decode()
	}

		/// Create Cadence Object Account (COA) with gas fee
	@MainActor
	func createCOA(
		chainID: ChainID,
		proposer: Address,
		payer: Address,
		amount: Decimal = 0,
		signers: [FlowSigner]
	) async throws -> Flow.ID {
		guard let amountFlow = amount.toFlowValue()?.toArgument() else {
			throw FError.customError(msg: "Amount convert to flow arg failed")
		}

		let script = try CadenceLoader.load(
			CadenceLoader.Category.EVM.createCOA
		)

		let unsignedTx = try await buildTransaction(
			chainID: chainID,
			script: script,
			arguments: [amountFlow],
			payerAddress: payer,
			proposerKey: .init(address: proposer)
		)

		let signedTx = try await signTransaction(
			unsignedTransaction: unsignedTx,
			signers: signers
		)

		return try await sendTransaction(
			chainID: chainID,
			signedTransaction: signedTx
		)
	}

		/// Execute EVM transaction through Flow
	@MainActor
	func runEVMTransaction(
		chainID: ChainID,
		proposer: Address,
		payer: Address,
		rlpEncodedTransaction: [UInt8],
		coinbaseAddress: String,
		signers: [FlowSigner]
	) async throws -> Flow.ID {
		guard let txArg = rlpEncodedTransaction.toFlowValue()?.toArgument(),
			  let coinbaseArg = coinbaseAddress.toFlowValue()?.toArgument() else {
			throw FError.customError(msg: "EVM transaction arguments encoding failed")
		}

		let script = try CadenceLoader.load(
			CadenceLoader.Category.EVM.evmRun
		)

		let unsignedTx = try await buildTransaction(
			chainID: chainID,
			script: script,
			arguments: [txArg, coinbaseArg],
			authorizers: [proposer],
			payerAddress: payer,
			proposerKey: .init(address: proposer)
		)

		let signedTx = try await signTransaction(
			unsignedTransaction: unsignedTx,
			signers: signers
		)

		return try await sendTransaction(
			chainID: chainID,
			signedTransaction: signedTx
		)
	}
}
//extension CadenceLoader.Category {
//    public enum EVM: String, CaseIterable, CadenceLoaderProtocol {
//        case getAddress = "get_addr"
//        case createCOA = "create_coa"
//        case evmRun = "evm_run"
//        
//        var filename: String {
//            rawValue
//        }
//    }
//}
//
//// Extension to Flow for convenience methods
//public extension Flow {
//    /// Get the EVM address associated with a Flow address
//    /// - Parameter address: Flow address to query
//    /// - Returns: EVM address as a hex string
//    /// - Throws: Error if script cannot be loaded or execution fails
//    func getEVMAddress(address: Flow.Address) async throws -> String? {
//        let script = try CadenceLoader.load(CadenceLoader.Category.EVM.getAddress)
//        return try await executeScriptAtLatestBlock(
//            script: .init(text: script),
//            arguments: [.address(address)]
//        ).decode()
//    }
//    
//    func createCOA(chainID: ChainID, proposer: Address, payer: Address, amount: Decimal = 0, signers: [FlowSigner]) async throws -> Flow.ID {
//        guard let amountFlow = amount.toFlowValue()?.toArgument() else {
//            throw FError.customError(msg: "Amount convert to flow arg failed")
//        }
//        let script = try CadenceLoader.load(CadenceLoader.Category.EVM.createCOA)
//        let unsignedTx = try await flow.buildTransaction(chainID: chainID,
//                                                         script: script,
//                                                         agrument: [amountFlow],
//                                                         payerAddress: payer,
//                                                         proposerKey: .init(address: proposer))
//        let signedTx = try await flow.signTransaction(unsignedTransaction: unsignedTx, signers: signers)
//        return try await flow.sendTransaction(chainID: chainID,signedTransaction: signedTx)
//    }
//    
//    func runEVMTransaction(chainID: ChainID,
//                           proposer: Address,
//                           payer: Address,
//                           rlpEncodedTransaction: [UInt8],
//                           coinbaseAddress: String,
//                           signers: [FlowSigner]) async throws -> Flow.ID {
//        guard let txArg = rlpEncodedTransaction.toFlowValue()?.toArgument(),
//              let coinbaseArg = coinbaseAddress.toFlowValue()?.toArgument() else {
//            throw FError.customError(msg: "EVM transaction arguments encoding failed")
//        }
//        let script = try CadenceLoader.load(CadenceLoader.Category.EVM.evmRun)
//        let unsignedTx = try await flow.buildTransaction(chainID: chainID,
//                                                         script: script,
//                                                         agrument: [txArg, coinbaseArg],
//                                                         authorizer: [proposer],
//                                                         payerAddress: payer,
//                                                         proposerKey: .init(address: proposer))
//        let signedTx = try await flow.signTransaction(unsignedTransaction: unsignedTx, signers: signers)
//        return try await flow.sendTransaction(chainID: chainID, signedTransaction: signedTx)
//    }
//    
//} 
