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
        public let id: Int
        public let nodeID: String
        public let tokensCommitted: Double
        public let tokensStaked: Double
        public let tokensUnstaking: Double
        public let tokensRewarded: Double
        public let tokensUnstaked: Double
        public let tokensRequestedToUnstake: Double

        public var stakingCount: Double {
            tokensCommitted + tokensStaked
        }
    }
}
