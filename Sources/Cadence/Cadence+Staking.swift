//
//  File.swift
//  Flow
//
//  Created by Hao Fu on 4/4/2025.
//

import SwiftUI

extension CadenceLoader.Category {
	public enum Staking: String, CaseIterable, CadenceLoaderProtocol {
		case getDelegatorInfo = "get_delegator_info"

		var filename: String { rawValue }
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

		public var unstakingCount: Double {
			tokensUnstaking + tokensRequestedToUnstake
		}
	}
}

public extension Flow {
		/// Get staking info for delegator
	@MainActor
	func getStakingInfo(
		address: Flow.Address
	) async throws -> [CadenceLoader.Category.Staking.StakingNode] {
		let script = try CadenceLoader.load(
			CadenceLoader.Category.Staking.getDelegatorInfo
		)
		return try await executeScriptAtLatestBlock(
			script: .init(text: script),
			arguments: [.address(address)]
		).decode()
	}
}

	// Actor for concurrent staking operations
actor StakingCoordinator {
	private let flow: Flow

	init(flow: Flow) {
		self.flow = flow
	}

		/// Concurrent fetch of multiple delegators' staking info
	func loadStakingBatch(
		for addresses: [Flow.Address]
	) async throws -> [Flow.Address: [CadenceLoader.Category.Staking.StakingNode]] {
		let results = try await withThrowingTaskGroup(
			of: (Flow.Address, [CadenceLoader.Category.Staking.StakingNode]).self
		) { group in
			for address in addresses {
				group.addTask {
					let staking = try await self.flow.getStakingInfo(address: address)
					return (address, staking)
				}
			}

			var dict: [Flow.Address: [CadenceLoader.Category.Staking.StakingNode]] = [:]
			for try await (address, staking) in group {
				dict[address] = staking
			}
			return dict
		}

		return results
	}
}
/*@MainActor
 func updateUI(with data: String) {
 // Safe to update UI
 self.label.stringValue = data
 }

 @MainActor
 class FlowViewModel: ObservableObject {
 @Published var state: String = ""

 func load() {
 Task {
 let result = try await fetchData()
 await updateState(result)
 }
 }

 @MainActor
 func updateState(_ result: String) {
 state = result
 }
 }*/

//
//extension CadenceLoader.Category {
//    
//    public enum Staking: String, CaseIterable, CadenceLoaderProtocol {
//        case getDelegatorInfo = "get_delegator_info"
//        
//        var filename: String {
//            rawValue
//        }
//    }
//    
//}
//
//// Extension to Flow for convenience methods
//public extension Flow {
//    func getStakingInfo(address: Flow.Address) async throws -> [CadenceLoader.Category.Staking.StakingNode] {
//        let script = try CadenceLoader.load(CadenceLoader.Category.Staking.getDelegatorInfo)
//        return try await executeScriptAtLatestBlock(
//            script: .init(text: script),
//            arguments: [.address(address)]
//        ).decode()
//    }
//}
//
//extension CadenceLoader.Category.Staking {
//    public struct StakingNode: Codable {
//        public let id: Int
//        public let nodeID: String
//        public let tokensCommitted: Double
//        public let tokensStaked: Double
//        public let tokensUnstaking: Double
//        public let tokensRewarded: Double
//        public let tokensUnstaked: Double
//        public let tokensRequestedToUnstake: Double
//
//        public var stakingCount: Double {
//            tokensCommitted + tokensStaked
//        }
//    }
//}
