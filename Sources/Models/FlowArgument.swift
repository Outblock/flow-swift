	//
	//  FlowArgument.swift
	//  Flow
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
	//  Reviewed for Swift 6 concurrency & actors by Nicholas Reich on 2026-03-19.
	//

import BigInt
import Foundation

	/// Flow Argument Model
	///
	/// Represents arguments passed to Cadence scripts and transactions.
	/// Handles type conversion and encoding for network transmission.
	///
	/// Features:
	/// - Type safety
	/// - JSON encoding/decoding
	/// - Cadence value conversion
	/// - Argument validation
	///
	/// Example usage:
	/// ```swift
	/// let arg = Flow.Argument(value: .string("Hello"))
	/// let snapshot = try await flow.accessAPI.executeScriptAtLatestBlock(
	///     script: myScript,
	///     arguments: [arg]
	/// )
	/// ```
public extension Flow {
		/// The argument for Cadence code for encoding and decoding.
	struct Argument: Codable, Equatable {
			/// The type of the argument in `Flow.Cadence.FType`.
		public let type: Cadence.FType

			/// The value of the argument in `Flow.Cadence.FValue`.
		public let value: Cadence.FValue

		enum CodingKeys: String, CodingKey {
			case type
			case value
		}

			/// Encode argument into JSON data.
		public var jsonData: Data? {
			guard let jsonData = try? flow.encoder.encode(self) else {
				return nil
			}
			return jsonData
		}

			/// Encode argument into JSON string.
		public var jsonString: String? {
			guard let data = jsonData else {
				return nil
			}
			return String( data, encoding: .utf8)
		}

			/// Initial argument with type and value.
		public init(type: Cadence.FType, value: Flow.Cadence.FValue) {
			self.type = type
			self.value = value
		}

			/// Initial argument with value in `Flow.Cadence.FValue` type.
		public init(value: Flow.Cadence.FValue) {
			type = value.type
			self.value = value
		}

			/// Initialize argument from any `FlowEncodable` value.
		public init?(_ value: FlowEncodable) {
			guard let flowArgument = value.toFlowValue() else {
				return nil
			}

			self.type = flowArgument.type
			self.value = flowArgument
		}

			/// Initialize from JSON data.
		public init?(jsonData: Data) {
			do {
				let result = try JSONDecoder().decode(Flow.Argument.self, from: jsonData)
				self.init(type: result.type, value: result.value)
			} catch {
				print(error)
				return nil
			}
		}

			/// Initialize from JSON string.
		public init?(jsonString: String) {
			guard let data = jsonString.data(using: .utf8) else {
				return nil
			}
			self.init(jsonData: data)
		}

			/// Decode argument from JSON.
		public init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			type = try container.decode(Cadence.FType.self, forKey: .type)

