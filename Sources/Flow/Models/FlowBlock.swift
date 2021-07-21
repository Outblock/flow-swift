//
//  File.swift
//
//
//  Created by lmcmz on 21/7/21.
//

import Foundation

struct FlowBlockHeader {
    let id: FlowId
    let parentId: FlowId
    let height: UInt64

    init(value: Flow_Entities_BlockHeader) {
        id = FlowId(bytes: value.id.byteArray)
        parentId = FlowId(bytes: value.parentID.byteArray)
        height = value.height
    }
}

struct FlowBlockSeal {
    let id: FlowId
    let executionReceiptId: FlowId
    let executionReceiptSignatures: [FlowSignature]
    let resultApprovalSignatures: [FlowSignature]

    init(value: Flow_Entities_BlockSeal) {
        id = FlowId(bytes: value.blockID.byteArray)
        executionReceiptId = FlowId(bytes: value.executionReceiptID.byteArray)
        executionReceiptSignatures = value.executionReceiptSignatures.compactMap { FlowSignature(bytes: $0.byteArray) }
        resultApprovalSignatures = value.resultApprovalSignatures.compactMap { FlowSignature(bytes: $0.byteArray) }
    }
}

struct FlowBlock {
    let id: FlowId
    let parentId: FlowId
    let height: UInt64
    let timestamp: Date
    var collectionGuarantees: [FlowCollectionGuarantee]
    var blockSeals: [FlowBlockSeal]
    var signatures: [FlowSignature]

    init(value: Flow_Entities_Block) {
        id = FlowId(bytes: value.id.byteArray)
        parentId = FlowId(bytes: value.parentID.byteArray)
        height = value.height
        timestamp = value.timestamp.date
        collectionGuarantees = value.collectionGuarantees.compactMap { FlowCollectionGuarantee(value: $0) }
        blockSeals = value.blockSeals.compactMap { FlowBlockSeal(value: $0) }
        signatures = value.signatures.compactMap { FlowSignature(bytes: $0.byteArray) }
    }
}
