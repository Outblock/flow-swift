//
//  FlowBlock.swift
//
//
//  Created by lmcmz on 21/7/21.
//

import Foundation

extension Flow {
    struct BlockHeader {
        let id: Id
        let parentId: Id
        let height: UInt64

        init(value: Flow_Entities_Block) {
            id = Id(bytes: value.id.byteArray)
            parentId = Id(bytes: value.parentID.byteArray)
            height = value.height
        }

        init(value: Flow_Entities_BlockHeader) {
            id = Id(bytes: value.id.byteArray)
            parentId = Id(bytes: value.parentID.byteArray)
            height = value.height
        }
    }

    struct BlockSeal {
        let id: Id
        let executionReceiptId: Id
        let executionReceiptSignatures: [Signature]
        let resultApprovalSignatures: [Signature]

        init(value: Flow_Entities_BlockSeal) {
            id = Id(bytes: value.blockID.byteArray)
            executionReceiptId = Id(bytes: value.executionReceiptID.byteArray)
            executionReceiptSignatures = value.executionReceiptSignatures.compactMap { Signature(bytes: $0.byteArray) }
            resultApprovalSignatures = value.resultApprovalSignatures.compactMap { Signature(bytes: $0.byteArray) }
        }
    }

    struct Block {
        let id: Id
        let parentId: Id
        let height: UInt64
        let timestamp: Date
        var collectionGuarantees: [CollectionGuarantee]
        var blockSeals: [BlockSeal]
        var signatures: [Signature]

        init(value: Flow_Entities_Block) {
            id = Id(bytes: value.id.byteArray)
            parentId = Id(bytes: value.parentID.byteArray)
            height = value.height
            timestamp = value.timestamp.date
            collectionGuarantees = value.collectionGuarantees.compactMap { CollectionGuarantee(value: $0) }
            blockSeals = value.blockSeals.compactMap { BlockSeal(value: $0) }
            signatures = value.signatures.compactMap { Signature(bytes: $0.byteArray) }
        }
    }
}