			switch type {
				case .int:
					let rawValue = try? container.decode(String.self, forKey: .value)
					guard let s = rawValue, let v = Int(s) else { value = .error; return }
					value = .int(v)
				case .uint:
					let rawValue = try? container.decode(String.self, forKey: .value)
					guard let s = rawValue, let v = UInt(s) else { value = .error; return }
					value = .uint(v)
				case .int8:
					let rawValue = try? container.decode(String.self, forKey: .value)
					guard let s = rawValue, let v = Int8(s) else { value = .error; return }
					value = .int8(v)
				case .uint8:
					let rawValue = try? container.decode(String.self, forKey: .value)
					guard let s = rawValue, let v = UInt8(s) else { value = .error; return }
					value = .uint8(v)
				case .int16:
					let rawValue = try? container.decode(String.self, forKey: .value)
					guard let s = rawValue, let v = Int16(s) else { value = .error; return }
					value = .int16(v)
				case .uint16:
					let rawValue = try? container.decode(String.self, forKey: .value)
					guard let s = rawValue, let v = UInt16(s) else { value = .error; return }
					value = .uint16(v)
				case .int32:
					let rawValue = try? container.decode(String.self, forKey: .value)
					guard let s = rawValue, let v = Int32(s) else { value = .error; return }
					value = .int32(v)
				case .uint32:
					let rawValue = try? container.decode(String.self, forKey: .value)
					guard let s = rawValue, let v = UInt32(s) else { value = .error; return }
					value = .uint32(v)
				case .int64:
					let rawValue = try? container.decode(String.self, forKey: .value)
					guard let s = rawValue, let v = Int64(s) else { value = .error; return }
					value = .int64(v)
				case .uint64:
					let rawValue = try? container.decode(String.self, forKey: .value)
					guard let s = rawValue, let v = UInt64(s) else { value = .error; return }
					value = .uint64(v)
				case .int128:
					let rawValue = try? container.decode(String.self, forKey: .value)
					guard let s = rawValue, let v = BigInt(s) else { value = .error; return }
					value = .int128(v)
				case .uint128:
					let rawValue = try? container.decode(String.self, forKey: .value)
					guard let s = rawValue, let v = BigUInt(s) else { value = .error; return }
					value = .uint128(v)
				case .int256:
					let rawValue = try? container.decode(String.self, forKey: .value)
					guard let s = rawValue, let v = BigInt(s) else { value = .error; return }
					value = .int256(v)
				case .uint256:
					let rawValue = try? container.decode(String.self, forKey: .value)
					guard let s = rawValue, let v = BigUInt(s) else { value = .error; return }
					value = .uint256(v)
				case .word8:
					let rawValue = try? container.decode(String.self, forKey: .value)
					guard let s = rawValue, let v = UInt8(s) else { value = .error; return }
					value = .word8(v)
				case .word16:
					let rawValue = try? container.decode(String.self, forKey: .value)
					guard let s = rawValue, let v = UInt16(s) else { value = .error; return }
					value = .word16(v)
				case .word32:
					let rawValue = try? container.decode(String.self, forKey: .value)
					guard let s = rawValue, let v = UInt32(s) else { value = .error; return }
					value = .word32(v)
				case .word64:
					let rawValue = try? container.decode(String.self, forKey: .value)
					guard let s = rawValue, let v = UInt64(s) else { value = .error; return }
					value = .word64(v)
				case .fix64:
					let rawValue = try? container.decode(String.self, forKey: .value)
					guard let s = rawValue, let v = Decimal(string: s) else { value = .error; return }
					value = .fix64(v)
				case .ufix64:
					let rawValue = try? container.decode(String.self, forKey: .value)
					guard let s = rawValue, let v = Decimal(string: s) else { value = .error; return }
					value = .ufix64(v)
				case .string:
					let rawValue = try? container.decode(String.self, forKey: .value)
					guard let s = rawValue else { value = .error; return }
					value = .string(s)
				case .bool:
					let rawValue = try? container.decode(Bool.self, forKey: .value)
					guard let b = rawValue else { value = .error; return }
					value = .bool(b)
				case .optional:
					let rawValue = try? container.decode(Argument.self, forKey: .value)
					guard let arg = rawValue else { value = .optional(nil); return }
					value = .optional(arg.value)
				case .address:
					let rawValue = try? container.decode(String.self, forKey: .value)
					guard let s = rawValue else { value = .error; return }
					value = .address(Flow.Address(hex: s))
				case .path:
					let rawValue = try? container.decode(Path.self, forKey: .value)
					guard let p = rawValue else { value = .error; return }
					value = .path(p)
				case .event:
					let rawValue = try? container.decode(Event.self, forKey: .value)
					guard let e = rawValue else { value = .error; return }
					value = .event(e)
				case .array:
					let rawValue = try? container.decode([Flow.Argument].self, forKey: .value)
					guard let arr = rawValue else { value = .error; return }
					value = .array(arr.toValue())
				case .character:
					let rawValue = try? container.decode(String.self, forKey: .value)
					guard let c = rawValue else { value = .error; return }
					value = .character(c)
				case .reference:
					let rawValue = try? container.decode(Reference.self, forKey: .value)
					guard let r = rawValue else { value = .error; return }
					value = .reference(r)
				case .struct:
					let rawValue = try? container.decode(Event.self, forKey: .value)
					guard let e = rawValue else { value = .error; return }
					value = .struct(e)
				case .resource:
					let rawValue = try? container.decode(Event.self, forKey: .value)
					guard let e = rawValue else { value = .error; return }
					value = .resource(e)
				case .dictionary:
					let rawValue = try? container.decode(
						[Flow.Argument.Dictionary].self,
						forKey: .value
					)
					guard let d = rawValue else { value = .error; return }
					value = .dictionary(d)
				case .capability:
					let rawValue = try? container.decode(
						Flow.Argument.Capability.self,
						forKey: .value
					)
					guard let c = rawValue else { value = .error; return }
					value = .capability(c)
				case .enum:
					let rawValue = try? container.decode(
						Flow.Argument.Event.self,
						forKey: .value
					)
					guard let e = rawValue else { value = .error; return }
					value = .enum(e)
				case .contract:
					let rawValue = try? container.decode(
						Flow.Argument.Event.self,
						forKey: .value
					)
					guard let e = rawValue else { value = .error; return }
					value = .contract(e)
				case .type:
					let rawValue = try? container.decode(
						Flow.Argument.StaticType.self,
						forKey: .value
					)
					guard let t = rawValue else { value = .error; return }
					value = .type(t)
				case .void:
					value = .void
				case .undefined:
					value = .unsupported
			}
		}

