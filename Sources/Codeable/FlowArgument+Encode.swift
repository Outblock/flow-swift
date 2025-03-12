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
    func toFlowArgument() -> Flow.Argument?
}

extension Int: FlowEncodable {
    public func toFlowArgument() -> Flow.Argument? {
        return .init(type: .int, value: .int(self))
    }
}

extension String: FlowEncodable {
    public func toFlowArgument() -> Flow.Argument? {
        return .init(type: .string, value: .string(self))
    }
}

extension Bool: FlowEncodable {
    public func toFlowArgument() -> Flow.Argument? {
        return .init(type: .bool, value: .bool(self))
    }
}

extension Double: FlowEncodable {
    public func toFlowArgument() -> Flow.Argument? {
        return .init(type: .ufix64, value: .ufix64(Decimal(self)))
    }
}

extension Decimal: FlowEncodable {
    public func toFlowArgument() -> Flow.Argument? {
        return .init(type: .ufix64, value: .ufix64(self))
    }
}

extension Int8: FlowEncodable {
    public func toFlowArgument() -> Flow.Argument? {
        return .init(type: .int8, value: .int8(self))
    }
}

extension UInt8: FlowEncodable {
    public func toFlowArgument() -> Flow.Argument? {
        return .init(type: .uint8, value: .uint8(self))
    }
}

extension Int16: FlowEncodable {
    public func toFlowArgument() -> Flow.Argument? {
        return .init(type: .int16, value: .int16(self))
    }
}

extension UInt16: FlowEncodable {
    public func toFlowArgument() -> Flow.Argument? {
        return .init(type: .uint16, value: .uint16(self))
    }
}

extension Int32: FlowEncodable {
    public func toFlowArgument() -> Flow.Argument? {
        return .init(type: .int32, value: .int32(self))
    }
}

extension UInt32: FlowEncodable {
    public func toFlowArgument() -> Flow.Argument? {
        return .init(type: .uint32, value: .uint32(self))
    }
}

extension Int64: FlowEncodable {
    public func toFlowArgument() -> Flow.Argument? {
        return .init(type: .int64, value: .int64(self))
    }
}

extension UInt64: FlowEncodable {
    public func toFlowArgument() -> Flow.Argument? {
        return .init(type: .uint64, value: .uint64(self))
    }
}

extension BigInt: FlowEncodable {
    public func toFlowArgument() -> Flow.Argument? {
        return .init(type: .int128, value: .int128(self))
    }
}

extension BigUInt: FlowEncodable {
    public func toFlowArgument() -> Flow.Argument? {
        return .init(type: .uint128, value: .uint128(self))
    }
}

extension Array: FlowEncodable where Element: FlowEncodable {
    public func toFlowArgument() -> Flow.Argument? {
        let arguments = compactMap { $0.toFlowArgument() }
        return .init(type: .array, value: .array(arguments.toValue()))
    }
}

extension Optional: FlowEncodable where Wrapped: FlowEncodable {
    public func toFlowArgument() -> Flow.Argument? {
        switch self {
        case .none:
            return .init(type: .optional, value: .optional(nil))
        case .some(let value):
            return .init(type: .optional, value: .optional(value.toFlowArgument()?.value))
        }
    }
}

extension Dictionary: FlowEncodable where Key: FlowEncodable, Value: FlowEncodable {
    public func toFlowArgument() -> Flow.Argument? {
        let entries = compactMap { key, value -> Flow.Argument.Dictionary? in
            guard let keyArg = key.toFlowArgument(),
                  let valueArg = value.toFlowArgument() else {
                return nil
            }
            return Flow.Argument.Dictionary(key: keyArg.value, value: valueArg.value)
        }
        return .init(type: .dictionary, value: .dictionary(entries))
    }
}
