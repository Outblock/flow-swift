	//
	//  BatchProcessor.swift
	//  Flow
	//
	//  Created by Hao Fu on 4/4/2022.
	//  Edited for Swift 6 concurrency & actors by Nicholas Reich on 2026-03-19.
	//

import Foundation

public typealias FlowData = [String: String]

actor BatchProcessor {
	func processAccounts(_ addresses: [Flow.Address]) async throws -> [Flow.Address: FlowData] {
		var results: [Flow.Address: FlowData] = [:]

		try await withThrowingTaskGroup(of: (Flow.Address, FlowData).self) { group in
			for address in addresses {
				group.addTask {
					let data = try await self.processAccount(address)
					return (address, data)
				}
			}

			for try await (address, data) in group {
				results[address] = data
			}
		}

		return results
	}

	private func processAccount(_ address: Flow.Address) async throws -> FlowData {
			// Simulate async work
		try await _Concurrency.Task.sleep(nanoseconds: 100_000_000) // 0.1s
		return ["address": address.hex, "balance": "1000"]
	}
}
