//
//  File.swift
//  Flow
//
//  Created by Hao Fu on 4/4/2025.
//

import Foundation

extension CadenceLoader.Category {
    
    public enum Token: String, CaseIterable, CadenceLoaderProtocol {
        case getTokenBalanceStorage = "get_token_balance_storage"
        
        var filename: String {
            rawValue
        }
    }
    
}

// Extension to Flow for convenience methods
public extension Flow {
    func getTokenBalance(address: Flow.Address) async throws -> [String: Decimal] {
        let script = try CadenceLoader.load(CadenceLoader.Category.Token.getTokenBalanceStorage)
        return try await executeScriptAtLatestBlock(
            script: .init(text: script),
            arguments: [.address(address)]
        ).decode()
    }
    
}
