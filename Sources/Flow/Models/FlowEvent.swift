//
//  FlowEvent
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

import Foundation

public extension Flow {
    ///
    struct Event: Codable {
        ///
        public let type: String

        /// The id for the transaction, `Flow.ID`
        public let transactionId: ID
        public let transactionIndex: Int
        public let eventIndex: Int
        public let payload: Payload

        public init(type: String, transactionId: Flow.ID, transactionIndex: Int, eventIndex: Int, payload: Flow.Event.Payload) {
            self.type = type
            self.transactionId = transactionId
            self.transactionIndex = transactionIndex
            self.eventIndex = eventIndex
            self.payload = payload
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            type = try container.decode(String.self, forKey: .type)
            transactionId = try container.decode(Flow.ID.self, forKey: .transactionId)
            let transactionIndex = try container.decode(String.self, forKey: .transactionIndex)
            self.transactionIndex = Int(transactionIndex) ?? -1
            let eventIndex = try container.decode(String.self, forKey: .eventIndex)
            self.eventIndex = Int(eventIndex) ?? -1
            payload = try container.decode(Flow.Event.Payload.self, forKey: .payload)
        }

        /// The event result
        public struct Result: Codable {
            public let blockId: ID
            public let blockHeight: UInt64
            public let blockTimestamp: Date
            public var events: [Event]

            public init(blockId: Flow.ID, blockHeight: UInt64, blockTimestamp: Date, events: [Flow.Event]) {
                self.blockId = blockId
                self.blockHeight = blockHeight
                self.blockTimestamp = blockTimestamp
                self.events = events
            }

            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                blockId = try container.decode(Flow.ID.self, forKey: .blockId)
                let blockHeight = try container.decode(String.self, forKey: .blockHeight)
                self.blockHeight = UInt64(blockHeight) ?? 0
                blockTimestamp = try container.decode(Date.self, forKey: .blockTimestamp)
                events = try container.decode([Flow.Event].self, forKey: .events)
            }
        }

        public struct Payload: FlowEntity, Codable {
            public var data: Data
            public var fields: Flow.Argument?

            public init(data: Data) {
                self.data = data
                fields = try? JSONDecoder().decode(Flow.Argument.self, from: data)
            }

            public init(bytes: [UInt8]) {
                self.init(data: bytes.data)
            }

            enum CodingKeys: CodingKey {
                case data
            }

            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                data = try container.decode(Data.self)
                fields = try? JSONDecoder().decode(Flow.Argument.self, from: data)
            }
        }
    }

    struct Snapshot: FlowEntity, Equatable, Codable {
        public var data: Data

        public init(data: Data) {
            self.data = data
        }
    }
}

extension Flow.Snapshot: CustomStringConvertible {
    public var description: String { data.hexValue }
}

extension Flow.Event.Payload: FlowCodable {
    func decode() -> Any? {
        return fields?.decode()
    }

    public func decode<T: Decodable>(_ decodable: T.Type) throws -> T? {
        return try fields?.decode(decodable)
    }

    public func decode<T: Decodable>() throws -> T {
        guard let result: T = try? fields?.decode() else {
            throw Flow.FError.decodeFailure
        }
        return result
    }
}
