//
//  FlowEvent
//
//  Copyright 2021 Zed Labs Pty Ltd
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
    struct Event {
        ///
        public let type: String

        /// The id for the transaction, `Flow.ID`
        public let transactionId: ID
        public let transactionIndex: Int
        public let eventIndex: Int
        public let payload: Payload

        init(value: Flow_Entities_Event) {
            type = value.type
            transactionId = ID(data: value.transactionID)
            transactionIndex = Int(value.transactionIndex)
            eventIndex = Int(value.eventIndex)
            payload = Payload(bytes: value.payload.bytes)
        }

        /// The event result
        public struct Result {
            public let blockId: ID
            public let blockHeight: UInt64
            public let blockTimestamp: Date
            public var events: [Event]

            init(value: Flow_Access_EventsResponse.Result) {
                blockId = ID(data: value.blockID)
                blockHeight = value.blockHeight
                blockTimestamp = value.blockTimestamp.date
                events = value.events.compactMap { Event(value: $0) }
            }
        }

        public struct Payload: FlowEntity {
            public var data: Data
            public var fields: Flow.Argument?

            init(data: Data) {
                self.data = data
                fields = try? JSONDecoder().decode(Flow.Argument.self, from: data)
            }

            init(bytes: [UInt8]) {
                self.init(data: bytes.data)
            }
        }
    }

    struct Snapshot: FlowEntity, Equatable {
        public var data: Data
    }
}

extension Flow.Snapshot: CustomStringConvertible {
    public var description: String { data.hexValue }
}
