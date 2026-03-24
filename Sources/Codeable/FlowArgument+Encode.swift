	//
	//  FlowArgument-Encode.swift
	//
	//  CadenceTypeTest
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
	//

import BigInt
import Foundation

protocol FlowEncodable {
	func toFlowValue() -> Flow.Cadence.FValue?
}

extension Int: FlowEncodable {
	func toFlowValue() -> Flow.Cadence.FValue? {
		.int(self)
	}
}

extension String: FlowEncodable {
	func toFlowValue() -> Flow.Cadence.FValue? {
		.string(self)
	}
}

extension Bool: FlowEncodable {
	func toFlowValue() -> Flow.Cadence.FValue? {
		.bool(self)
	}
}

extension Double: FlowEncodable {
	func toFlowValue() -> Flow.Cadence.FValue? {
		.ufix64(Decimal(self))
	}
}

extension Decimal: FlowEncodable {
	func toFlowValue() -> Flow.Cadence.FValue? {
		.ufix64(self)
	}
}

extension Int8: FlowEncodable {
	func toFlowValue() -> Flow.Cadence.FValue? {
		.int8(self)
	}
}

extension UInt8: FlowEncodable {
	func toFlowValue() -> Flow.Cadence.FValue? {
		.uint8(self)
	}
}

extension Int16: FlowEncodable {
	func toFlowValue() -> Flow.Cadence.FValue? {
		.int16(self)
	}
}

extension UInt16: FlowEncodable {
	func toFlowValue() -> Flow.Cadence.FValue? {
		.uint16(self)
	}
}

extension Int32: FlowEncodable {
	func toFlowValue() -> Flow.Cadence.FValue? {
		.int32(self)
	}
}

extension UInt32: FlowEncodable {
	func toFlowValue() -> Flow.Cadence.FValue? {
		.uint32(self)
	}
}

extension Int64: FlowEncodable {
	func toFlowValue() -> Flow.Cadence.FValue? {
		.int64(self)
	}
}

extension UInt64: FlowEncodable {
	func toFlowValue() -> Flow.Cadence.FValue? {
		.uint64(self)
	}
}

extension BigInt: FlowEncodable {
	func toFlowValue() -> Flow.Cadence.FValue? {
		.int128(self)
	}
}

extension BigUInt: FlowEncodable {
	func toFlowValue() -> Flow.Cadence.FValue? {
		.uint128(self)
	}
}

extension Array: FlowEncodable where Element: FlowEncodable {
	func toFlowValue() -> Flow.Cadence.FValue? {
		let arguments = compactMap { $0.toFlowValue() }
		return .array(arguments)
	}
}

extension Optional: FlowEncodable where Wrapped: FlowEncodable {
	func toFlowValue() -> Flow.Cadence.FValue? {
		switch self {
			case .none:
				return .optional(nil)
			case let .some(value):
				return .optional(value.toFlowValue())
		}
	}
}

extension Dictionary: FlowEncodable where Key: FlowEncodable, Value: FlowEncodable {
	func toFlowValue() -> Flow.Cadence.FValue? {
		let entries = compactMap { key, value -> Flow.Argument.Dictionary? in
			guard let keyArg = key.toFlowValue(),
				  let valueArg = value.toFlowValue() else {
				return nil
			}
			return Flow.Argument.Dictionary(key: keyArg, value: valueArg)
		}

		return .dictionary(entries)
	}
}

extension Flow.Address: FlowEncodable {
	func toFlowValue() -> Flow.Cadence.FValue? {
		.address(self)
	}
}

