//
//  File.swift
//
//
//  Created by lmcmz on 27/7/21.
//

import Foundation

extension Flow {
    public struct Collection {
        let id: ID
        let transactionIds: [ID]

        init(value: Flow_Entities_Collection) {
            id = ID(bytes: value.id.bytes)
            transactionIds = value.transactionIds.compactMap { ID(bytes: $0.bytes) }
        }
    }

    public struct CollectionGuarantee {
        let id: ID
        let signatures: [Signature]

        init(value: Flow_Entities_CollectionGuarantee) {
            id = ID(bytes: value.collectionID.bytes)
            signatures = value.signatures.compactMap { Signature(data: $0) }
        }
    }
}
