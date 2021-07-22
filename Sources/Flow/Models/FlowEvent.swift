//
//  FlowEvent.swift
//
//
//  Created by lmcmz on 22/7/21.
//

import Foundation

struct FlowEvent {
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

struct FlowTransactionResult {
    let status: FlowTransactionStatus
    let statusCode: Int
    let errorMessage: String
    let events: [FlowEvent]

    init(value: Flow_Execution_GetTransactionResultResponse) {
        status = FlowTransactionStatus(num: Int(value.statusCode))
        statusCode = Int(value.statusCode)
        errorMessage = value.errorMessage
        events = value.events.compactMap { FlowEvent(value: $0) }
    }
}

struct FlowEventResult {
    let blockId: FlowId
    let blockHeight: UInt64
    let blockTimestamp: Date
    var events: [FlowEvent]

    init(value: Flow_Access_EventsResponse.Result) {
        blockId = FlowId(bytes: value.blockID.byteArray)
        blockHeight = value.blockHeight
        blockTimestamp = value.blockTimestamp.date
        events = value.events.compactMap { FlowEvent(value: $0) }
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
