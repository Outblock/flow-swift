//
//  File.swift
//
//
//  Created by lmcmz on 5/9/21.
//

import BigInt
import Foundation

extension Flow {
    struct Argument: Codable, Equatable {
        let type: Cadence.FType
        let value: Flow.Cadence.ValueType

        enum CodingKeys: String, CodingKey {
            case type
            case value
        }

        var jsonString: Data? {
            let encoder = JSONEncoder()
            guard let jsonData = try? encoder.encode(self) else {
                return nil
            }
            return jsonData
        }

        init(type: Cadence.FType, value: Flow.Cadence.ValueType) {
            self.type = type
            self.value = value
        }

        init(value: Flow.Cadence.ValueType) {
            type = value.type
            self.value = value
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            type = try container.decode(Cadence.FType.self, forKey: .type)

            switch type {
            case .int:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = Int(unwarpRawValue) else { value = .error; return }
                value = .int(value: realValue)
            case .uint:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = UInt(unwarpRawValue) else { value = .error; return }
                value = .uint(value: realValue)
            case .int8:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = Int8(unwarpRawValue) else { value = .error; return }
                value = .int8(value: realValue)
            case .uint8:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = UInt8(unwarpRawValue) else { value = .error; return }
                value = .uint8(value: realValue)
            case .int16:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = Int16(unwarpRawValue) else { value = .error; return }
                value = .int16(value: realValue)
            case .uint16:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = UInt16(unwarpRawValue) else { value = .error; return }
                value = .uint16(value: realValue)
            case .int32:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = Int32(unwarpRawValue) else { value = .error; return }
                value = .int32(value: realValue)
            case .uint32:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = UInt32(unwarpRawValue) else { value = .error; return }
                value = .uint32(value: realValue)
            case .int64:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = Int64(unwarpRawValue) else { value = .error; return }
                value = .int64(value: realValue)
            case .uint64:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = UInt64(unwarpRawValue) else { value = .error; return }
                value = .uint64(value: realValue)
            case .int128:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = BigInt(unwarpRawValue) else { value = .error; return }
                value = .int128(value: realValue)
            case .uint128:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = BigUInt(unwarpRawValue) else { value = .error; return }
                value = .uint128(value: realValue)
            case .int256:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = BigInt(unwarpRawValue) else { value = .error; return }
                value = .int256(value: realValue)
            case .uint256:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = BigUInt(unwarpRawValue) else { value = .error; return }
                value = .uint256(value: realValue)
            case .word8:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = UInt8(unwarpRawValue) else { value = .error; return }
                value = .word8(value: realValue)
            case .word16:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = UInt16(unwarpRawValue) else { value = .error; return }
                value = .word16(value: realValue)
            case .word32:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = UInt32(unwarpRawValue) else { value = .error; return }
                value = .word32(value: realValue)
            case .word64:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = UInt64(unwarpRawValue) else { value = .error; return }
                value = .word64(value: realValue)
            case .fix64:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = Double(unwarpRawValue) else { value = .error; return }
                value = .fix64(value: realValue)
            case .ufix64:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = Double(unwarpRawValue) else { value = .error; return }
                value = .ufix64(value: realValue)
            case .string:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                value = .string(value: unwarpRawValue)
            case .bool:
                let rawValue = try? container.decode(Bool.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                value = .bool(value: unwarpRawValue)
            case .optional:
                let rawValue = try? container.decode(Argument.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                value = .optional(value: unwarpRawValue)
            case .address:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                value = .address(value: Flow.Address(hex: unwarpRawValue))
            case .path:
                let rawValue = try? container.decode(Path.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                value = .path(value: unwarpRawValue)
            case .event:
                let rawValue = try? container.decode(Event.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                value = .event(value: unwarpRawValue)
            case .array:
                let rawValue = try? container.decode([Flow.Argument].self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                value = .array(value: unwarpRawValue)
            case .character:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                value = .character(value: unwarpRawValue)
            case .reference:
                let rawValue = try? container.decode(Reference.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                value = .reference(value: unwarpRawValue)
            case .struct:
                let rawValue = try? container.decode(Event.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                value = .struct(value: unwarpRawValue)
            case .resource:
                let rawValue = try? container.decode(Event.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                value = .resource(value: unwarpRawValue)
            case .dictionary:
                let rawValue = try? container.decode([Flow.Argument.Dictionary].self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                value = .dictionary(value: unwarpRawValue)
            case .void:
                value = .void
            case .undefined:
                value = .unsupported
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)
            try container.encode(value, forKey: .value)
        }
    }
}

extension Flow.Argument {
    struct Path: Codable, Equatable {
        let domain: String
        let identifier: String
    }

    struct Event: Codable, Equatable {
        let id: String
        let fields: [EventName]
    }

    struct EventName: Codable, Equatable {
        let name: String
        let value: Flow.Argument
    }

    struct Reference: Codable, Equatable {
        let address: String
        let type: String
    }

    struct Dictionary: Codable, Equatable {
        let key: Flow.Argument
        let value: Flow.Argument
    }
}
