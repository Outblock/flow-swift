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

        init(type: Cadence.FType, value: Flow.Cadence.ValueType) {
            self.type = type
            self.value = value
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            type = try container.decode(Cadence.FType.self, forKey: .type)

            switch type {
            case .int:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .unsupported; return }
                guard let realValue = Int(unwarpRawValue) else { value = .unsupported; return }
                value = .int(value: realValue)
            case .string:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .unsupported; return }
                value = .string(value: unwarpRawValue)
            case .bool:
                let rawValue = try? container.decode(Bool.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .unsupported; return }
                value = .bool(value: unwarpRawValue)
            case .optional:
                let rawValue = try? container.decode(Argument.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .unsupported; return }
                value = .optional(value: unwarpRawValue)
            case .uint64:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .unsupported; return }
                guard let realValue = UInt64(unwarpRawValue) else { value = .unsupported; return }
                value = .uint64(value: realValue)
            case .ufix64:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .unsupported; return }
                guard let realValue = Double(unwarpRawValue) else { value = .unsupported; return }
                value = .ufix64(value: realValue)
            case .address:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .unsupported; return }
                value = .address(value: unwarpRawValue)
            case .path:
                let rawValue = try? container.decode(Path.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .unsupported; return }
                value = .path(value: unwarpRawValue)
            case .event:
                let rawValue = try? container.decode(Event.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .unsupported; return }
                value = .event(value: unwarpRawValue)
            default:
                value = .unsupported
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)
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
}
