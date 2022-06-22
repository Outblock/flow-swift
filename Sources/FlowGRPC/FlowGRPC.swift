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
                  weight: Int(value.weight),
                  sequenceNumber: Int64(value.sequenceNumber),
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

public extension Flow.TransactionResult {
    init(value: Flow_Access_TransactionResultResponse) {
        self.init(status: Flow.Transaction.Status(Int(value.status.rawValue)),
                  errorMessage: value.errorMessage,
                  events: value.events.compactMap { Flow.Event(value: $0) },
                  statusCode: Int(value.statusCode),
                  blockId: Flow.ID(data: value.blockID),
                  computationUsed: "0")
    }
}

public extension Flow.Event {
    init(value: Flow_Entities_Event) {
        self.init(type: value.type,
                  transactionId: Flow.ID(data: value.transactionID),
                  transactionIndex: Int(value.transactionIndex),
                  eventIndex: Int(value.eventIndex),
                  payload: Payload(data: value.payload))
    }
}

public extension Flow.Event.Result {
    init(value: Flow_Access_EventsResponse.Result) {
        self.init(blockId: Flow.ID(data: value.blockID),
                  blockHeight: value.blockHeight,
                  blockTimestamp: value.blockTimestamp.date,
                  events: value.events.compactMap { Flow.Event(value: $0) })
    }
}

public extension Flow.Transaction {
    init(value: Flow_Entities_Transaction) {
        self.init(script: Flow.Script(data: value.script),
                  arguments: value.arguments.compactMap { try? JSONDecoder().decode(Flow.Argument.self, from: $0) },
                  referenceBlockId: Flow.ID(data: value.referenceBlockID),
                  gasLimit: value.gasLimit,
                  proposalKey: Flow.TransactionProposalKey(value: value.proposalKey),
                  payer: Flow.Address(data: value.payer),
                  authorizers: value.authorizers.compactMap { Flow.Address(data: $0) },
                  payloadSignatures: value.payloadSignatures.compactMap { Flow.TransactionSignature(value: $0) },
                  envelopeSignatures: value.envelopeSignatures.compactMap { Flow.TransactionSignature(value: $0) })
    }
}

public extension Flow.TransactionSignature {
    init(value: Flow_Entities_Transaction.Signature) {
        self.init(address: Flow.Address(data: value.address),
                  keyIndex: Int(value.keyID),
                  signature: value.signature)
    }
}

public extension Flow.TransactionProposalKey {
    init(value: Flow_Entities_Transaction.ProposalKey) {
        self.init(address: Flow.Address(data: value.address),
                  keyIndex: Int(value.keyID),
                  sequenceNumber: Int64(value.sequenceNumber))
    }
}
