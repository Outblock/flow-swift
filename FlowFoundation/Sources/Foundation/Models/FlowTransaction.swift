//
//  FlowTransaction.swift
//
//
//  Created by lmcmz on 19/7/21.
//

import BigInt
import Foundation

extension Flow {
    struct Transaction {
        let script: Script
        let arguments: [Argument]
        let referenceBlockId: Id
        let gasLimit: BigUInt
        let proposalKey: TransactionProposalKey
        let payerAddress: Address
        let authorizers: [Address]
        var payloadSignatures: [TransactionSignature] = []
        var envelopeSignatures: [TransactionSignature] = []

        init(script: Flow.Script, arguments: [Flow.Argument], referenceBlockId: Flow.Id, gasLimit: BigUInt, proposalKey: Flow.TransactionProposalKey, payerAddress: Flow.Address, authorizers: [Flow.Address], payloadSignatures: [Flow.TransactionSignature] = [], envelopeSignatures: [Flow.TransactionSignature] = []) {
            self.script = script
            self.arguments = arguments
            self.referenceBlockId = referenceBlockId
            self.gasLimit = gasLimit
            self.proposalKey = proposalKey
            self.payerAddress = payerAddress
            self.authorizers = authorizers
            self.payloadSignatures = payloadSignatures
            self.envelopeSignatures = envelopeSignatures
        }

        init(value: Flow_Entities_Transaction) {
            script = Script(bytes: value.script.bytes)
            arguments = value.arguments.compactMap { try! JSONDecoder().decode(Argument.self, from: $0) }
            referenceBlockId = Id(bytes: value.referenceBlockID.bytes)
            gasLimit = BigUInt(value.gasLimit)
            proposalKey = TransactionProposalKey(value: value.proposalKey)
            payerAddress = Address(bytes: value.payer.bytes)
            authorizers = value.authorizers.compactMap { Address(bytes: $0.bytes) }
            payloadSignatures = value.payloadSignatures.compactMap { TransactionSignature(value: $0) }
            envelopeSignatures = value.envelopeSignatures.compactMap { TransactionSignature(value: $0) }
        }

        func toFlowEntity() -> Flow_Entities_Transaction {
            var transaction = Flow_Entities_Transaction()
            transaction.script = script.bytes.data
            transaction.arguments = arguments.compactMap { try! JSONEncoder().encode($0) }
            transaction.referenceBlockID = referenceBlockId.bytes.data
            transaction.gasLimit = UInt64(gasLimit)
            transaction.proposalKey = proposalKey.toFlowEntity()
            transaction.payer = payerAddress.bytes.data
            transaction.authorizers = authorizers.compactMap { $0.bytes.data }
            transaction.payloadSignatures = payloadSignatures.compactMap { $0.toFlowEntity() }
            transaction.envelopeSignatures = envelopeSignatures.compactMap { $0.toFlowEntity() }
            return transaction
        }

        func buildUpOn(script: Flow.Script? = nil,
                       arguments: [Flow.Argument]? = nil,
                       referenceBlockId: Flow.Id? = nil,
                       gasLimit: BigUInt? = nil,
                       proposalKey: Flow.TransactionProposalKey? = nil,
                       payerAddress: Flow.Address? = nil,
                       authorizers: [Flow.Address]? = nil,
                       payloadSignatures: [Flow.TransactionSignature]? = nil,
                       envelopeSignatures: [Flow.TransactionSignature]? = nil) -> Transaction {
            return Transaction(script: script ?? self.script,
                               arguments: arguments ?? self.arguments,
                               referenceBlockId: referenceBlockId ?? self.referenceBlockId,
                               gasLimit: gasLimit ?? self.gasLimit,
                               proposalKey: proposalKey ?? self.proposalKey,
                               payerAddress: payerAddress ?? self.payerAddress,
                               authorizers: authorizers ?? self.authorizers,
                               payloadSignatures: payloadSignatures ?? self.payloadSignatures,
                               envelopeSignatures: envelopeSignatures ?? self.envelopeSignatures)
        }

        var encodedEnvelope: Data? {
            return RLP.encode(payloadEnvelope.rlpList)
        }

        var encodedPayload: Data? {
            return RLP.encode(payload.rlpList)
        }

        var payload: Transaction.Payload {
            Flow.Transaction.Payload(script: script.data,
                                     arguments: arguments.compactMap { $0.jsonData },
                                     referenceBlockId: referenceBlockId.data.paddingZeroLeft(blockSize: 32),
                                     gasLimit: gasLimit,
                                     proposalKeyAddress: proposalKey.address.data.paddingZeroLeft(blockSize: 8),
                                     proposalKeyIndex: proposalKey.keyIndex,
                                     proposalKeySequenceNumber: proposalKey.sequenceNumber,
                                     payer: payerAddress.data.paddingZeroLeft(blockSize: 8),
                                     authorizers: authorizers.map { $0.data.paddingZeroLeft(blockSize: 8) })
        }