		public func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)
			try container.encode(type, forKey: .type)
			try container.encode(value, forKey: .value)
		}
	}
}

extension Flow.Argument: CustomStringConvertible {
	public var description: String {
		"\n\(type.rawValue): \(value.description)"
	}
}

public extension Flow.Argument {
	/// The data structure for `.path` argument type.
	/// More detail can be found here:
	/// https://docs.onflow.org/cadence/json-cadence-spec/#path
	struct Path: Codable, Equatable {
		public let domain: String
		public let identifier: String

		public init(domain: String, identifier: String) {
			self.domain = domain
			self.identifier = identifier
		}
	}

		/// The data structure for `.struct, .resource, .event, .contract, .enum` argument type.
		/// More detail can be found here:
		/// https://docs.onflow.org/cadence/json-cadence-spec/#composites-struct-resource-event-contract-enum
	struct Event: Codable, Equatable {
			/// The identification of the event.
		public let id: String

			/// The list of value in `Flow.Argument.Event.Name` type.
		public let fields: [Name]

		public init(id: String, fields: [Flow.Argument.Event.Name]) {
			self.id = id
			self.fields = fields
		}

			/// The data structure for the `fields` in `Flow.Argument.Event`.
		public struct Name: Codable, Equatable {
			public let name: String
			public let value: Flow.Argument

			public init(name: String, value: Flow.Cadence.FValue) {
				self.name = name
				self.value = value.toArgument()
			}

			public init(name: String, value: Flow.Argument) {
				self.name = name
				self.value = value
			}
		}
	}

		/// The data structure for `.reference` argument type.
	struct Reference: Codable, Equatable {
		public let address: String
		public let type: String

		public init(address: String, type: String) {
			self.address = address
			self.type = type
		}
	}

		/// The data structure for `.dictionary` argument type.
		/// More detail can be found here:
		/// https://docs.onflow.org/cadence/json-cadence-spec/#dictionary
	struct Dictionary: Codable, Equatable {
		public let key: Flow.Argument
		public let value: Flow.Argument

		public init(key: Flow.Cadence.FValue, value: Flow.Cadence.FValue) {
			self.key = key.toArgument()
			self.value = value.toArgument()
		}

		public init(key: Flow.Argument, value: Flow.Argument) {
			self.key = key
			self.value = value
		}
	}

		/// The data structure for `.capability` argument type.
		/// More detail can be found here:
		/// https://docs.onflow.org/cadence/json-cadence-spec/#capability
	struct Capability: Codable, Equatable {
		public let path: String
		public let address: String
		public let borrowType: String

		public init(path: String, address: String, borrowType: String) {
			self.path = path
			self.address = address
			self.borrowType = borrowType
		}
	}

		/// The data structure for `.type` argument type.
		/// More detail can be found here:
		/// https://docs.onflow.org/cadence/json-cadence-spec/#type
	struct StaticType: Codable, Equatable {
		let staticType: Flow.Cadence.Kind

		public init(staticType: Flow.Cadence.Kind) {
			self.staticType = staticType
		}
	}
}
