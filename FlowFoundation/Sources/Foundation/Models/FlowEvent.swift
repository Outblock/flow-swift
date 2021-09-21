//
//  FlowEvent.swift
//
//
//  Created by lmcmz on 22/7/21.
//

import Foundation

extension Flow {
    struct Event {
        let type: String
        let transactionId: Id
        let transactionIndex: Int
        let eventIndex: Int
        let payload: EventPayload

        init(value: Flow_Entities_Event) {
            type = value.type
            transactionId = Id(bytes: value.transactionID.bytes)
            transactionIndex = Int(value.transactionIndex)
            eventIndex = Int(value.eventIndex)
            payload = EventPayload(bytes: value.payload.bytes)
        }
    }

    struct EventResult {
        let blockId: Id
        let blockHeight: UInt64
        let blockTimestamp: Date
        var events: [Event]

        init(value: Flow_Access_EventsResponse.Result) {
            blockId = Id(bytes: value.blockID.bytes)
            blockHeight = value.blockHeight
            blockTimestamp = value.blockTimestamp.date
            events = value.events.compactMap { Event(value: $0) }
        }
    }

    struct Snapshot: FlowEntity, Equatable {
        var data: Data
    }

    struct EventPayload: FlowEntity {
        var data: Data
        var fields: Flow.Argument?

        init(data: Data) {
            self.data = data
            fields = try? JSONDecoder().decode(Flow.Argument.self, from: data)
        }

        init(bytes: [UInt8]) {
            self.init(data: bytes.data)
        }
    }
}