        var payloadEnvelope: PayloadEnvelope {
            let signatures = payloadSignatures
                .map { sig in
                    EnvelopeSignature(signerIndex: signers[sig.address] ?? 0, keyIndex: sig.keyIndex, signature: sig.signature.data)
                }
                .sorted(by: <)
            return PayloadEnvelope(payload: payload, payloadSignatures: signatures)
        }

        private var signers: [Address: Int] {
            var i = 0
            var signer = [Address: Int]()

            func addSigner(address: Address) {
                if !signer.keys.contains(address) {
                    signer[address] = i
                    i += 1
                }
            }
            addSigner(address: proposalKey.address)
            addSigner(address: payerAddress)
            authorizers.forEach { addSigner(address: $0) }
            return signer
        }

//        var payment: PaymentEnvelope {
//            PaymentEnvelope(payloadEnvelope: authorization,
//                            envelopeSignatures: envelopeSignatures.compactMap {
//                                EnvelopeSignature(signerIndex: $0.signerIndex,
//                                                  keyIndex: $0.keyIndex,
//                                                  signature: $0.signature.bytes)
//            })
//        }
//
//        var authorization: PayloadEnvelope {
//            PayloadEnvelope(payload: payload,
//                            payloadSignatures: payloadSignatures.compactMap {
//                                EnvelopeSignature(signerIndex: $0.signerIndex,
//                                                  keyIndex: $0.keyIndex,
//                                                  signature: $0.signature.bytes)
//            })
//        }
//
//        var signerMap: [Address: Int] {
//            signerList.enumerated().reduce(into: [Address: Int]()) { result, next in
//                result[next.element] = next.offset
//            }
//        }
//
//        mutating func addPayloadSignature(address: Address, keyIndex: Int, signer: Signer) -> Self {
//            guard let canonicalPayload = canonicalPayload else { return self }
//            return addPayloadSignature(address: address,
//                                       keyIndex: keyIndex,
//                                       signature: Signature(bytes: signer.signAsTransaction(bytes: canonicalPayload)))
//        }
//
//        mutating func addPayloadSignature(address: Address, keyIndex: Int, signature: Signature) -> Self {
//            payloadSignatures.append(
//                TransactionSignature(address: address,
//                                     signerIndex: signerMap[address] ?? -1,
//                                     keyIndex: keyIndex,
//                                     signature: signature)
//            )
//
//            payloadSignatures = payloadSignatures.sorted { t1, t2 in
//                if t1.signerIndex == t2.signerIndex {
//                    return t1.keyIndex > t2.keyIndex
//                }
//                return t1.signerIndex > t2.signerIndex
//            }
//            return self
//        }
//
//        mutating func addEnvelopeSignature(address: Address, keyIndex: Int, signer: Signer) -> Self {
//            guard let data = canonicalAuthorizationEnvelope else {
//                return self
//            }
//
//            return addEnvelopeSignature(address: address,
//                                        keyIndex: keyIndex,
//                                        signature: Signature(bytes: signer.signAsTransaction(bytes: data)))
//        }
//
//        mutating func addEnvelopeSignature(address: Address, keyIndex: Int, signature: Signature) -> Self {
//            envelopeSignatures.append(
//                TransactionSignature(address: address,
//                                     signerIndex: signerMap[address] ?? -1,
//                                     keyIndex: keyIndex,
//                                     signature: signature)
//            )
//
//            envelopeSignatures = envelopeSignatures.sorted { t1, t2 in
//                if t1.signerIndex == t2.signerIndex {
//                    return t1.keyIndex > t2.keyIndex
//                }
//                return t1.signerIndex > t2.signerIndex
//            }
//            return self
//        }
//
//        func updateSignerIndices() -> Transaction {
//            let map = signerMap
//            var payloadSig = payloadSignatures
//            var envelopeSig = envelopeSignatures
//            for (index, sig) in payloadSig.enumerated() {
//                if map.keys.contains(sig.address) {
//                    continue
//                }
//                payloadSig[index].signerIndex = index
//            }
//            for (index, sig) in envelopeSig.enumerated() {
//                if map.keys.contains(sig.address) {
//                    continue
//                }
//                envelopeSig[index].signerIndex = index
//            }
//
//            var transaction = self
//            transaction.payloadSignatures = payloadSig
//            transaction.envelopeSignatures = envelopeSig
//            return transaction
//        }
    }
}

