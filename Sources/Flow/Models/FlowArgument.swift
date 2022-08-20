//
//  FlowArgument
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

public extension Flow {
    /// The argument for Cadence code for encoding and decoding
    struct Argument: Codable, Equatable {
        /// The type of the argument in `Flow.Cadence.FType`
        public let type: Cadence.FType

        /// The value of the argument in `Flow.Cadence.FValue`
        public let value: Cadence.FValue

        enum CodingKeys: String, CodingKey {
            case type
            case value
        }

        /// Encode argument into json data.
        public var jsonData: Data? {
            let encoder = JSONEncoder()
            guard let jsonData = try? encoder.encode(self) else {
                return nil
            }
            return jsonData
        }

        /// Encode argument into json string.
        public var jsonString: String? {
            guard let data = jsonData else {
                return nil
            }
            return String(data: data, encoding: .utf8)
        }

        /// Initial argument with type and value
        public init(type: Cadence.FType, value: Flow.Cadence.FValue) {
            self.type = type
            self.value = value
        }

        /// Initial argument with value in `Flow.Cadence.FValue` type
        public init(value: Flow.Cadence.FValue) {
            type = value.type
            self.value = value
        }

        public init?(jsonData: Data) {
            do {
                let result = try JSONDecoder().decode(Flow.Argument.self, from: jsonData)
                self.init(type: result.type, value: result.value)
            } catch {
                print(error)
                return nil
            }
        }

        public init?(jsonString: String) {
            guard let jsonData = jsonString.data(using: .utf8) else {
                return nil
            }
            self.init(jsonData: jsonData)
        }

        /// Decode argument from json string
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            type = try container.decode(Cadence.FType.self, forKey: .type)

