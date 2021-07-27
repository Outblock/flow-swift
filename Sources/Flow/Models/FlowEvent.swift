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
        let transactionId: FlowId
        let transactionIndex: Int
        let eventIndex: Int
        let payload: FlowEventPayload

        init(value: Flow_Entities_Event) {
            type = value.type
            transactionId = FlowId(bytes: value.transactionID.byteArray)
            transactionIndex = Int(value.transactionIndex)
            eventIndex = Int(value.eventIndex)
            payload = FlowEventPayload(bytes: value.payload.byteArray)
        }
    }

    struct EventResult {
        let blockId: FlowId
        let blockHeight: UInt64
        let blockTimestamp: Date
        var events: [Event]

        init(value: Flow_Access_EventsResponse.Result) {
            blockId = FlowId(bytes: value.blockID.byteArray)
            blockHeight = value.blockHeight
            blockTimestamp = value.blockTimestamp.date
            events = value.events.compactMap { Event(value: $0) }
        }
    }
}

struct FlowSnapshot: BytesHolder, Equatable {
    var bytes: ByteArray
}

struct FlowEventPayload: BytesHolder, Equatable {
    var bytes: [UInt8]

    // TODO: Add jsonCadence
    // var jsonCadence: Field<T>
}
