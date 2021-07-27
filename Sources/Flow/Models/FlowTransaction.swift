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
        let signerIndex: UInt32
        let keyIndex: UInt32
        let signature: Signature

        init(value: Flow_Entities_Transaction.Signature) {
            address = Address(bytes: value.address.byteArray)
            keyIndex = value.keyID
            signature = Signature(bytes: value.signature.byteArray)
            signerIndex = value.keyID
        }

        init(address: Flow.Address, signerIndex: UInt32, keyIndex: UInt32, signature: Flow.Signature) {
            self.address = address
            self.signerIndex = signerIndex
            self.keyIndex = keyIndex
            self.signature = signature
        }

        func toFlowEntity() -> Flow_Entities_Transaction.Signature {
            var entity = Flow_Entities_Transaction.Signature()
            entity.address = address.bytes.data
            entity.keyID = keyIndex
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
        let signerIndex: UInt32
        let keyIndex: UInt32
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

        lazy var payment: PaymentEnvelope = {
            PaymentEnvelope(payloadEnvelope: authorization,
                            envelopeSignatures: envelopeSignatures.compactMap {
                                EnvelopeSignature(signerIndex: $0.signerIndex,
                                                  keyIndex: $0.keyIndex,
                                                  signature: $0.signature.bytes)
            })
        }()

        lazy var authorization: PayloadEnvelope = {
            PayloadEnvelope(payload: payload,
                            payloadSignatures: payloadSignatures.compactMap {
                                EnvelopeSignature(signerIndex: $0.signerIndex,
                                                  keyIndex: $0.keyIndex,
                                                  signature: $0.signature.bytes)
            })
        }()

        lazy var canonicalPayload: Data? = {
            RLP.encode(payload)
        }()

        lazy var canonicalAuthorizationEnvelope: Data? = {
            RLP.encode(authorization)
        }()

        lazy var canonicalPaymentEnvelope: Data? = {
            RLP.encode(payment)
        }()

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

        lazy var signerMap: [Address: Int] = {
            signerList.enumerated().reduce(into: [Address: Int]()) { result, next in
                result[next.element] = next.offset
            }
        }()

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

        mutating func addPayloadSignature(address: Address, keyIndex: UInt32, signer: Signer) -> Transaction {
            guard let canonicalPayload = canonicalPayload else { return self }
            return addPayloadSignature(address: address,
                                       keyIndex: keyIndex,
                                       signature: Flow.Signature(bytes: signer.signAsTransaction(bytes: canonicalPayload.byteArray)))
        }

        mutating func addPayloadSignature(address: Address, keyIndex: UInt32, signature: Signature) -> Transaction {
            payloadSignatures.append(
                TransactionSignature(address: address,
                                     signerIndex: keyIndex,
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
