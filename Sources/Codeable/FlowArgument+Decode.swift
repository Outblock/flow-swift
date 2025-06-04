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

protocol FlowDecodable {
    func decode() -> Any?

    func decode<T: Decodable>(_ decodable: T.Type) throws -> T

    func decode<T: Decodable>() throws -> T
}

extension Flow.Argument: FlowDecodable {
    public func decode<T: Decodable>() throws -> T {
        guard let value = decode() else {
            throw Flow.FError.decodeFailure
        }

        if let some = value as? T {
            return some
        }

        guard JSONSerialization.isValidJSONObject(value) else {
            throw Flow.FError.decodeFailure
        }

        do {
            let data = try JSONSerialization.data(withJSONObject: value, options: [.fragmentsAllowed, .sortedKeys])
            let model = try JSONDecoder().decode(T.self, from: data)
            return model
        } catch {
            throw error
        }
    }

    public func decode<T: Decodable>(_: T.Type) throws -> T {
        do {
            let result: T = try decode()
            return result
        } catch {
            throw error
        }
    }

    public func decode() -> Any? {
        switch type {
        case .int:
            return value.toInt()
        case .address:
            return value.toAddress()?.hex.addHexPrefix()
        case .struct:
            guard let event = value.toStruct() else {
                return nil
            }
            return eventToDict(result: event)
        case .event:
            guard let event = value.toEvent() else {
                return nil
            }
            return eventToDict(result: event)
        case .ufix64:
            return value.toUFix64()
        case .int128:
            return value.toInt128()
        case .array:
            let args = value.toArray()?.map { arg in
                arg.toArgument().decode()
            }
            return args
        case .bool:
            return value.toBool()
        case .void:
            return nil
        case .optional:
            return value.toOptional()?.toArgument().decode()
        case .string:
            return value.toString()
        case .uint:
            return value.toUInt()
        case .int8:
            return value.toInt8()
        case .uint8:
            return value.toUInt8()
        case .int16:
            return value.toInt16()
        case .uint16:
            return value.toUInt16()
        case .int32:
            return value.toInt32()
        case .uint32:
            return value.toUInt32()
        case .int64:
            return value.toInt64()
        case .uint64:
            return value.toUInt64()
        case .uint128:
            return value.toUInt128()
        case .int256:
            return value.toInt256()
        case .uint256:
            return value.toUInt256()
        case .word8:
            return value.toWord8()
        case .word16:
            return value.toWord16()
        case .word32:
            return value.toWord32()
        case .word64:
            return value.toWord64()
        case .fix64:
            return value.toFix64()
        case .dictionary:
            guard let result = value.toDictionary() else {
                return nil
            }
            
            if result.isEmpty {
                return [String: Any]()
            }
            
            switch result.first?.key.type {
            case .int:
                return result.decode(Int.self)
            case .uint:
                return result.decode(UInt.self)
            case .ufix64:
                return result.decode(Decimal.self)
            case .int128:
                return result.decode(BigInt.self)
            case .bool:
                return result.decode(Bool.self)
            case .string:
                return result.decode(String.self)
            case .address:
                return result.decode(String.self)
            case .int8:
                return result.decode(Int8.self)
            case .uint8:
                return result.decode(UInt8.self)
            case .int16:
                return result.decode(Int16.self)
            case .uint16:
                return result.decode(UInt16.self)
            case .int32:
                return result.decode(Int16.self)
            case .uint32:
                return result.decode(UInt32.self)
            case .int64:
                return result.decode(Int64.self)
            case .uint64:
                return result.decode(UInt64.self)
            case .uint128:
                return result.decode(BigUInt.self)
            case .int256:
                return result.decode(BigInt.self)
            case .uint256:
                return result.decode(BigUInt.self)
            case .word8:
                return result.decode(UInt8.self)
            case .word16:
                return result.decode(UInt16.self)
            case .word32:
                return result.decode(UInt32.self)
            case .word64:
                return result.decode(UInt64.self)
            case .fix64:
                return result.decode(Decimal.self)
            default:
                return nil
            }

        case .path:
            guard let result = value.toPath() else {
                return nil
            }
            return modelToDict(result: result)
        case .resource:
            guard let result = value.toResource() else {
                return nil
            }
            return eventToDict(result: result)
        case .character:
            return value.toCharacter()
        case .reference:
            guard let result = value.toReference() else {
                return nil
            }
            return modelToDict(result: result)
        case .capability:
            guard let result = value.toCapability() else {
                return nil
            }
            return modelToDict(result: result)
        case .type:
            guard let result = value.toType() else {
                return nil
            }
            return modelToDict(result: result)
        case .contract:
            guard let result = value.toContract() else {
                return nil
            }
            return eventToDict(result: result)
        case .enum:
            guard let result = value.toEnum() else {
                return nil
            }
            return eventToDict(result: result)
        case .undefined:
            return nil
        }
    }

    private func eventToDict(result: Event) -> [String: Any?] {
        return result.fields.reduce(into: [String: Any?]()) {
            $0[$1.name] = $1.value.decode()
        }
    }

    private func modelToDict<T: Encodable>(result: T) -> [String: Any]? {
        guard let data = try? flow.encoder.encode(result),
              let model = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
        else {
            return nil
        }
        return model
    }
}

extension Array where Element == Flow.Argument.Dictionary {
    func decode<T: Hashable>(_: T.Type) -> [T: Any?] {
        let reducedResult = reduce(into: [T: Any?]()) {
            if let key = $1.key.decode() as? T {
                $0[key] = $1.value.decode()
            }
        }
        return reducedResult
    }
}
