//
//  FlowTransaction.swift
//
//
//  Created by lmcmz on 19/7/21.
//

import Foundation

struct FlowSignature: BytesHolder, Equatable {
    var bytes: [UInt8]

    init(hex: String) {
        bytes = hex.hexValue
    }

    init(bytes: [UInt8]) {
        self.bytes = bytes
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

enum FlowTransactionStatus: Int, CaseIterable {
    case unknown
    case pending
    case finalized
    case executed
    case sealed
    case expired

    init(num: Int) {
        self = FlowTransactionStatus.allCases.first { $0.rawValue == num } ?? .unknown
    }
}

enum FlowChainId: String, CaseIterable {
    case unknown
    case mainnet = "flow-mainnet"
    case testnet = "flow-testnet"
    case canarynet = "flow-canarynet"
    case emulator = "flow-emulator"

    init(id: String) {
        self = FlowChainId.allCases.first { $0.rawValue == id } ?? .unknown
    }
}

struct FlowArgument: BytesHolder {
    var bytes: [UInt8]
    // TODO: - Add jsonCadence
//    var jsonCadence:
}

struct FlowTransactionProposalKey {
    let address: FlowAddress
    let keyIndex: UInt32
    let sequenceNumber: UInt64

    init(value: Flow_Entities_Transaction.ProposalKey) {
        address = FlowAddress(bytes: value.address.byteArray)
        keyIndex = value.keyID
        sequenceNumber = value.sequenceNumber
    }
}

struct FlowTransactionSignature {
    let address: FlowAddress
    let keyIndex: UInt32
    let signature: FlowSignature

    init(value: Flow_Entities_Transaction.Signature) {
        address = FlowAddress(bytes: value.address.byteArray)
        keyIndex = value.keyID
        signature = FlowSignature(bytes: value.signature.byteArray)
    }

    func builder() {
//        let test = Flow_Entities_Transaction.Signature.init(jsonString: <#T##String#>)
    }
}

internal struct Payload {
    let script: ByteArray
    let arguments: [ByteArray]
    let referenceBlockId: ByteArray
    let gasLimit: UInt64
    let proposalKeyAddress: ByteArray
    let proposalKeyIndex: UInt32
    let proposalKeySequenceNumber: UInt64
    let payer: ByteArray
    let authorizers: [ByteArray]
}

struct FlowTransaction {
    let script: FlowScript
    let arguments: [FlowArgument]
    let referenceBlockId: FlowId
    let gasLimit: UInt64
    let proposalKey: FlowTransactionProposalKey
    let payerAddress: FlowAddress
    let authorizers: [FlowAddress]
    var payloadSignatures: [FlowTransactionSignature] = []
    var envelopeSignatures: [FlowTransactionSignature] = []

    var payload: Payload {
        Payload(script: script.bytes,
                arguments: arguments.compactMap { $0.bytes },
                referenceBlockId: referenceBlockId.bytes,
                gasLimit: gasLimit,
                proposalKeyAddress: proposalKey.address.bytes,
                proposalKeyIndex: proposalKey.keyIndex,
                proposalKeySequenceNumber: proposalKey.sequenceNumber,
                payer: payerAddress.bytes,
                authorizers: authorizers.compactMap { $0.bytes })
    }

    init(value: Flow_Entities_Transaction) {
        script = FlowScript(bytes: value.script.byteArray)
        arguments = value.arguments.compactMap { FlowArgument(bytes: $0.byteArray) }
        referenceBlockId = FlowId(bytes: value.referenceBlockID.byteArray)
        gasLimit = value.gasLimit
        proposalKey = FlowTransactionProposalKey(value: value.proposalKey)
        payerAddress = FlowAddress(bytes: value.payer.byteArray)
        authorizers = value.authorizers.compactMap { FlowAddress(bytes: $0.byteArray) }
        payloadSignatures = value.payloadSignatures.compactMap { FlowTransactionSignature(value: $0) }
        envelopeSignatures = value.envelopeSignatures.compactMap { FlowTransactionSignature(value: $0) }
    }
}
