//
//  BatchProcessor.swift
//  
//
//  Created by Nicholas Reich on 3/19/26.
//
import SwiftUI

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
}
