//
//  File.swift
//
//
//  Created by lmcmz on 11/9/21.
//

import BigInt
import Foundation

extension Flow {
    public class Cadence {}
}

extension Flow.Cadence {
    public enum FType: String, Codable, Equatable, CaseIterable {
        case void = "Void"
        case optional = "Optional"
        case bool = "Bool"
        case string = "String"
        case int = "Int"
        case uint = "UInt"
        case int8 = "Int8"
        case uint8 = "UInt8"
        case int16 = "Int16"
        case uint16 = "UInt16"
        case int32 = "Int32"
        case uint32 = "UInt32"
        case int64 = "Int64"
        case uint64 = "UInt64"
        case int128 = "Int128"
        case uint128 = "UInt128"
        case int256 = "Int256"
        case uint256 = "UInt256"
        case word8 = "Word8"
        case word16 = "Word16"
        case word32 = "Word32"
        case word64 = "Word64"
        case fix64 = "Fix64"
        case ufix64 = "UFix64"
        case array = "Array"
        case dictionary = "Dictionary"
        case address = "Address"
        case path = "Path"
        case `struct` = "Struct"
        case resource = "Resource"
        case event = "Event"
        case character = "Character"
        case reference = "Reference"
        case capability = "Capability"
        case type = "Type"
        case contract = "Contract"
        case `enum` = "Enum"
        case undefined

        public init(rawValue: String) {
            if let type = FType.allCases.first(where: { $0.rawValue.lowercased() == rawValue.lowercased() }) {
                self = type
            } else {
                self = .undefined
            }
        }
    }

    public enum FValue: Encodable, Equatable {
        case void
        indirect case optional(value: Flow.Argument)
        case bool(Bool)
        case string(String)
        case character(String)

        case int(Int)
        case uint(UInt)
        case int8(Int8)
        case uint8(UInt8)
        case int16(Int16)
        case uint16(UInt16)
        case int32(Int32)
        case uint32(UInt32)
        case int64(Int64)
        case uint64(UInt64)
        case int128(BigInt)
        case uint128(BigUInt)
        case int256(BigInt)
        case uint256(BigUInt)

        // TODO: Need to check for overflow and underflow
        case word8(UInt8)
        case word16(UInt16)
        case word32(UInt32)
        case word64(UInt64)

        case fix64(Double)
        case ufix64(Double) // Need to check

        case address(Flow.Address)
        case path(Flow.Argument.Path)
        case reference(Flow.Argument.Reference)
        case capability(Flow.Argument.Capability)
        case `type`(Flow.Argument.StaticType)

        indirect case array([Flow.Argument])
        indirect case dictionary([Flow.Argument.Dictionary])
        indirect case `struct`(Flow.Argument.Event)
        indirect case resource(Flow.Argument.Event)
        indirect case event(Flow.Argument.Event)
        indirect case contract(Flow.Argument.Event)
        indirect case `enum`(Flow.Argument.Event)

        case unsupported
        case error

        var type: FType {
            switch self {
            case .address:
                return .address
            case .array:
                return .array
            case .optional:
                return .optional
            case .bool:
                return .bool
            case .string:
                return .string
            case .character:
                return .character
            case .int:
                return .int
            case .uint:
                return .uint
            case .int8:
                return .int8
            case .uint8:
                return .uint8
            case .int16:
                return .int16
            case .uint16:
                return .uint16
            case .int32:
                return .int32
            case .uint32:
                return .uint32
            case .int64:
                return .int64
            case .uint64:
                return .uint64
            case .int128:
                return .int128
            case .uint128:
                return .uint128
            case .int256:
                return .int256
            case .uint256:
                return .uint256
            case .word8:
                return .word8
            case .word16:
                return .word16
            case .word32:
                return .word32
            case .word64:
                return .word64
            case .fix64:
                return .fix64
            case .ufix64:
                return .ufix64
            case .path:
                return .path
            case .reference:
                return .reference
            case .event:
                return .event
            case .dictionary:
                return .dictionary
            case .struct:
                return .struct
            case .resource:
                return .resource
            case .void:
                return .void
            case .unsupported, .error:
                return .undefined
            case .capability:
                return .capability
            case .type:
                return .type
            case .contract:
                return .contract
            case .enum:
                return .enum
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case let .int(value):
                try container.encode(String(value))
            case let .uint(value):
                try container.encode(String(value))
            case let .int8(value):
                try container.encode(String(value))
            case let .uint8(value):
                try container.encode(String(value))
            case let .int16(value):
                try container.encode(String(value))
            case let .uint16(value):
                try container.encode(String(value))
            case let .int32(value):
                try container.encode(String(value))
            case let .uint32(value):
                try container.encode(String(value))
            case let .int64(value):
                try container.encode(String(value))
            case let .uint64(value):
                try container.encode(String(value))
            case let .int128(value):
                try container.encode(String(value))
            case let .uint128(value):
                try container.encode(String(value))
            case let .int256(value):
                try container.encode(String(value))
            case let .uint256(value):
                try container.encode(String(value))
            case let .word8(value):
                try container.encode(String(value))
            case let .word16(value):
                try container.encode(String(value))
            case let .word32(value):
                try container.encode(String(value))
            case let .word64(value):
                try container.encode(String(value))
            case let .string(value):
                try container.encode(value)
            case let .array(value):
                try container.encode(value)
            case let .dictionary(value):
                try container.encode(value)
            case let .reference(value):
                try container.encode(value)
            case let .optional(value):
                try container.encode(value)
            case let .character(value):
                try container.encode(value)
            case let .struct(value),
                 let .event(value),
                 let .resource(value):
                try container.encode(value)
            case let .bool(value):
                try container.encode(value)
            case let .fix64(value):
                try container.encode(String(value))
            case let .ufix64(value):
                try container.encode(String(value))
            case let .address(value):
                try container.encode(value)
            case let .path(value):
                try container.encode(value)
            case .void:
                try container.encodeNil()
            case let .capability(value):
                try container.encode(value)
            case let .type(value):
                try container.encode(value)
            case let .contract(value):
                try container.encode(value)
            case let .enum(value):
                try container.encode(value)
            case .unsupported,
                 .error:
                return
            }
        }

