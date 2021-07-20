//
//  File.swift
//
//
//  Created by lmcmz on 19/7/21.
//

import Foundation

protocol BytesHolder {
    var bytes: [UInt8] { set get }
    var base16Value: String { get }
    var stringValue: String { get }
}

extension BytesHolder {
    var base16Value: String {
        return bytes.hexValue
    }

    var stringValue: String {
        return String(bytes: bytes, encoding: .utf8) ?? ""
    }
}

struct FlowId: BytesHolder, Equatable {
    var bytes: [UInt8]

    init(hex: String) {
        bytes = hex.hexValue
    }

    init(bytes: [UInt8]) {
        self.bytes = bytes
    }
}

struct FlowSignature: BytesHolder, Equatable {
    var bytes: [UInt8]

    init(hex: String) {
        bytes = hex.hexValue
    }

    init(bytes: [UInt8]) {
        self.bytes = bytes
    }
}

struct FlowBlockHeader {
    let id: FlowId
    let parentId: FlowId
    let height: UInt64

    init(value: Flow_Entities_BlockHeader) {
        id = FlowId(bytes: value.id.byteArray)
        parentId = FlowId(bytes: value.parentID.byteArray)
        height = value.height
    }
}

struct FlowCollection {
    let id: FlowId
    let transactionIds: [FlowId]

    init(value: Flow_Entities_Collection) {
        id = FlowId(bytes: value.id.byteArray)
        transactionIds = value.transactionIds.compactMap { FlowId(bytes: $0.byteArray) }
    }
}

struct FlowCollectionGuarantee {
    let id: FlowId
    let signatures: [FlowSignature]

    init(value: Flow_Entities_CollectionGuarantee) {
        id = FlowId(bytes: value.collectionID.byteArray)
        signatures = value.signatures.compactMap { FlowSignature(bytes: $0.byteArray) }
    }
}

struct FlowBlockSeal {
    let id: FlowId
    let executionReceiptId: FlowId
    let executionReceiptSignatures: [FlowSignature]
    let resultApprovalSignatures: [FlowSignature]

    init(value: Flow_Entities_BlockSeal) {
        id = FlowId(bytes: value.blockID.byteArray)
        executionReceiptId = FlowId(bytes: value.executionReceiptID.byteArray)
        executionReceiptSignatures = value.executionReceiptSignatures.compactMap { FlowSignature(bytes: $0.byteArray) }
        resultApprovalSignatures = value.resultApprovalSignatures.compactMap { FlowSignature(bytes: $0.byteArray) }
    }
}

struct FlowBlock {
    let id: FlowId
    let parentId: FlowId
    let height: UInt64
    let timestamp: Date
    var collectionGuarantees: [FlowCollectionGuarantee]
    var blockSeals: [FlowBlockSeal]
    var signatures: [FlowSignature]

    init(value: Flow_Entities_Block) {
        id = FlowId(bytes: value.id.byteArray)
        parentId = FlowId(bytes: value.parentID.byteArray)
        height = value.height
        timestamp = value.timestamp.date
        collectionGuarantees = value.collectionGuarantees.compactMap { FlowCollectionGuarantee(value: $0) }
        blockSeals = value.blockSeals.compactMap { FlowBlockSeal(value: $0) }
        signatures = value.signatures.compactMap { FlowSignature(bytes: $0.byteArray) }
    }
}
