	//
	//  FlowBlock.swift
	//
	//  Copyright 2022 Outblock Pty Ltd
	//
	//  Licensed under the Apache License, Version 2.0 (the "License");
	//  you may not use this file except in compliance with the License.
	//  You may obtain a copy of the License at
	//
	//    http://www.apache.org/licenses/LICENSE-2.0
	//
	//  Unless required by applicable law or agreed to in writing, software
	//  distributed under the License is distributed on an "AS IS" BASIS,
	//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	//  See the License for the specific language governing permissions and
	//  limitations under the License.
	//
	//  Reviewed and updated for Swift 6 concurrency by Nicholas Reich on 2026-03-19.
	//

import SwiftUI

	/// Flow Block Model
	///
	/// Represents a block in the Flow blockchain.
	/// Contains block header, payload, and execution results.
	///
	/// Features:
	/// - Block identification
	/// - Transaction inclusion
	/// - Seal verification
	/// - State updates
	///
	/// Example usage:
	/// ```swift
	/// let block = try await flow.getBlockByHeight(height: 12345)
	/// print("Block ID: \(block.id)")
	/// print("Height: \(block.height)")
	/// ```
public extension Flow {
		/// Brief information of `Flow.Block`.
	struct BlockHeader: Codable, Sendable {
			/// The identification of block.
		public let id: ID

			/// The identification of previous block.
		public let parentId: ID

			/// The height of block.
		public let height: UInt64

			/// The time when the block is created.
		public let timestamp: Date

		public init(
			id: Flow.ID,
			parentId: Flow.ID,
			height: UInt64,
			timestamp: Date
		) {
			self.id = id
			self.parentId = parentId
			self.height = height
			self.timestamp = timestamp
		}

		public init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)

			let heightString = try container.decode(String.self, forKey: .height)
			height = UInt64(heightString) ?? 0

			id = try container.decode(ID.self, forKey: .id)
			parentId = try container.decode(ID.self, forKey: .parentId)
			timestamp = try container.decode(Date.self, forKey: .timestamp)
		}
	}

		/// The data structure of `Flow.Block` which is `sealed`.
	struct BlockSeal: Codable, Sendable {
		public let blockId: ID
		public let executionReceiptId: ID
		public let executionReceiptSignatures: [Signature]?
		public let resultApprovalSignatures: [Signature]?

		enum CodingKeys: String, CodingKey {
			case blockId
			case executionReceiptId = "resultId"
		}

		public init(
			blockId: Flow.ID,
			executionReceiptId: Flow.ID,
			executionReceiptSignatures: [Flow.Signature]? = nil,
			resultApprovalSignatures: [Flow.Signature]? = nil
		) {
			self.blockId = blockId
			self.executionReceiptId = executionReceiptId
			self.executionReceiptSignatures = executionReceiptSignatures
			self.resultApprovalSignatures = resultApprovalSignatures
		}

		public init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			blockId = try container.decode(ID.self, forKey: .blockId)
			executionReceiptId = try container.decode(ID.self, forKey: .executionReceiptId)
			executionReceiptSignatures = nil
			resultApprovalSignatures = nil
		}
	}

		/// The data structure for the block in the Flow blockchain.
	struct Block: Codable, Sendable {
			/// The identification of block.
		public let id: ID

			/// The identification of previous block.
		public let parentId: ID

			/// The height of block.
		public let height: UInt64

			/// The time when the block is created.
		public let timestamp: Date


			/// Collection guarantees included in the block.
		public var collectionGuarantees: [Flow.CollectionGuarantee]


			/// Seals associated with the block.
		public var blockSeals: [BlockSeal]

			/// The list of signatures of the block.
		public var signatures: [Signature]?

		public init(
			id: Flow.ID,
			parentId: Flow.ID,
			height: UInt64,
			timestamp: Date,
			collectionGuarantees: [Flow.CollectionGuarantee],
			blockSeals: [Flow.BlockSeal],
			signatures: [Flow.Signature]? = nil
		) {
			self.id = id
			self.parentId = parentId
			self.height = height
			self.timestamp = timestamp
			self.collectionGuarantees = collectionGuarantees
			self.blockSeals = blockSeals
			self.signatures = signatures
		}
	}
}