protocol RLPEncodable {
    var rlpList: [Any] { get }
}

extension Flow.Transaction {
    enum Status: Int, CaseIterable {
        case unknown = 0
        case pending
        case finalized
        case executed
        case sealed
        case expired

        init(num: Int) {
            self = Status.allCases.first { $0.rawValue == num } ?? .unknown
        }
    }

    struct Payload: RLPEncodable {
        let script: Data
        let arguments: [Data]
        let referenceBlockId: Data
        let gasLimit: BigUInt
        let proposalKeyAddress: Data
        let proposalKeyIndex: Int
        let proposalKeySequenceNumber: BigUInt
        let payer: Data
        let authorizers: [Data]

        var rlpList: [Any] {
            let mirror = Mirror(reflecting: self)
            return mirror.children.compactMap { $0.value }
        }
    }

    struct PayloadEnvelope: RLPEncodable {
        var payload: Payload
        var payloadSignatures: [EnvelopeSignature]

        var rlpList: [Any] {
            return [payload.rlpList, payloadSignatures.compactMap { sig in [sig.signerIndex, sig.keyIndex, sig.signature] }]
        }
    }

    struct EnvelopeSignature: Comparable, Equatable {
        let signerIndex: Int
        let keyIndex: Int
        let signature: Data

        static func < (lhs: Flow.Transaction.EnvelopeSignature, rhs: Flow.Transaction.EnvelopeSignature) -> Bool {
            if lhs.signerIndex == rhs.signerIndex {
                return lhs.keyIndex < rhs.keyIndex
            }
            return lhs.signerIndex < rhs.signerIndex
        }
    }

    struct PaymentEnvelope {
        var payloadEnvelope: PayloadEnvelope
        var envelopeSignatures: [EnvelopeSignature]
    }
}

extension Flow {
    struct TransactionResult {
        let status: Transaction.Status
        let statusCode: Int
        let errorMessage: String
        let events: [Event]

        init(value: Flow_Execution_GetTransactionResultResponse) {
            status = Transaction.Status(num: Int(value.statusCode))
            statusCode = Int(value.statusCode)
            errorMessage = value.errorMessage
            events = value.events.compactMap { Event(value: $0) }
        }

        init(value: Flow_Access_TransactionResultResponse) {
            status = Transaction.Status(num: Int(value.statusCode))
            statusCode = Int(value.statusCode)
            errorMessage = value.errorMessage
            events = value.events.compactMap { Flow.Event(value: $0) }
        }
    }

    struct TransactionProposalKey {
        let address: Address
        let keyIndex: Int
        let sequenceNumber: BigUInt

        init(address: Flow.Address, keyIndex: Int, sequenceNumber: BigUInt) {
            self.address = address
            self.keyIndex = keyIndex
            self.sequenceNumber = sequenceNumber
        }

        init(value: Flow_Entities_Transaction.ProposalKey) {
            address = Address(bytes: value.address.bytes)
            keyIndex = Int(value.keyID)
            sequenceNumber = BigUInt(value.sequenceNumber)
        }

        func toFlowEntity() -> Flow_Entities_Transaction.ProposalKey {
            var entity = Flow_Entities_Transaction.ProposalKey()
            entity.address = address.bytes.data
            entity.keyID = UInt32(keyIndex)
            entity.sequenceNumber = UInt64(sequenceNumber)
            return entity
        }
    }

    struct TransactionSignature {
        let address: Address
        var signerIndex: Int
        let keyIndex: Int
        let signature: Signature

        init(value: Flow_Entities_Transaction.Signature) {
            address = Address(bytes: value.address.bytes)
            keyIndex = Int(value.keyID)
            signature = Signature(data: value.signature)
            signerIndex = Int(value.keyID)
        }

        init(address: Flow.Address, signerIndex: Int, keyIndex: Int, signature: Flow.Signature) {
            self.address = address
            self.signerIndex = signerIndex
            self.keyIndex = keyIndex
            self.signature = signature
        }

        func buildUpon(address: Flow.Address? = nil,
                       signerIndex: Int? = nil,
                       keyIndex: Int? = nil,
                       signature: Flow.Signature? = nil) -> TransactionSignature {
            return TransactionSignature(address: address ?? self.address,
                                        signerIndex: signerIndex ?? self.signerIndex,
                                        keyIndex: keyIndex ?? self.keyIndex,
                                        signature: signature ?? self.signature)
        }

        func toFlowEntity() -> Flow_Entities_Transaction.Signature {
            var entity = Flow_Entities_Transaction.Signature()
            entity.address = address.bytes.data
            entity.keyID = UInt32(keyIndex)
            entity.signature = signature.bytes.data
            return entity
        }
    }
}
