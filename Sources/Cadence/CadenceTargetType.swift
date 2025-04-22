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
        let script = try decodeScript(from: target.cadenceBase64)
        let api = Flow.FlowHTTPAPI(chainID: chainID)
        return try await api.executeScriptAtLatestBlock(script: script, arguments: target.arguments)
            .decode()
    }
    
    public func sendTransaction(_ target: CadenceTargetType,
                                singers: [FlowSigner],
                                network: Flow.ChainID = .mainnet,
                                @Flow.TransactionBuilder builder: () -> [Flow.TransactionBuild]
    ) async throws -> Flow.ID {
        let script = try decodeScript(from: target.cadenceBase64)
        var tx = try await flow.buildTransaction(chainID: chainID, skipEmptyCheck: true, builder: builder)
        tx.script = script
        tx.arguments = target.arguments
        let signedTx = try await flow.signTransaction(unsignedTransaction: tx, signers: singers)
        return try await flow.sendTransaction(transaction: signedTx)
    }
    
    private func decodeScript(from base64String: String) throws -> Flow.Script {
        // First decode base64 to Data
        guard let data = Data(base64Encoded: base64String) else {
            throw NSError(domain: "Invalid Cadence Base64 String", code: 9900001)
        }
        
        // Convert to string, preserving newlines
        guard let scriptString = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "Invalid UTF8 encoding", code: 9900002)
        }
        
        // Convert back to data with proper encoding
        guard let scriptData = scriptString.data(using: .utf8) else {
            throw NSError(domain: "Failed to encode script", code: 9900003)
        }
        
        return .init(data: scriptData)
    }
}
