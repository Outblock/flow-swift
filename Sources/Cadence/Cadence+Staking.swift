	//
	//  Staking.swift
	//  Flow
	//
	//  Created by Hao Fu on 4/4/2025.
	//  Edited for Swift 6 concurrency & actors by Nicholas Reich on 2026-03-19.
	//

import Foundation

public extension CadenceLoader.Category {
	enum Staking: String, CaseIterable, CadenceLoaderProtocol {
		case getDelegatorInfo = "get_delegator_info"

		public var filename: String { rawValue }
	}
}

public extension CadenceLoader.Category.Staking {
	struct StakingNode: Codable, Sendable {
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
	@FlowCryptoActor
	func getStakingInfo(
	address: Flow.Address
	) async throws -> [CadenceLoader.Category.Staking.StakingNode] {
		let script = try await CadenceLoader.load(
		CadenceLoader.Category.Staking.getDelegatorInfo
		)
		return try await executeScriptAtLatestBlock(
		script: .init(text: script),
		arguments: [.address(address)]
			).decode()
	}
}

/// Actor for concurrent staking operations
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
