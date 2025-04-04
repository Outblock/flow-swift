//
//  File.swift
//  Flow
//
//  Created by Hao Fu on 4/4/2025.
//

import Foundation

extension CadenceLoader.Category {
    
    public enum Staking: String, CaseIterable, CadenceLoaderProtocol {
        case getDelegatorInfo = "get_delegator_info"
        
        var filename: String {
            rawValue
        }
    }
    
}

// Extension to Flow for convenience methods
public extension Flow {
    func getStakingInfo(address: Flow.Address) async throws -> [CadenceLoader.Category.Staking.StakingNode] {
        let script = try CadenceLoader.load(CadenceLoader.Category.Staking.getDelegatorInfo)
        return try await executeScriptAtLatestBlock(
            script: .init(text: script),
            arguments: [.address(address)]
        ).decode()
    }
    
}

extension CadenceLoader.Category.Staking {
    
    public struct StakingNode: Codable {
        // MARK: Internal

        let id: Int
        let nodeID: String
        let tokensCommitted: Double
        let tokensStaked: Double
        let tokensUnstaking: Double
        let tokensRewarded: Double
        let tokensUnstaked: Double
        let tokensRequestedToUnstake: Double

        var stakingCount: Double {
            tokensCommitted + tokensStaked
        }
    }

    
}
