//
//  File.swift
//  Flow
//
//  Created by Hao Fu on 1/4/2025.
//

import Foundation

// Extension to Flow for convenience methods
public extension Flow {
    
    /// Get the EVM address associated with a Flow address
    /// - Parameter address: Flow address to query
    /// - Returns: EVM address as a hex string
    /// - Throws: Error if script cannot be loaded or execution fails
    func getChildAddress(address: Flow.Address) async throws -> [Flow.Address] {
        let script = try CadenceLoader.load(CadenceLoader.Category.Child.getChildAddress)
        return try await executeScriptAtLatestBlock(
            script: .init(text: script),
            arguments: [.address(address)]
        ).decode()
    }
    
    func getChildMetadata(address: Flow.Address) async throws -> [String: CadenceLoader.Category.Child.Metadata] {
        let script = try CadenceLoader.load(CadenceLoader.Category.Child.getChildAccountMeta)
        return try await executeScriptAtLatestBlock(
            script: .init(text: script),
            arguments: [.address(address)]
        ).decode()
    }
    
}

extension CadenceLoader.Category.Child {
    public struct Metadata: Codable {
        public let name: String
        public let description: String
        public let thumbnail: Thumbnail
    }
    
    public struct Thumbnail: Codable {
        public let url: URL
    }
}
