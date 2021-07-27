//
//  FlowBlock.swift
//
//
//  Created by lmcmz on 21/7/21.
//

import Foundation

extension Flow {
    struct BlockHeader {
        let id: FlowId
        let parentId: FlowId
        let height: UInt64

        init(value: Flow_Entities_Block) {
            id = FlowId(bytes: value.id.byteArray)
            parentId = FlowId(bytes: value.parentID.byteArray)
            height = value.height
        }

        init(value: Flow_Entities_BlockHeader) {
            id = FlowId(bytes: value.id.byteArray)
            parentId = FlowId(bytes: value.parentID.byteArray)
            height = value.height
        }
    }

    struct BlockSeal {
        let id: FlowId
        let executionReceiptId: FlowId
        let executionReceiptSignatures: [Signature]
        let resultApprovalSignatures: [Signature]

        init(value: Flow_Entities_BlockSeal) {
            id = FlowId(bytes: value.blockID.byteArray)
            executionReceiptId = FlowId(bytes: value.executionReceiptID.byteArray)
            executionReceiptSignatures = value.executionReceiptSignatures.compactMap { Signature(bytes: $0.byteArray) }
            resultApprovalSignatures = value.resultApprovalSignatures.compactMap { Signature(bytes: $0.byteArray) }
        }
    }

    struct Block {
        let id: FlowId
        let parentId: FlowId
        let height: UInt64
        let timestamp: Date
        var collectionGuarantees: [CollectionGuarantee]
        var blockSeals: [BlockSeal]
        var signatures: [Signature]

        init(value: Flow_Entities_Block) {
            id = FlowId(bytes: value.id.byteArray)
            parentId = FlowId(bytes: value.parentID.byteArray)
            height = value.height
            timestamp = value.timestamp.date
            collectionGuarantees = value.collectionGuarantees.compactMap { CollectionGuarantee(value: $0) }
            blockSeals = value.blockSeals.compactMap { BlockSeal(value: $0) }
            signatures = value.signatures.compactMap { Signature(bytes: $0.byteArray) }
        }
    }
}
