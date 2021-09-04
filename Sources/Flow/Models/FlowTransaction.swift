//
//  FlowTransaction.swift
//
//
//  Created by lmcmz on 19/7/21.
//

import Foundation

extension Flow {
    struct FlowArgument: BytesHolder {
        var bytes: [UInt8]
        // TODO: - Add jsonCadence
        //    var jsonCadence:
    }

    struct TransactionProposalKey {
        let address: Address
        let keyIndex: UInt32
        let sequenceNumber: UInt64

        init(address: Flow.Address, keyIndex: UInt32, sequenceNumber: UInt64) {
            self.address = address
            self.keyIndex = keyIndex
            self.sequenceNumber = sequenceNumber
        }

        init(value: Flow_Entities_Transaction.ProposalKey) {
            address = Address(bytes: value.address.byteArray)
            keyIndex = value.keyID
            sequenceNumber = value.sequenceNumber
        }

        func toFlowEntity() -> Flow_Entities_Transaction.ProposalKey {
            var entity = Flow_Entities_Transaction.ProposalKey()
            entity.address = address.bytes.data
            entity.keyID = keyIndex
            entity.sequenceNumber = sequenceNumber
            return entity
        }
    }

    struct TransactionSignature {
        let address: Address
        var signerIndex: Int
        let keyIndex: Int
        let signature: Signature

