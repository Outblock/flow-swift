//
//  File.swift
//
//
//  Created by Hao Fu on 28/10/2022.
//

import Foundation

extension Flow: FlowAccessProtocol {
    public func ping() async throws -> Bool {
        return try await flow.accessAPI.ping()
    }

    public func getLatestBlockHeader(blockStatus: Flow.BlockStatus = .final) async throws -> BlockHeader {
        return try await flow.accessAPI.getLatestBlockHeader(blockStatus: blockStatus)
    }

    public func getBlockHeaderById(id: ID) async throws -> BlockHeader {
        return try await flow.accessAPI.getBlockHeaderById(id: id)
    }

    public func getBlockHeaderByHeight(height: UInt64) async throws -> BlockHeader {
        return try await flow.accessAPI.getBlockHeaderByHeight(height: height)
    }

    public func getLatestBlock(blockStatus: Flow.BlockStatus = .final) async throws -> Block {
        return try await flow.accessAPI.getLatestBlock(blockStatus: blockStatus)
    }

    public func getBlockById(id: ID) async throws -> Block {
        return try await flow.accessAPI.getBlockById(id: id)
    }

    public func getBlockByHeight(height: UInt64) async throws -> Block {
        return try await flow.accessAPI.getBlockByHeight(height: height)
    }

    public func getCollectionById(id: ID) async throws -> Collection {
        return try await flow.accessAPI.getCollectionById(id: id)
    }

    public func sendTransaction(transaction: Transaction) async throws -> ID {
        return try await flow.accessAPI.sendTransaction(transaction: transaction)
    }

    public func getTransactionById(id: ID) async throws -> Transaction {
        return try await flow.accessAPI.getTransactionById(id: id)
    }

    public func getTransactionResultById(id: ID) async throws -> TransactionResult {
        return try await flow.accessAPI.getTransactionResultById(id: id)
    }

    public func getAccountAtLatestBlock(address: Address, blockStatus: Flow.BlockStatus = .final) async throws -> Account {
        return try await flow.accessAPI.getAccountAtLatestBlock(address: address, blockStatus: blockStatus)
    }

    public func getAccountByBlockHeight(address: Address, height: UInt64) async throws -> Account {
        return try await flow.accessAPI.getAccountByBlockHeight(address: address, height: height)
    }

    public func getEventsForHeightRange(type: String, range: ClosedRange<UInt64>) async throws -> [Event.Result] {
        return try await flow.accessAPI.getEventsForHeightRange(type: type, range: range)
    }

    public func getEventsForBlockIds(type: String, ids: Set<ID>) async throws -> [Event.Result] {
        return try await flow.accessAPI.getEventsForBlockIds(type: type, ids: ids)
    }

    public func executeScriptAtLatestBlock(script: Script, arguments: [Argument], blockStatus: Flow.BlockStatus = .final) async throws -> ScriptResponse {
        return try await flow.accessAPI.executeScriptAtLatestBlock(script: script, arguments: arguments, blockStatus: blockStatus)
    }

    public func getNetworkParameters() async throws -> ChainID {
        return try await flow.accessAPI.getNetworkParameters()
    }
}