        public static func == (lhs: Flow.Cadence.FValue, rhs: Flow.Cadence.FValue) -> Bool {
            switch (lhs, rhs) {
            case let (.int(lhsValue), .int(rhsValue)):
                return lhsValue == rhsValue
            case let (.uint(lhsValue), .uint(rhsValue)):
                return lhsValue == rhsValue
            case let (.int8(lhsValue), .int8(rhsValue)):
                return lhsValue == rhsValue
            case let (.uint8(lhsValue), .uint8(rhsValue)):
                return lhsValue == rhsValue
            case let (.int16(lhsValue), .int16(rhsValue)):
                return lhsValue == rhsValue
            case let (.uint16(lhsValue), .uint16(rhsValue)):
                return lhsValue == rhsValue
            case let (.int32(lhsValue), .int32(rhsValue)):
                return lhsValue == rhsValue
            case let (.uint32(lhsValue), .uint32(rhsValue)):
                return lhsValue == rhsValue
            case let (.int64(lhsValue), .int64(rhsValue)):
                return lhsValue == rhsValue
            case let (.uint64(lhsValue), .uint64(rhsValue)):
                return lhsValue == rhsValue
            case let (.int128(lhsValue), .int128(rhsValue)):
                return lhsValue == rhsValue
            case let (.uint128(lhsValue), .uint128(rhsValue)):
                return lhsValue == rhsValue
            case let (.int256(lhsValue), .int256(rhsValue)):
                return lhsValue == rhsValue
            case let (.uint256(lhsValue), .uint256(rhsValue)):
                return lhsValue == rhsValue
            case let (.word8(lhsValue), .word8(rhsValue)):
                return lhsValue == rhsValue
            case let (.word16(lhsValue), .word16(rhsValue)):
                return lhsValue == rhsValue
            case let (.word32(lhsValue), .word32(rhsValue)):
                return lhsValue == rhsValue
            case let (.word64(lhsValue), .word64(rhsValue)):
                return lhsValue == rhsValue
            case let (.fix64(lhsValue), .fix64(rhsValue)):
                return lhsValue == rhsValue
            case let (.ufix64(lhsValue), .ufix64(rhsValue)):
                return lhsValue == rhsValue
            case let (.string(lhsValue), .string(rhsValue)):
                return lhsValue == rhsValue
            case let (.address(lhsValue), .address(rhsValue)):
                return lhsValue == rhsValue
            case let (.optional(lhsValue), .optional(rhsValue)):
                return lhsValue == rhsValue
            case let (.event(lhsValue), .event(rhsValue)):
                return lhsValue == rhsValue
            case let (.path(lhsValue), .path(rhsValue)):
                return lhsValue == rhsValue
            case let (.reference(lhsValue), .reference(rhsValue)):
                return lhsValue == rhsValue
            case let (.array(lhsValue), .array(rhsValue)):
                return lhsValue == rhsValue
            case let (.dictionary(lhsValue), .dictionary(rhsValue)):
                return lhsValue == rhsValue
            case let (.struct(lhsValue), .struct(rhsValue)):
                return lhsValue == rhsValue
            case let (.resource(lhsValue), .resource(rhsValue)):
                return lhsValue == rhsValue
            case let (.character(lhsValue), .character(rhsValue)):
                return lhsValue == rhsValue
            case let (.bool(lhsValue), .bool(rhsValue)):
                return lhsValue == rhsValue
            case let (.type(lhsValue), .type(rhsValue)):
                return lhsValue == rhsValue
            case let (.contract(lhsValue), .contract(rhsValue)):
                return lhsValue == rhsValue
            case let (.enum(lhsValue), .enum(rhsValue)):
                return lhsValue == rhsValue
            case let (.capability(lhsValue), .capability(rhsValue)):
                return lhsValue == rhsValue
            case (.void, .void):
                return true
            case (.error, .error):
                return true
            case (.unsupported, .unsupported):
                return true
            default:
                return false
            }
        }

