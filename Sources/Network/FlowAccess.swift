	//
	//  FlowAccess.swift
	//
	//  Created by Hao Fu on 28/10/2022.
	//  Edited for Swift 6 concurrency & actors by Nicholas Reich on 2026-03-19.
	//

import Foundation

extension Flow: FlowAccessProtocol {

	public func ping() async throws -> Bool {
		try await FlowActor.shared.flow.accessAPI.ping()
	}

	public func getLatestBlockHeader(
		blockStatus: Flow.BlockStatus = .final
	) async throws -> BlockHeader {
		try await FlowActor.shared.flow.accessAPI.getLatestBlockHeader(blockStatus: blockStatus)
	}

	public func getBlockHeaderById(id: ID) async throws -> BlockHeader {
		try await FlowActor.shared.flow.accessAPI.getBlockHeaderById(id: id)
	}

	public func getBlockHeaderByHeight(height: UInt64) async throws -> BlockHeader {
		try await FlowActor.shared.flow.accessAPI.getBlockHeaderByHeight(height: height)
	}

	public func getLatestBlock(
		blockStatus: Flow.BlockStatus = .final
	) async throws -> Block {
		try await FlowActor.shared.flow.accessAPI.getLatestBlock(blockStatus: blockStatus)
	}

	public func getBlockById(id: ID) async throws -> Block {
		try await FlowActor.shared.flow.accessAPI.getBlockById(id: id)
	}

	public func getBlockByHeight(height: UInt64) async throws -> Block {
		try await FlowActor.shared.flow.accessAPI.getBlockByHeight(height: height)
	}

	public func getCollectionById(id: ID) async throws -> Collection {
		try await FlowActor.shared.flow.accessAPI.getCollectionById(id: id)
	}

	public func sendTransaction(transaction: Transaction) async throws -> ID {
		try await FlowActor.shared.flow.accessAPI.sendTransaction(transaction: transaction)
	}

	public func getTransactionById(id: ID) async throws -> Transaction {
		try await FlowActor.shared.flow.accessAPI.getTransactionById(id: id)
	}

	public func getTransactionResultById(id: ID) async throws -> TransactionResult {
		try await FlowActor.shared.flow.accessAPI.getTransactionResultById(id: id)
	}

	public func getAccountAtLatestBlock(
		address: Address,
		blockStatus: Flow.BlockStatus = .final
	) async throws -> Account {
		try await FlowActor.shared.flow.accessAPI.getAccountAtLatestBlock(
			address: address,
			blockStatus: blockStatus
		)
	}

	public func getAccountByBlockHeight(
		address: Address,
		height: UInt64
	) async throws -> Account {
		try await FlowActor.shared.flow.accessAPI
			.getAccountByBlockHeight(address: address, height: height)
	}

	public func getEventsForHeightRange(
		type: String,
		range: ClosedRange<UInt64>
	) async throws -> [Event.Result] {
		try await FlowActor.shared.flow.accessAPI.getEventsForHeightRange(type: type, range: range)
	}

	public func getEventsForBlockIds(
		type: String,
		ids: Set<ID>
	) async throws -> [Event.Result] {
		try await FlowActor.shared.flow.accessAPI.getEventsForBlockIds(type: type, ids: ids)
	}

	public func executeScriptAtLatestBlock(
		script: Script,
		arguments: [Argument],
		blockStatus: Flow.BlockStatus = .final
	) async throws -> ScriptResponse {
		try await FlowActor.shared.flow.accessAPI.executeScriptAtLatestBlock(
			script: script,
			arguments: arguments,
			blockStatus: blockStatus
		)
	}

	public func getNetworkParameters() async throws -> ChainID {
		try await FlowActor.shared.flow.accessAPI.getNetworkParameters()
	}
}