            switch type {
            case .int:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = Int(unwarpRawValue) else { value = .error; return }
                value = .int(realValue)
            case .uint:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = UInt(unwarpRawValue) else { value = .error; return }
                value = .uint(realValue)
            case .int8:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = Int8(unwarpRawValue) else { value = .error; return }
                value = .int8(realValue)
            case .uint8:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = UInt8(unwarpRawValue) else { value = .error; return }
                value = .uint8(realValue)
            case .int16:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = Int16(unwarpRawValue) else { value = .error; return }
                value = .int16(realValue)
            case .uint16:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = UInt16(unwarpRawValue) else { value = .error; return }
                value = .uint16(realValue)
            case .int32:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = Int32(unwarpRawValue) else { value = .error; return }
                value = .int32(realValue)
            case .uint32:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = UInt32(unwarpRawValue) else { value = .error; return }
                value = .uint32(realValue)
            case .int64:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = Int64(unwarpRawValue) else { value = .error; return }
                value = .int64(realValue)
            case .uint64:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = UInt64(unwarpRawValue) else { value = .error; return }
                value = .uint64(realValue)
            case .int128:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = BigInt(unwarpRawValue) else { value = .error; return }
                value = .int128(realValue)
            case .uint128:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = BigUInt(unwarpRawValue) else { value = .error; return }
                value = .uint128(realValue)
            case .int256:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = BigInt(unwarpRawValue) else { value = .error; return }
                value = .int256(realValue)
            case .uint256:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = BigUInt(unwarpRawValue) else { value = .error; return }
                value = .uint256(realValue)
            case .word8:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = UInt8(unwarpRawValue) else { value = .error; return }
                value = .word8(realValue)
            case .word16:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = UInt16(unwarpRawValue) else { value = .error; return }
                value = .word16(realValue)
            case .word32:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = UInt32(unwarpRawValue) else { value = .error; return }
                value = .word32(realValue)
            case .word64:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = UInt64(unwarpRawValue) else { value = .error; return }
                value = .word64(realValue)
            case .fix64:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = Double(unwarpRawValue) else { value = .error; return }
                value = .fix64(realValue)
            case .ufix64:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                guard let realValue = Double(unwarpRawValue) else { value = .error; return }
                value = .ufix64(realValue)
            case .string:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                value = .string(unwarpRawValue)
            case .bool:
                let rawValue = try? container.decode(Bool.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                value = .bool(unwarpRawValue)
            case .optional:
                let rawValue = try? container.decode(Argument.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                value = .optional(value: unwarpRawValue)
            case .address:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                value = .address(Flow.Address(hex: unwarpRawValue))
            case .path:
                let rawValue = try? container.decode(Path.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                value = .path(unwarpRawValue)
            case .event:
                let rawValue = try? container.decode(Event.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                value = .event(unwarpRawValue)
            case .array:
                let rawValue = try? container.decode([Flow.Argument].self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                value = .array(unwarpRawValue)
            case .character:
                let rawValue = try? container.decode(String.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                value = .character(unwarpRawValue)
            case .reference:
                let rawValue = try? container.decode(Reference.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                value = .reference(unwarpRawValue)
            case .struct:
                let rawValue = try? container.decode(Event.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                value = .struct(unwarpRawValue)
            case .resource:
                let rawValue = try? container.decode(Event.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                value = .resource(unwarpRawValue)
            case .dictionary:
                let rawValue = try? container.decode([Flow.Argument.Dictionary].self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                value = .dictionary(unwarpRawValue)
            case .capability:
                let rawValue = try? container.decode(Flow.Argument.Capability.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                value = .capability(unwarpRawValue)
            case .enum:
                let rawValue = try? container.decode(Flow.Argument.Event.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                value = .enum(unwarpRawValue)
            case .contract:
                let rawValue = try? container.decode(Flow.Argument.Event.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                value = .contract(unwarpRawValue)
            case .type:
                let rawValue = try? container.decode(Flow.Argument.StaticType.self, forKey: .value)
                guard let unwarpRawValue = rawValue else { value = .error; return }
                value = .type(unwarpRawValue)
            case .void:
                value = .void
            case .undefined:
                value = .unsupported
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)
            try container.encode(value, forKey: .value)
        }
    }
}

public extension Flow.Argument {
    /// The data structure for `.path` argument type
    /// More detail can be found here: https://docs.onflow.org/cadence/json-cadence-spec/#path
    struct Path: Codable, Equatable {
        public let domain: String
        public let identifier: String

        public init(domain: String, identifier: String) {
            self.domain = domain
            self.identifier = identifier
        }
    }

    /// The data structure for `.struct, .resource, .event, .contract, .enum` argument type
    /// More detail can be found here: https://docs.onflow.org/cadence/json-cadence-spec/#composites-struct-resource-event-contract-enum
    struct Event: Codable, Equatable {
        /// The identification of the event
        public let id: String

        /// The list of value in `Flow.Argument.Event.Name` type.
        public let fields: [Name]

        public init(id: String, fields: [Flow.Argument.Event.Name]) {
            self.id = id
            self.fields = fields
        }

        /// The data structure for the `fields` in `Flow.Argument.Event`
        public struct Name: Codable, Equatable {
            public let name: String
            public let value: Flow.Argument

            public init(name: String, value: Flow.Cadence.FValue) {
                self.name = name
                self.value = value.toArgument()
            }

            public init(name: String, value: Flow.Argument) {
                self.name = name
                self.value = value
            }
        }
    }

    /// The data structure for `.reference` argument type
    struct Reference: Codable, Equatable {
        public let address: String
        public let type: String

        public init(address: String, type: String) {
            self.address = address
            self.type = type
        }
    }

    /// The data structure for `.dictionary` argument type
    /// More detail can be found here: https://docs.onflow.org/cadence/json-cadence-spec/#dictionary
    struct Dictionary: Codable, Equatable {
        public let key: Flow.Argument
        public let value: Flow.Argument

        public init(key: Flow.Cadence.FValue, value: Flow.Cadence.FValue) {
            self.key = key.toArgument()
            self.value = value.toArgument()
        }

        public init(key: Flow.Argument, value: Flow.Argument) {
            self.key = key
            self.value = value
        }
    }

    /// The data structure for `.capability` argument type
    /// More detail can be found here: https://docs.onflow.org/cadence/json-cadence-spec/#capability
    struct Capability: Codable, Equatable {
        public let path: String
        public let address: String
        public let borrowType: String

        public init(path: String, address: String, borrowType: String) {
            self.path = path
            self.address = address
            self.borrowType = borrowType
        }
    }

    /// The data structure for `.type` argument type
    /// More detail can be found here: https://docs.onflow.org/cadence/json-cadence-spec/#type
    struct StaticType: Codable, Equatable {
        let staticType: Flow.Cadence.Kind
        
        public init(staticType: Flow.Cadence.Kind) {
            self.staticType = staticType
        }
    }
}
