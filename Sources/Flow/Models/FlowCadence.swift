//
//  File.swift
//
//
//  Created by lmcmz on 11/9/21.
//

import BigInt
import Foundation

extension Flow {
    class Cadence {}
}

extension Flow.Cadence {
    enum FType: String, Codable, Equatable {
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
        case capability = "Capability"
        case `struct` = "Struct"
        case resource = "Resource"
        case event = "Event"
        case contract = "Contract"
        case `enum` = "Enum"
    }

    enum ValueType: Equatable {
        case void(value: Never)
        indirect case optional(value: Flow.Argument)
        case bool(value: Bool)
        case string(value: String)
        case int(value: Int)
        case uint(value: UInt)
        case int8(value: Int8)
        case uint8(value: UInt8)
        case int16(value: Int16)
        case uint16(value: UInt16)
        case int32(value: Int32)
        case uint32(value: UInt32)
        case int64(value: Int64)
        case uint64(value: UInt64)
        case int128(value: BigInt)
        case uint128(value: BigUInt)
        case int256(value: BigInt)
        case uint256(value: BigUInt)

        // TODO: Need to check for overflow and underflow
        case word8(value: UInt8)
        case word16(value: UInt16)
        case word32(value: UInt32)
        case word64(value: UInt64)

        case fix64(value: Double)
        case ufix64(value: Double) // Need to check

        indirect case array(type: Flow.Cadence.Type, value: ValueType)
//        case dictionary = "Dictionary"

        case address(value: String)
        case path(value: Flow.Argument.Path)
//        case capability = "Capability"
//        case `struct` = "Struct"
//        case resource = "Resource"
        indirect case event(value: Flow.Argument.Event)
//        case contract = "Contract"
//        case `enum` = "Enum"
        case unsupported

        static func == (lhs: Flow.Cadence.ValueType, rhs: Flow.Cadence.ValueType) -> Bool {
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
            default:
                return false
            }
        }
    }
}