        func toArgument() -> Flow.Argument {
            return .init(value: self)
        }
    }
}

extension Flow.Cadence.FValue {
    func toInt() -> Int? {
        if case let .int(value) = self {
            return value
        }
        return nil
    }

    func toUInt() -> UInt? {
        if case let .uint(value) = self {
            return value
        }
        return nil
    }

    func toInt8() -> Int8? {
        if case let .int8(value) = self {
            return value
        }
        return nil
    }

    func toUInt8() -> UInt8? {
        if case let .uint8(value) = self {
            return value
        }
        return nil
    }

    func toInt16() -> Int16? {
        if case let .int16(value) = self {
            return value
        }
        return nil
    }

    func toUInt16() -> UInt16? {
        if case let .uint16(value) = self {
            return value
        }
        return nil
    }

    func toInt32() -> Int32? {
        if case let .int32(value) = self {
            return value
        }
        return nil
    }

    func toUInt32() -> UInt32? {
        if case let .uint32(value) = self {
            return value
        }
        return nil
    }

    func toInt64() -> Int64? {
        if case let .int64(value) = self {
            return value
        }
        return nil
    }

    func toUInt64() -> UInt64? {
        if case let .uint64(value) = self {
            return value
        }
        return nil
    }

    func toInt128() -> BigInt? {
        if case let .int128(value) = self {
            return value
        }
        return nil
    }

    func toUInt128() -> BigUInt? {
        if case let .uint128(value) = self {
            return value
        }
        return nil
    }

    func toInt256() -> BigInt? {
        if case let .int256(value) = self {
            return value
        }
        return nil
    }

    func toUInt256() -> BigUInt? {
        if case let .uint256(value) = self {
            return value
        }
        return nil
    }

    func toWord8() -> UInt8? {
        if case let .word8(value) = self {
            return value
        }
        return nil
    }

    func toWord16() -> UInt16? {
        if case let .word16(value) = self {
            return value
        }
        return nil
    }

    func toWord32() -> UInt32? {
        if case let .word32(value) = self {
            return value
        }
        return nil
    }

    func toWord64() -> UInt64? {
        if case let .word64(value) = self {
            return value
        }
        return nil
    }

    func toFix64() -> Double? {
        if case let .fix64(value) = self {
            return value
        }
        return nil
    }

    func toUFix64() -> Double? {
        if case let .ufix64(value) = self {
            return value
        }
        return nil
    }

    func toOptional() -> Flow.Argument? {
        if case let .optional(value) = self {
            return value
        }
        return nil
    }

    func toBool() -> Bool? {
        if case let .bool(value) = self {
            return value
        }
        return nil
    }

    func toString() -> String? {
        if case let .string(value) = self {
            return value
        }
        return nil
    }

    func toCharacter() -> String? {
        if case let .character(value) = self {
            return value
        }
        return nil
    }

    func toAddress() -> Flow.Address? {
        if case let .address(value) = self {
            return value
        }
        return nil
    }

    func toPath() -> Flow.Argument.Path? {
        if case let .path(value) = self {
            return value
        }
        return nil
    }

    func toReference() -> Flow.Argument.Reference? {
        if case let .reference(value) = self {
            return value
        }
        return nil
    }

    func toArray() -> [Flow.Argument]? {
        if case let .array(value) = self {
            return value
        }
        return nil
    }

    func toDictionary() -> [Flow.Argument.Dictionary]? {
        if case let .dictionary(value) = self {
            return value
        }
        return nil
    }

    func toStruct() -> Flow.Argument.Event? {
        if case let .struct(value) = self {
            return value
        }
        return nil
    }

    func toResource() -> Flow.Argument.Event? {
        if case let .resource(value) = self {
            return value
        }
        return nil
    }

    func toEvent() -> Flow.Argument.Event? {
        if case let .event(value) = self {
            return value
        }
        return nil
    }

    func toEnum() -> Flow.Argument.Event? {
        if case let .enum(value) = self {
            return value
        }
        return nil
    }

    func toContract() -> Flow.Argument.Event? {
        if case let .contract(value) = self {
            return value
        }
        return nil
    }

    func toType() -> Flow.Argument.StaticType? {
        if case let .type(value) = self {
            return value
        }
        return nil
    }

    func toCapability() -> Flow.Argument.Capability? {
        if case let .capability(value) = self {
            return value
        }
        return nil
    }
}
