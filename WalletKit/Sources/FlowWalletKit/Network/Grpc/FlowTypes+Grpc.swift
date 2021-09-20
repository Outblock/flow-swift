import Flow
import Foundation
import SwiftProtobuf

public protocol GrpcEntityConsumer {
    static func from(_ object: SwiftProtobuf.Message) -> FlowEntity?
}

extension FlowTransactionResult: GrpcEntityConsumer {
    public static func from(_ object: SwiftProtobuf.Message) -> FlowEntity? {
        let transactionResult = FlowTransactionResult()
        let input = object as! Flow_Access_TransactionResultResponse

        transactionResult.errorMessage = input.errorMessage
        transactionResult.events = input.events.map { event in FlowEvent.from(event) as! FlowEvent }
        transactionResult.statusCode = Int(input.statusCode)
        transactionResult.status = FlowTransactionStatus(rawValue: Int(input.status.rawValue))!

        return transactionResult
    }
}

extension FlowExecutionResult: GrpcEntityConsumer {
    public static func from(_ object: SwiftProtobuf.Message) -> FlowEntity? {
        let executionResult = FlowExecutionResult()
        let input = object as! Flow_Entities_ExecutionResult
        executionResult.previousResultId = FlowIdentifier(input.previousResultID)
        executionResult.blockId = FlowIdentifier(input.blockID)
        executionResult.chunks = input.chunks.map { object in FlowChunk.from(object) as! FlowChunk }
        executionResult.serviceEvents = input.serviceEvents.map { object in FlowServiceEvent.from(object) as! FlowServiceEvent }
        return executionResult
    }
}

extension FlowChunk: GrpcEntityConsumer {
    public static func from(_ object: SwiftProtobuf.Message) -> FlowEntity? {
        let input = object as! Flow_Entities_Chunk
        let chunk = FlowChunk()
        chunk.startState = FlowBlob.from(input.startState)
        chunk.eventCollection = FlowBlob.from(input.eventCollection)
        chunk.blockId = FlowIdentifier.from(input.blockID)
        chunk.totalComputationUsed = Int(input.totalComputationUsed)
        chunk.numberOfTransactions = Int(input.numberOfTransactions)
        chunk.index = Int(input.index)
        chunk.endState = FlowBlob.from(input.endState)
        return chunk
    }
}

extension FlowServiceEvent: GrpcEntityConsumer {
    public static func from(_ object: SwiftProtobuf.Message) -> FlowEntity? {
        let event = FlowServiceEvent()
        let input = object as! Flow_Entities_ServiceEvent
        event.type = input.type
        event.payload = FlowBlob.from(input.payload)
        return event
    }
}

extension FlowCollection: GrpcEntityConsumer {
    public static func from(_ object: SwiftProtobuf.Message) -> FlowEntity? {
        let collection = FlowCollection()
        let input = object as! Flow_Entities_Collection
        collection.id = FlowIdentifier(input.id)
        collection.transactionIds = FlowIdentifier.from(input.transactionIds)
        return collection
    }
}

extension FlowEventsResult: GrpcEntityConsumer {
    public static func from(_ object: SwiftProtobuf.Message) -> FlowEntity? {
        let result = FlowEventsResult()
        let input = object as! Flow_Access_EventsResponse.Result
        result.blockHeight = Int(input.blockHeight)
        result.blockId = FlowIdentifier.from(input.blockID)
        result.blockTimestamp = UInt64(input.blockTimestamp.seconds)
        result.events = input.events.map { object in FlowEvent.from(object) as! FlowEvent }
        return result
    }
}

extension FlowEventsResponse: GrpcEntityConsumer {
    public static func from(_ object: SwiftProtobuf.Message) -> FlowEntity? {
        let result = FlowEventsResponse()
        let input = object as! Flow_Access_EventsResponse
        result.results = input.results.map { object in FlowEventsResult.from(object) as! FlowEventsResult }
        return result
    }
}

