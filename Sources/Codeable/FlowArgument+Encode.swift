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

import BigInt
import Foundation

public protocol FlowEncodable {
    func toFlowValue() -> Flow.Cadence.FValue?
}

extension Int: FlowEncodable {
    public func toFlowValue() -> Flow.Cadence.FValue? {
        return .int(self)
    }
}

extension String: FlowEncodable {
    public func toFlowValue() -> Flow.Cadence.FValue? {
        return .string(self)
    }
}

extension Bool: FlowEncodable {
    public func toFlowValue() -> Flow.Cadence.FValue? {
        return .bool(self)
    }
}

extension Double: FlowEncodable {
    public func toFlowValue() -> Flow.Cadence.FValue? {
        return .ufix64(Decimal(self))
    }
}

extension Decimal: FlowEncodable {
    public func toFlowValue() -> Flow.Cadence.FValue? {
        return .ufix64(self)
    }
}

extension Int8: FlowEncodable {
    public func toFlowValue() -> Flow.Cadence.FValue? {
        return .int8(self)
    }
}

extension UInt8: FlowEncodable {
    public func toFlowValue() -> Flow.Cadence.FValue? {
        return .uint8(self)
    }
}

extension Int16: FlowEncodable {
    public func toFlowValue() -> Flow.Cadence.FValue? {
        return .int16(self)
    }
}

extension UInt16: FlowEncodable {
    public func toFlowValue() -> Flow.Cadence.FValue? {
        return .uint16(self)
    }
}

extension Int32: FlowEncodable {
    public func toFlowValue() -> Flow.Cadence.FValue? {
        return .int32(self)
    }
}

extension UInt32: FlowEncodable {
    public func toFlowValue() -> Flow.Cadence.FValue? {
        return .uint32(self)
    }
}

extension Int64: FlowEncodable {
    public func toFlowValue() -> Flow.Cadence.FValue? {
        return .int64(self)
    }
}

extension UInt64: FlowEncodable {
    public func toFlowValue() -> Flow.Cadence.FValue? {
        return .uint64(self)
    }
}

extension BigInt: FlowEncodable {
    public func toFlowValue() -> Flow.Cadence.FValue? {
        return .int128(self)
    }
}

extension BigUInt: FlowEncodable {
    public func toFlowValue() -> Flow.Cadence.FValue? {
        return .uint128(self)
    }
}

extension Array: FlowEncodable where Element: FlowEncodable {
    public func toFlowValue() -> Flow.Cadence.FValue? {
        let arguments = compactMap { $0.toFlowValue() }
        return .array(arguments)
    }
}

extension Optional: FlowEncodable where Wrapped: FlowEncodable {
    public func toFlowValue() -> Flow.Cadence.FValue? {
        switch self {
        case .none:
            return .optional(nil)
        case .some(let value):
            return .optional(value.toFlowValue())
        }
    }
}

extension Dictionary: FlowEncodable where Key: FlowEncodable, Value: FlowEncodable {
    public func toFlowValue() -> Flow.Cadence.FValue? {
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
    public func toFlowValue() -> Flow.Cadence.FValue? {
        return .address(self)
    }
}
