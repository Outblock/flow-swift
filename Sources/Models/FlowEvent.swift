	//
	//  FlowEvent.swift
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
	//  Edited for Swift 6 concurrency & actors by Nicholas Reich on 2026-03-19.

import Foundation

	/// Flow Event Model
	///
	/// Represents blockchain events emitted during transaction execution.
	/// Provides structure for event data and result handling.
public extension Flow {
		/// Flow blockchain event.
	struct Event: Codable, Sendable {
			/// Event type identifier.
		public let type: String

			/// The id for the transaction, `Flow.ID`.
		public let transactionId: ID
		public let transactionIndex: Int
		public let eventIndex: Int
		public let payload: Payload

		public init(
			type: String,
			transactionId: Flow.ID,
			transactionIndex: Int,
			eventIndex: Int,
			payload: Flow.Event.Payload
		) {
			self.type = type
			self.transactionId = transactionId
			self.transactionIndex = transactionIndex
			self.eventIndex = eventIndex
			self.payload = payload
		}

		public init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			self.type = try container.decode(String.self, forKey: .type)
			self.transactionId = try container.decode(Flow.ID.self, forKey: .transactionId)

			let transactionIndexString = try container.decode(String.self, forKey: .transactionIndex)
			self.transactionIndex = Int(transactionIndexString) ?? -1

			let eventIndexString = try container.decode(String.self, forKey: .eventIndex)
			self.eventIndex = Int(eventIndexString) ?? -1

			self.payload = try container.decode(Flow.Event.Payload.self, forKey: .payload)
		}

			/// Event result including block context.
		public struct Result: Codable, Sendable {
				/// Block ID where event occurred.
			public let blockId: Flow.ID

				/// Block height.
			public let blockHeight: UInt64

				/// Events in this result.
			public let events: [Flow.Event]

			public init(
				blockId: Flow.ID,
				blockHeight: UInt64,
				events: [Flow.Event]
			) {
				self.blockId = blockId
				self.blockHeight = blockHeight
				self.events = events
			}

			public init(from decoder: Decoder) throws {
				let container = try decoder.container(keyedBy: CodingKeys.self)
				self.blockId = try container.decode(Flow.ID.self, forKey: .blockId)

				let heightString = try container.decode(String.self, forKey: .blockHeight)
				self.blockHeight = UInt64(heightString) ?? 0

				self.events = try container.decode([Flow.Event].self, forKey: .events)
			}
		}

			/// Raw Cadence payload and decoded argument fields.
		public struct Payload: FlowEntity, Codable, Sendable {
			public var data: Data
			public var fields: Flow.Argument?

			public init(data: Data) {
				self.data = data
				self.fields = try? JSONDecoder().decode(Flow.Argument.self, from: data)
			}

			public init(bytes: [UInt8]) {
				self.init(data: Data(bytes))
			}

			public init(from decoder: Decoder) throws {
				let container = try decoder.singleValueContainer()
				self.data = try container.decode(Data.self)
				self.fields = try? JSONDecoder().decode(Flow.Argument.self, from: data)
			}

			public func encode(to encoder: Encoder) throws {
				var container = encoder.singleValueContainer()
				try container.encode(data)
			}
		}
	}

	struct Snapshot: FlowEntity, Equatable, Codable, Sendable {
		public var data: Data

		public init(data: Data) {
			self.data = data
		}

		public init(bytes: [UInt8]) {
			self.data = Data(bytes)
		}
	}
}

extension Flow.Snapshot: CustomStringConvertible {
	public var description: String { data.hexValue }
}

// MARK: - FlowDecodable for Event.Payload

extension Flow.Event.Payload: FlowDecodable {
	public func decode() -> Any? {
		fields?.decode()
	}

	public func decode<T: Decodable>(_ decodable: T.Type) throws -> T {
		guard let result: T = try? fields?.decode(decodable) else {
			throw Flow.FError.decodeFailure
		}
		return result
	}

	public func decode<T: Decodable>() throws -> T {
		guard let result: T = try? fields?.decode() else {
			throw Flow.FError.decodeFailure
		}
		return result
	}
}

// MARK: - Event field helpers

extension Flow.Event {
	public func getField<T: Decodable>(_ name: String) -> T? {
		try? payload.fields?
		.value
		.toEvent()?
		.fields
		.first(where: { $0.name == name })?
		.value
		.decode(T.self)
	}
}

// MARK: - TransactionResult helpers

extension Flow.TransactionResult {
	public func getEvent(_ type: String) -> Flow.Event? {
		events.first { $0.type == type }
	}

	public func getCreatedAddress() -> String? {
		getEvent(Flow.accountCreationEventType)?
			.getField(Flow.accountCreationFieldName)
	}
}