extension FlowEvent: GrpcEntityConsumer {
    public static func from(_ object: SwiftProtobuf.Message) -> FlowEntity? {
        let event = FlowEvent()
        let input = object as! Flow_Entities_Event
        event.type = input.type
        event.transactionId = FlowIdentifier.from(input.transactionID)
        event.transactionIndex = Int(input.transactionIndex)
        event.eventIndex = Int(input.eventIndex)
        event.payload = CadenceValue.fromJSON(input.payload)?.innerValue as? CadenceStruct
        return event
    }
}

extension FlowAccountKey: GrpcEntityConsumer {
    public static func from(_ object: SwiftProtobuf.Message) -> FlowEntity? {
        let input = object as! Flow_Entities_AccountKey
        return FlowAccountKey(
            publicKey: input.publicKey.bytes,
            signAlgorithm: Int(input.signAlgo),
            hashAlgorithm: Int(input.hashAlgo),
            weight: Int(input.weight),
            sequenceNumber: Int(input.sequenceNumber)
        )
    }
}

extension FlowBlockSeal: GrpcEntityConsumer {
    public static func from(_ object: SwiftProtobuf.Message) -> FlowEntity? {
        let seal = FlowBlockSeal()
        let input = object as! Flow_Entities_BlockSeal

        seal.blockId = FlowIdentifier.from(input.blockID)
        seal.executionReceiptId = FlowIdentifier.from(input.executionReceiptID)
        seal.executionReceiptSignatures = FlowBlob.from(input.executionReceiptSignatures.map { object in object })
        seal.resultApprovalSignatures = FlowBlob.from(input.resultApprovalSignatures.map { object in object })
        return seal
    }
}

extension FlowCollectionGuarantee: GrpcEntityConsumer {
    public static func from(_ object: SwiftProtobuf.Message) -> FlowEntity? {
        let guarantee = FlowCollectionGuarantee()
        let input = object as! Flow_Entities_CollectionGuarantee

        guarantee.collectionId = FlowIdentifier.from(input.collectionID)
        guarantee.signatures = FlowBlob.from(input.signatures.map { object in object })
        return guarantee
    }
}

extension FlowBlock: GrpcEntityConsumer {
    public static func from(_ object: SwiftProtobuf.Message) -> FlowEntity? {
        let block = FlowBlock()
        let input = object as! Flow_Entities_Block

        block.id = FlowIdentifier.from(input.id)
        block.parentId = FlowIdentifier.from(input.parentID)
        block.height = Int(input.height)
        block.timestamp = UInt64(input.timestamp.seconds)
        block.collectionGuarantees = input.collectionGuarantees.map { object in FlowCollectionGuarantee.from(object) as! FlowCollectionGuarantee }
        block.blockSeals = input.blockSeals.map { object in FlowBlockSeal.from(object) as! FlowBlockSeal }
        block.signatures = FlowBlob.from(input.signatures.map { object in object })
        return block
    }
}

extension FlowBlockHeader: GrpcEntityConsumer {
    public static func from(_ object: SwiftProtobuf.Message) -> FlowEntity? {
        let block = FlowBlockHeader()
        let input = object as! Flow_Entities_BlockHeader

        block.id = FlowIdentifier.from(input.id)
        block.parentId = FlowIdentifier.from(input.parentID)
        block.height = Int(input.height)
        return block
    }
}

extension FlowAccount: GrpcEntityConsumer {
    public static func from(_ object: SwiftProtobuf.Message) -> FlowEntity? {
        let flowAccount = FlowAccount()
        let account = object as! Flow_Entities_Account
        flowAccount.address = FlowAddress.from(account.address.hexString())!
        flowAccount.balance = CadenceUInt64(account.balance)
        flowAccount.keys = account.keys.map { key in FlowAccountKey.from(key) as! FlowAccountKey }
        for contractName in account.contracts.keys {
            let deployed = FlowDeployedContract(
                name: contractName,
                code: String(data: account.contracts[contractName]!, encoding: .utf8)!
            )
            flowAccount.contracts[contractName] = deployed
        }
        return flowAccount
    }
}
