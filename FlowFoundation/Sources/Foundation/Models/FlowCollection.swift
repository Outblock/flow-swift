//
//  File.swift
//
//
//  Created by lmcmz on 27/7/21.
//

import Foundation

extension Flow {
    struct Collection {
        let id: Id
        let transactionIds: [Id]

        init(value: Flow_Entities_Collection) {
            id = Id(bytes: value.id.bytes)
            transactionIds = value.transactionIds.compactMap { Id(bytes: $0.bytes) }
        }
    }

    struct CollectionGuarantee {
        let id: Id
        let signatures: [Signature]

        init(value: Flow_Entities_CollectionGuarantee) {
            id = Id(bytes: value.collectionID.bytes)
            signatures = value.signatures.compactMap { Signature(data: $0) }
        }
    }
}
