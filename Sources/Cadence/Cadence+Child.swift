//
//  File.swift
//  Flow
//
//  Created by Hao Fu on 1/4/2025.
//

import SwiftUI

extension CadenceLoader.Category {
	public enum Child: String, CaseIterable, CadenceLoaderProtocol {
		case getChildAddress = "get_child_addresses"
		case getChildAccountMeta = "get_child_account_meta"

		var filename: String { rawValue }
	}
}

	// Metadata structure for child accounts
extension CadenceLoader.Category.Child {
	public struct Metadata: Codable {
		public let name: String?
		public let description: String?
		public let thumbnail: Thumbnail?

		public struct Thumbnail: Codable {
			public let urlString: String?

			public var url: URL? {
				guard let urlString else { return nil }
				return URL(string: urlString)
			}

			enum CodingKeys: String, CodingKey {
				case urlString = "url"
			}
		}
	}
}

	// Swift 6 async extensions with MainActor safety
public extension Flow {
		/// Fetch child account addresses with Swift 6 concurrency
	@MainActor
	func getChildAddress(address: Flow.Address) async throws -> [Flow.Address] {
		let script = try CadenceLoader.load(
			CadenceLoader.Category.Child.getChildAddress
		)
		return try await executeScriptAtLatestBlock(
			script: .init(text: script),
			arguments: [.address(address)]
		).decode()
	}

		/// Fetch child account metadata concurrently
	@MainActor
	func getChildMetadata(
		address: Flow.Address
	) async throws -> [String: CadenceLoader.Category.Child.Metadata] {
		let script = try CadenceLoader.load(
			CadenceLoader.Category.Child.getChildAccountMeta
		)
		return try await executeScriptAtLatestBlock(
			script: .init(text: script),
			arguments: [.address(address)]
		).decode()
	}
}
//@MainActor
//class ChildAccountManager {
//	private let flow: Flow
//
//	init(flow: Flow) {
//		self.flow = flow
//	}
//
//		/// Fetch all child account info concurrently
//	func loadAllChildren(for parentAddress: Flow.Address) async throws -> [ChildAccountInfo] {
//			// Concurrent fetch of addresses and metadata
//		async let addresses = flow.getChildAddress(address: parentAddress)
//		async let metadata = flow.getChildMetadata(address: parentAddress)
//
//		let (childAddrs, childMetadata) = try await (addresses, metadata)
//
//		return childAddrs.map { address in
//			ChildAccountInfo(
//				address: address,
//				metadata: childMetadata[address.description] ?? nil
//			)
//		}
//	}
//
//	struct ChildAccountInfo {
//		let address: Flow.Address
//		let metadata: CadenceLoader.Category.Child.Metadata?
//	}
//}
