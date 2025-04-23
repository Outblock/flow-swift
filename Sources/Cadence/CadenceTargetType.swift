//
//  File.swift
//  Flow
//
//  Created by Hao Fu on 23/4/2025.
//

import Foundation

/// FIX Class

//// Internal Type
public enum CadenceType: String {
    case query
    case transaction
}

public protocol CadenceTargetType {
    
    /// The target's base `URL`.
    var cadenceBase64: String { get }

    /// The HTTP method used in the request.
    var type: CadenceType { get }
    
    /// The return type for decoding
    var returnType: Decodable.Type { get }
    
    var arguments: [Flow.Argument] { get }
}

extension Flow {
    // Update execute function to use the specific return type
    public func query<T: Decodable>(_ target: CadenceTargetType,
                                    chainID: Flow.ChainID = .mainnet) async throws -> T {
        guard let data = Data(base64Encoded: target.cadenceBase64) else {
            throw NSError(domain: "Invalid Cadence Base64 String", code: 9900001)
        }
        let script = Flow.Script(data: data)
        let api = Flow.FlowHTTPAPI(chainID: chainID)
        return try await api.executeScriptAtLatestBlock(script: script, arguments: target.arguments)
            .decode()
    }
    
    public func sendTransaction(_ target: CadenceTargetType,
                                singers: [FlowSigner],
                                network: Flow.ChainID = .mainnet,
                                @Flow.TransactionBuilder builder: () -> [Flow.TransactionBuild]
    ) async throws -> Flow.ID {
        guard let data = Data(base64Encoded: target.cadenceBase64) else {
            throw NSError(domain: "Invalid Cadence Base64 String", code: 9900001)
        }
        var tx = try await flow.buildTransaction(chainID: chainID, skipEmptyCheck: true, builder: builder)
        tx.script = .init(data: data)
        tx.arguments = target.arguments
        let signedTx = try await flow.signTransaction(unsignedTransaction: tx, signers: singers)
        return try await flow.sendTransaction(transaction: signedTx)
    }
}
