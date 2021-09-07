//
//  File.swift
//
//
//  Created by lmcmz on 5/9/21.
//

import Foundation

extension Flow {
    struct Argument: Codable {
        var type: CadenceType
        var rawValue: String

        enum CodingKeys: String, CodingKey {
            case type
            case rawValue = "value"
        }

        var value: Any? {
            switch type {
            case .int:
                return Int(rawValue)
            default:
                return nil
            }
        }
    }

    enum CadenceType: String, Codable {
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
}
