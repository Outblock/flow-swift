//
//  File.swift
//
//
//  Created by lmcmz on 27/7/21.
//

import Foundation

extension Flow {
    struct Collection {
        let id: FlowId
        let transactionIds: [FlowId]

        init(value: Flow_Entities_Collection) {
            id = FlowId(bytes: value.id.byteArray)
            transactionIds = value.transactionIds.compactMap { FlowId(bytes: $0.byteArray) }
        }
    }

    struct CollectionGuarantee {
        let id: FlowId
        let signatures: [Signature]

        init(value: Flow_Entities_CollectionGuarantee) {
            id = FlowId(bytes: value.collectionID.byteArray)
            signatures = value.signatures.compactMap { Signature(bytes: $0.byteArray) }
        }
    }
}
