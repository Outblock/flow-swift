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
            id = Id(bytes: value.id.byteArray)
            transactionIds = value.transactionIds.compactMap { Id(bytes: $0.byteArray) }
        }
    }

    struct CollectionGuarantee {
        let id: Id
        let signatures: [Signature]

        init(value: Flow_Entities_CollectionGuarantee) {
            id = Id(bytes: value.collectionID.byteArray)
            signatures = value.signatures.compactMap { Signature(bytes: $0.byteArray) }
        }
    }
}
