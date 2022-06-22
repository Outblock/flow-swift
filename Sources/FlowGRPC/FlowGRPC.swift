//
//  File.swift
//
//
//  Created by Hao Fu on 19/6/2022.
//

import Flow
import Foundation


public final class FlowGRPC {}

extension Flow.BlockHeader {
    init(value: Flow_Entities_Block) {
        let id = Flow.ID(data: value.id)
        let parentId = Flow.ID(data: value.parentID)
        self.init(id: id, parentId: parentId, height: value.height, timestamp: value.timestamp.date)
    }

    init(value: Flow_Entities_BlockHeader) {
        let id = Flow.ID(data: value.id)
        let parentId = Flow.ID(data: value.parentID)
        self.init(id: id, parentId: parentId, height: value.height, timestamp: value.timestamp.date)
    }
}

extension Flow.Block {
    init(value: Flow_Entities_Block) {
        self.init(id: Flow.ID(data: value.id),
                  parentId: Flow.ID(data: value.parentID),
                  height: value.height,
                  timestamp: value.timestamp.date,
                  collectionGuarantees: value.collectionGuarantees.compactMap { Flow.CollectionGuarantee(value: $0) },
                  blockSeals: value.blockSeals.compactMap { Flow.BlockSeal(value: $0) },
                  signatures: value.signatures.compactMap { Flow.Signature(data: $0) })
    }
}

extension Flow.BlockSeal {
    init(value: Flow_Entities_BlockSeal) {
        self.init(id: Flow.ID(data: value.blockID),
                  executionReceiptId: Flow.ID(data: value.executionReceiptID),
                  executionReceiptSignatures: value.executionReceiptSignatures.compactMap { Flow.Signature(data: $0) },
                  resultApprovalSignatures: value.resultApprovalSignatures.compactMap { Flow.Signature(data: $0) })
    }
}

public extension Flow.Collection {
    init(value: Flow_Entities_Collection) {
        self.init(id: Flow.ID(data: value.id),
                  transactionIds: value.transactionIds.compactMap { Flow.ID(data: $0) })
    }
}

public extension Flow.CollectionGuarantee {
    init(value: Flow_Entities_CollectionGuarantee) {
        self.init(id: Flow.ID(data: value.collectionID),
                  signatures: value.signatures.compactMap { Flow.Signature(data: $0) })
    }
}


public extension Flow.AccountKey {
    init(value: Flow_Entities_AccountKey) {        
        self.init(index: Int(value.index),
                  publicKey: Flow.PublicKey(data: value.publicKey),
                  signAlgo: Flow.SignatureAlgorithm(code: Int(value.signAlgo)),
                  hashAlgo: Flow.HashAlgorithm(code: Int(value.hashAlgo)),
                  weight:  Int(value.weight),
                  sequenceNumber: Int(value.sequenceNumber),
                  revoked: value.revoked)
    }
}

public extension Flow.Account {
    init(value: Flow_Entities_Account) {
        self.init(address: Flow.Address(data: value.address),
                  balance: value.balance,
                  keys: value.keys.compactMap { Flow.AccountKey(value: $0) },
                  contracts: value.contracts.compactMapValues { Flow.Code(data: $0) })
        
    }
}
    
