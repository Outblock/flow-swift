	//
	//  FlowHTTPClient.swift
	//  Flow
	//
	//  Created by Hao Fu on 24/4/2025.
	//  Edited for Swift 6 concurrency & actors by Nicholas Reich on 2026-03-23.
	//

import Foundation

	/// HTTP implementation of the Flow access API, using URLSession.
	/// Concurrency-safe via actor isolation.
public actor FlowHTTPAPI: FlowAccessProtocol {

	public static let client = FlowHTTPAPI()

	public var chainID: Flow.ChainID

	public init(chainID: Flow.ChainID = .mainnet) {
		self.chainID = chainID
	}

		// MARK: - Core request/decoding

		/// Decode helper with Flow's JSON settings and 400-error mapping.
		/// - Throws: Decoding errors or API errors.
	public static func decode<T: Decodable>(
		_ data: Data,
		response: URLResponse? = nil
	) throws -> T {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS'Z'"
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .formatted(dateFormatter)
		decoder.keyDecodingStrategy = .convertFromSnakeCase

		if let httpResponse = response as? HTTPURLResponse,
		   httpResponse.statusCode == 400 {
			let errorModel = try decoder.decode(ErrorResponse.self, from: data)
			throw Flow.FError.customError(msg: errorModel.message)
		}

		return try decoder.decode(T.self, from: data)
	}

		/// Low-level HTTP request wrapper.
	private func request<T: Decodable, U: TargetType>(_ target: U) async throws -> T {
		await FlowLogger.shared
			.log(.debug, message: "Starting request to: \(target.path)")

		guard
			let baseURL = chainID.defaultHTTPNode.url,
			var urlComponents = URLComponents(string: baseURL.absoluteString),
			case let .requestParameters(parameters, body: body) = target.task
		else {
			await FlowLogger.shared
				.log(.error, message: "Invalid URL configuration")
			throw Flow.FError.urlInvaild
		}

		await FlowLogger.shared
			.log(.debug, message: "Request parameters: \(String(describing: parameters))")

		if let bodyObject = body {
			await FlowLogger.shared
				.log(.debug, message: "Request body: \(String(describing: bodyObject))")
		}

		urlComponents.path = target.path

		if let parametersList = parameters, !parametersList.isEmpty {
			urlComponents.queryItems = parametersList.compactMap { key, value in
				URLQueryItem(name: key, value: value)
			}
		}

		guard let url = urlComponents.url else {
			throw Flow.FError.urlInvaild
		}

		var request = URLRequest(url: url)
		request.httpMethod = target.method.rawValue

		if let bodyObject = body {
			let encoder = JSONEncoder()
			encoder.keyEncodingStrategy = .convertToSnakeCase
			let data = try encoder.encode(AnyEncodable(bodyObject))
			request.httpBody = data
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			request.setValue(Flow.shared.defaultUserAgent, forHTTPHeaderField: "User-Agent")
		}

		if let headers = target.headers {
			headers.forEach { key, value in
				request.setValue(value, forHTTPHeaderField: key)
			}
		}

		let (data, response) = try await URLSession.shared.data(for: request)

		if let httpResponse = response as? HTTPURLResponse {
			await FlowLogger.shared
				.log(.debug, message: "Response status code: \(httpResponse.statusCode)")
		}

		if let jsonString = String(data: data, encoding: .utf8) {
			await FlowLogger.shared
				.log(.debug, message: "Response \(jsonString)")
		}

		do {
			let result: T = try FlowHTTPAPI.decode(data, response: response)
			await FlowLogger.shared
				.log(.debug, message: "Successfully decoded response of type: \(T.self)")
			return result
		} catch {
			await FlowLogger.shared
				.log(.error, message: "Decoding error: \(error)")
			throw error
		}
	}

		// MARK: - FlowAccessProtocol

	public func ping() async throws -> Bool {
		let result: [Flow.BlockHeaderResponse] = try await request(Flow.AccessEndpoint.ping)
		guard let block = result.first else {
			return false
		}
		return block.header.height > 0
	}

	public func getNetworkParameters() async throws -> Flow.ChainID {
		let result: Flow.NetworkResponse = try await request(Flow.AccessEndpoint.getNetwork)
		return result.chainId
	}

	public func getLatestBlockHeader(
		blockStatus: Flow.BlockStatus
	) async throws -> Flow.BlockHeader {
		let result: [Flow.BlockHeaderResponse] = try await request(
			Flow.AccessEndpoint.getLatestBlockHeader(blockStatus: blockStatus)
		)
		guard let block = result.first else {
			throw Flow.FError.invaildResponse
		}
		return block.header
	}

	public func getBlockHeaderById(id: Flow.ID) async throws -> Flow.BlockHeader {
		let result: [Flow.BlockHeaderResponse] = try await request(
			Flow.AccessEndpoint.getBlockById(id: id)
		)
		guard let block = result.first else {
			throw Flow.FError.invaildResponse
		}
		return block.header
	}

	public func getBlockHeaderByHeight(height: UInt64) async throws -> Flow.BlockHeader {
		let result: [Flow.BlockHeaderResponse] = try await request(
			Flow.AccessEndpoint.getBlockByHeight(height: height)
		)
		guard let block = result.first else {
			throw Flow.FError.invaildResponse
		}
		return block.header
	}

	public func getLatestBlock(
		blockStatus: Flow.BlockStatus
	) async throws -> Flow.Block {
		let result: [Flow.BlockResponse] = try await request(
			Flow.AccessEndpoint.getLatestBlock(blockStatus: blockStatus)
		)
		guard let block = result.first else {
			throw Flow.FError.invaildResponse
		}
		return block.toFlowBlock()
	}

	public func getBlockById(id: Flow.ID) async throws -> Flow.Block {
		let result: [Flow.BlockResponse] = try await request(
			Flow.AccessEndpoint.getBlockById(id: id)
		)
		guard let block = result.first else {
			throw Flow.FError.invaildResponse
		}
		return block.toFlowBlock()
	}

	public func getBlockByHeight(height: UInt64) async throws -> Flow.Block {
		let result: [Flow.BlockResponse] = try await request(
			Flow.AccessEndpoint.getBlockByHeight(height: height)
		)
		guard let block = result.first else {
			throw Flow.FError.invaildResponse
		}
		return block.toFlowBlock()
	}

	public func getCollectionById(id: Flow.ID) async throws -> Flow.Collection {
		try await request(Flow.AccessEndpoint.getCollectionById(id: id))
	}

	public func sendTransaction(
		transaction: Flow.Transaction
	) async throws -> Flow.ID {
		let result: Flow.TransactionResult = try await request(
			Flow.AccessEndpoint.sendTransaction(transaction: transaction)
		)
		return result.blockId
	}

	public func getTransactionById(id: Flow.ID) async throws -> Flow.Transaction {
		try await request(Flow.AccessEndpoint.getTransactionById(id: id))
	}

	public func getTransactionResultById(
		id: Flow.ID
	) async throws -> Flow.TransactionResult {
		try await request(Flow.AccessEndpoint.getTransactionResultById(id: id))
	}

	public func getAccountAtLatestBlock(
		address: Flow.Address,
		blockStatus: Flow.BlockStatus = .final
	) async throws -> Flow.Account {
		try await request(
			Flow.AccessEndpoint.getAccountAtLatestBlock(
				address: address,
				blockStatus: blockStatus
			)
		)
	}

	public func getAccountByBlockHeight(
		address: Flow.Address,
		height: UInt64
	) async throws -> Flow.Account {
		try await request(
			Flow.AccessEndpoint.getAccountByBlockHeight(address: address, height: height)
		)
	}

	public func executeScriptAtLatestBlock(
		script: Flow.Script,
		arguments: [Flow.Argument],
		blockStatus: Flow.BlockStatus
	) async throws -> Flow.ScriptResponse {
		let resolvedScript = FlowActor.shared.flow.addressRegister
			.resolveImports(in: script.text, for: chainID)
		return try await request(
			Flow.AccessEndpoint.executeScriptAtLatestBlock(
				script: .init(text: resolvedScript),
				arguments: arguments,
				blockStatus: blockStatus
			)
		)
	}

	public func executeScriptAtBlockId(
		script: Flow.Script,
		blockId: Flow.ID,
		arguments: [Flow.Argument]
	) async throws -> Flow.ScriptResponse {
		let resolvedScript = FlowActor.shared.flow.addressRegister
			.resolveImports(in: script.text, for: chainID)
		return try await request(
			Flow.AccessEndpoint.executeScriptAtBlockId(
				script: .init(text: resolvedScript),
				blockId: blockId,
				arguments: arguments
			)
		)
	}

	public func executeScriptAtBlockHeight(
		script: Flow.Script,
		height: UInt64,
		arguments: [Flow.Argument]
	) async throws -> Flow.ScriptResponse {
		let resolvedScript = FlowActor.shared.flow.addressRegister
			.resolveImports(in: script.text, for: chainID)
		return try await request(
			Flow.AccessEndpoint.executeScriptAtBlockHeight(
				script: .init(text: resolvedScript),
				height: height,
				arguments: arguments
			)
		)
	}

	public func getEventsForHeightRange(
		type: String,
		range: ClosedRange<UInt64>
	) async throws -> [Flow.Event.Result] {
		try await request(
			Flow.AccessEndpoint.getEventsForHeightRange(type: type, range: range)
		)
	}

	public func getEventsForBlockIds(
		type: String,
		ids: Set<Flow.ID>
	) async throws -> [Flow.Event.Result] {
		try await request(
			Flow.AccessEndpoint.getEventsForBlockIds(type: type, ids: ids)
		)
	}

		// MARK: - Internal models

	private struct ErrorResponse: Decodable {
		let message: String
	}
}
