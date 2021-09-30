//
//  FlowBlock.swift
//
//
//  Created by lmcmz on 21/7/21.
//

import Foundation

extension Flow {
    public struct BlockHeader {
        public let id: ID
        public let parentId: ID
        public let height: UInt64

        init(value: Flow_Entities_Block) {
            id = ID(bytes: value.id.bytes)
            parentId = ID(bytes: value.parentID.bytes)
            height = value.height
        }

        init(value: Flow_Entities_BlockHeader) {
            id = ID(bytes: value.id.bytes)
            parentId = ID(bytes: value.parentID.bytes)
            height = value.height
        }
    }

    public struct BlockSeal {
        public let id: ID
        public let executionReceiptId: ID
        public let executionReceiptSignatures: [Signature]
        public let resultApprovalSignatures: [Signature]

        init(value: Flow_Entities_BlockSeal) {
            id = ID(bytes: value.blockID.bytes)
            executionReceiptId = ID(bytes: value.executionReceiptID.bytes)
            executionReceiptSignatures = value.executionReceiptSignatures.compactMap { Signature(data: $0) }
            resultApprovalSignatures = value.resultApprovalSignatures.compactMap { Signature(data: $0) }
        }
    }

    public struct Block {
        public let id: ID
        public let parentId: ID
        public let height: UInt64
        public let timestamp: Date
        public var collectionGuarantees: [CollectionGuarantee]
        public var blockSeals: [BlockSeal]
        public var signatures: [Signature]

        init(value: Flow_Entities_Block) {
            id = ID(bytes: value.id.bytes)
            parentId = ID(bytes: value.parentID.bytes)
            height = value.height
            timestamp = value.timestamp.date
            collectionGuarantees = value.collectionGuarantees.compactMap { CollectionGuarantee(value: $0) }
            blockSeals = value.blockSeals.compactMap { BlockSeal(value: $0) }
            signatures = value.signatures.compactMap { Signature(data: $0) }
        }
    }
}
