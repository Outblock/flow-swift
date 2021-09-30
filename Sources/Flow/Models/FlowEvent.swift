//
//  FlowEvent.swift
//
//
//  Created by lmcmz on 22/7/21.
//

import Foundation

extension Flow {
    public struct Event {
        public let type: String
        public let transactionId: ID
        public let transactionIndex: Int
        public let eventIndex: Int
        public let payload: EventPayload

        init(value: Flow_Entities_Event) {
            type = value.type
            transactionId = ID(data: value.transactionID)
            transactionIndex = Int(value.transactionIndex)
            eventIndex = Int(value.eventIndex)
            payload = EventPayload(bytes: value.payload.bytes)
        }
    }

    public struct EventResult {
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

    public struct Snapshot: FlowEntity, Equatable {
        public var data: Data
    }

    public struct EventPayload: FlowEntity {
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
