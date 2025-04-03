//
//  File.swift
//  Flow
//
//  Created by Hao Fu on 4/4/2025.
//

import Foundation
import BigInt

/// A protocol for types that can be converted to a target type
protocol Convertible {
    var asInt: Int? { get }
    var asInt64: Int64? { get }
    var asBigInt: BigInt? { get }
    var asString: String { get }
}

// MARK: - Default implementations
extension Convertible {
    var asString: String { String(describing: self) }
    
    func convert<T>(to type: T.Type) -> T? {
        switch type {
        case is Int.Type: return asInt as? T
        case is Int64.Type: return asInt64 as? T
        case is BigInt.Type: return asBigInt as? T
        case is String.Type: return asString as? T
        default: return nil
        }
    }
}

// MARK: - Type Conversions
extension String: Convertible {
    var asInt: Int? { Int(self) }
    var asInt64: Int64? { Int64(self) }
    var asBigInt: BigInt? { BigInt(self) }
}

extension Int: Convertible {
    var asInt: Int? { self }
    var asInt64: Int64? { Int64(self) }
    var asBigInt: BigInt? { BigInt(self) }
}

extension Int64: Convertible {
    var asInt: Int? { 
        (self >= Int64(Int.min) && self <= Int64(Int.max)) ? Int(self) : nil 
    }
    var asInt64: Int64? { self }
    var asBigInt: BigInt? { BigInt(self) }
}

extension BigInt: Convertible {
    var asInt: Int? { 
        (self >= BigInt(Int.min) && self <= BigInt(Int.max)) ? Int(self) : nil 
    }
    var asInt64: Int64? { 
        (self >= BigInt(Int64.min) && self <= BigInt(Int64.max)) ? Int64(self) : nil 
    }
    var asBigInt: BigInt? { self }
}

// MARK: - Flexible Decoding
extension KeyedDecodingContainer {
    /// Decode a value that could be of multiple types and convert it to the target type
    /// - Parameters:
    ///   - types: Array of possible source types to try decoding
    ///   - as: The desired final type
    ///   - key: The coding key to decode
    /// - Returns: The decoded and converted value
    /// - Throws: DecodingError if value cannot be decoded or converted
    func decodeFlexible<T>(_ types: [Decodable.Type], as: T.Type, forKey key: Key) throws -> T {
        for type in types {
            if let _ = type as? Convertible.Type,
               let value = try? decode(type, forKey: key) as? Convertible,
               let converted = value.convert(to: T.self) {
                return converted
            }
        }
        
        throw DecodingError.dataCorruptedError(
            forKey: key,
            in: self,
            debugDescription: "Could not decode key '\(key.stringValue)' as any of: \(types)"
        )
    }
}
