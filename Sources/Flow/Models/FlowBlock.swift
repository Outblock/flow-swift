//
//  FlowBlock
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
    /// Brief information of `Flow.Block`
    struct BlockHeader {
        /// The identification of block
        public let id: ID

        /// The identification of previous block
        public let parentId: ID

        /// The height of block
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

    /// The data structure of `Flow.Block` which is `sealed`
    struct BlockSeal {
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

    /// The data structure for the block in Flow blockchain
    struct Block {
        /// The identification of block
        public let id: ID

        /// The identification of previous block
        public let parentId: ID

        /// The height of block
        public let height: UInt64

        /// The time when the block is created
        public let timestamp: Date

        // TODO: add doc
        public var collectionGuarantees: [CollectionGuarantee]

        // TODO: add doc
        public var blockSeals: [BlockSeal]

        /// The list of signature of the block
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