        init(value: Flow_Entities_Transaction.Signature) {
            address = Address(bytes: value.address.byteArray)
            keyIndex = Int(value.keyID)
            signature = Signature(bytes: value.signature.byteArray)
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

    internal struct PayloadEnvelope {
        var payload: Payload
        var payloadSignatures: [EnvelopeSignature]
    }

    internal struct EnvelopeSignature {
        let signerIndex: Int
        let keyIndex: Int
        let signature: ByteArray
    }

    internal struct PaymentEnvelope {
        var payloadEnvelope: PayloadEnvelope
        var envelopeSignatures: [EnvelopeSignature]
    }

    struct Transaction {
        let script: Script
        let arguments: [FlowArgument]
        let referenceBlockId: Id
        let gasLimit: UInt64
        let proposalKey: TransactionProposalKey
        let payerAddress: Address
        let authorizers: [Address]
        var payloadSignatures: [TransactionSignature] = []
        var envelopeSignatures: [TransactionSignature] = []

        init(script: Flow.Script, arguments: [Flow.FlowArgument], referenceBlockId: Flow.Id, gasLimit: UInt64, proposalKey: Flow.TransactionProposalKey, payerAddress: Flow.Address, authorizers: [Flow.Address], payloadSignatures: [Flow.TransactionSignature] = [], envelopeSignatures: [Flow.TransactionSignature] = []) {
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

        func buildUpOn(script: Flow.Script? = nil,
                       arguments: [Flow.FlowArgument]? = nil,
                       referenceBlockId: Flow.Id? = nil,
                       gasLimit: UInt64? = nil,
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
            return RLP.encode([preparePayload, preparePayloadSignatures])
        }

        var encodedPayload: Data? {
            return RLP.encode(preparePayload)
        }

        private var payload: Payload {
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

        var payment: PaymentEnvelope {
            PaymentEnvelope(payloadEnvelope: authorization,
                            envelopeSignatures: envelopeSignatures.compactMap {
                                EnvelopeSignature(signerIndex: $0.signerIndex,
                                                  keyIndex: $0.keyIndex,
                                                  signature: $0.signature.bytes)
            })
        }

        var authorization: PayloadEnvelope {
            PayloadEnvelope(payload: payload,
                            payloadSignatures: payloadSignatures.compactMap {
                                EnvelopeSignature(signerIndex: $0.signerIndex,
                                                  keyIndex: $0.keyIndex,
                                                  signature: $0.signature.bytes)
            })
        }

        var canonicalPayload: ByteArray? {
            // TODO: Need fix this, RLP not support encode object
            RLP.encode(payload)?.byteArray
        }

        var preparePayload: [Any] {
            return [
                script.bytes.data,
                [], // Flow Argument
                referenceBlockId.bytes.paddingZeroLeft(blockSize: 32).data,
                Int(gasLimit),
                proposalKey.address.bytes.paddingZeroLeft(blockSize: 8).data,
                Int(proposalKey.keyIndex),
                Int(proposalKey.sequenceNumber),
                payerAddress.bytes.paddingZeroLeft(blockSize: 8).data,
                authorizers.map { $0.bytes.paddingZeroLeft(blockSize: 8).data },
            ]
        }

        var preparePayloadSignatures: [Any] {
            return payloadSignatures
                .map { sig in
                    TransactionSignature(address: sig.address,
                                         signerIndex: signers[sig.address.stringValue] ?? 0,
                                         keyIndex: sig.keyIndex,
                                         signature: sig.signature)
                }
                .sorted { a, b in
                    if a.signerIndex == b.signerIndex {
                        return a.keyIndex < b.keyIndex
                    }
                    return a.signerIndex < b.signerIndex
                }.map { sig in
                    [Int(sig.signerIndex), Int(sig.keyIndex), sig.signature.bytes.data]
                }
        }

        private var signers: [String: Int] {
            var i = 0
            var signer = [String: Int]()

            func addSigner(address: String) {
                if !signer.keys.contains(address) {
                    signer[address] = i
                    i += 1
                }
            }

            addSigner(address: proposalKey.address.stringValue)
            addSigner(address: payerAddress.stringValue)
            authorizers.forEach { addSigner(address: $0.stringValue) }
            return signer
        }

        var canonicalAuthorizationEnvelope: ByteArray? {
            // TODO: Need fix this, RLP not support encode object
            RLP.encode(authorization)?.byteArray
        }

        var canonicalPaymentEnvelope: ByteArray? {
            // TODO: Need fix this, RLP not support encode object
            RLP.encode(payment)?.byteArray
        }

        var signerList: [Address] {
            var ret = [Address]()
            var seen = [Address]()
            func addSigner(_ address: Address) {
                if seen.contains(address) {
                    return
                }
                ret.append(address)
                seen.append(address)
            }
            addSigner(proposalKey.address)
            addSigner(payerAddress)
            authorizers.forEach(addSigner)
            return ret
        }

        var signerMap: [Address: Int] {
            signerList.enumerated().reduce(into: [Address: Int]()) { result, next in
                result[next.element] = next.offset
            }
        }

        init(value: Flow_Entities_Transaction) {
            script = Script(bytes: value.script.byteArray)
            arguments = value.arguments.compactMap { FlowArgument(bytes: $0.byteArray) }
            referenceBlockId = Id(bytes: value.referenceBlockID.byteArray)
            gasLimit = value.gasLimit
            proposalKey = TransactionProposalKey(value: value.proposalKey)
            payerAddress = Address(bytes: value.payer.byteArray)
            authorizers = value.authorizers.compactMap { Address(bytes: $0.byteArray) }
            payloadSignatures = value.payloadSignatures.compactMap { TransactionSignature(value: $0) }
            envelopeSignatures = value.envelopeSignatures.compactMap { TransactionSignature(value: $0) }
        }

        func toFlowEntity() -> Flow_Entities_Transaction {
            var transaction = Flow_Entities_Transaction()
            transaction.script = script.bytes.data
            transaction.arguments = arguments.compactMap { $0.bytes.data }
            transaction.referenceBlockID = referenceBlockId.bytes.data
            transaction.gasLimit = gasLimit
            transaction.proposalKey = proposalKey.toFlowEntity()
            transaction.payer = payerAddress.bytes.data
            transaction.authorizers = authorizers.compactMap { $0.bytes.data }
            transaction.payloadSignatures = payloadSignatures.compactMap { $0.toFlowEntity() }
            transaction.envelopeSignatures = envelopeSignatures.compactMap { $0.toFlowEntity() }
            return transaction
        }

        mutating func addPayloadSignature(address: Address, keyIndex: Int, signer: Signer) -> Self {
            guard let canonicalPayload = canonicalPayload else { return self }
            return addPayloadSignature(address: address,
                                       keyIndex: keyIndex,
                                       signature: Signature(bytes: signer.signAsTransaction(bytes: canonicalPayload)))
        }

        mutating func addPayloadSignature(address: Address, keyIndex: Int, signature: Signature) -> Self {
            payloadSignatures.append(
                TransactionSignature(address: address,
                                     signerIndex: signerMap[address] ?? -1,
                                     keyIndex: keyIndex,
                                     signature: signature)
            )

            payloadSignatures = payloadSignatures.sorted { t1, t2 in
                if t1.signerIndex == t2.signerIndex {
                    return t1.keyIndex > t2.keyIndex
                }
                return t1.signerIndex > t2.signerIndex
            }
            return self
        }

        mutating func addEnvelopeSignature(address: Address, keyIndex: Int, signer: Signer) -> Self {
            guard let data = canonicalAuthorizationEnvelope else {
                return self
            }

            return addEnvelopeSignature(address: address,
                                        keyIndex: keyIndex,
                                        signature: Signature(bytes: signer.signAsTransaction(bytes: data)))
        }

        mutating func addEnvelopeSignature(address: Address, keyIndex: Int, signature: Signature) -> Self {
            envelopeSignatures.append(
                TransactionSignature(address: address,
                                     signerIndex: signerMap[address] ?? -1,
                                     keyIndex: keyIndex,
                                     signature: signature)
            )

            envelopeSignatures = envelopeSignatures.sorted { t1, t2 in
                if t1.signerIndex == t2.signerIndex {
                    return t1.keyIndex > t2.keyIndex
                }
                return t1.signerIndex > t2.signerIndex
            }
            return self
        }

        func updateSignerIndices() -> Transaction {
            let map = signerMap
            var payloadSig = payloadSignatures
            var envelopeSig = envelopeSignatures
            for (index, sig) in payloadSig.enumerated() {
                if map.keys.contains(sig.address) {
                    continue
                }
                payloadSig[index].signerIndex = index
            }
            for (index, sig) in envelopeSig.enumerated() {
                if map.keys.contains(sig.address) {
                    continue
                }
                envelopeSig[index].signerIndex = index
            }

            var transaction = self
            transaction.payloadSignatures = payloadSig
            transaction.envelopeSignatures = envelopeSig
            return transaction
        }

        enum Status: Int, CaseIterable {
            case unknown
            case pending
            case finalized
            case executed
            case sealed
            case expired

            init(num: Int) {
                self = Status.allCases.first { $0.rawValue == num } ?? .unknown
            }
        }
    }

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

    struct Signature: BytesHolder, Equatable {
        var bytes: [UInt8]

        init(hex: String) {
            bytes = hex.hexValue
        }

        init(bytes: [UInt8]) {
            self.bytes = bytes
        }
    }
}
