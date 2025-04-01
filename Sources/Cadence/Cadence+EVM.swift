import Foundation
import BigInt

// Extension to Flow for convenience methods
public extension Flow {
    /// Get the EVM address associated with a Flow address
    /// - Parameter address: Flow address to query
    /// - Returns: EVM address as a hex string
    /// - Throws: Error if script cannot be loaded or execution fails
    func getEVMAddress(address: Flow.Address) async throws -> String? {
        let script = try CadenceLoader.load(CadenceLoader.Category.EVM.getAddress)
        return try await executeScriptAtLatestBlock(
            script: .init(text: script),
            arguments: [.address(address)]
        ).decode()
    }
    
} 
