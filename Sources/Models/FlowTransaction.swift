//
//  FlowTransaction
//
//  Copyright 2022 Outblock Pty Ltd
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
import BigInt
import Foundation

// TODO: Add doc
public extension Flow {
    /// The data structure of Transaction
    struct Transaction {
        /// A valid cadence script.
        public var script: Script

        /// Any arguments to the script if needed should be supplied via a function that returns an array of arguments.
        public var arguments: [Argument]

        /// The ID of the block to execute the interaction at.
        public var referenceBlockId: ID

        /// Compute (Gas) limit for query. Read the documentation about computation cost for information about how computation cost is calculated on Flow.
        /// More detail here: https://docs.onflow.org/flow-go-sdk/building-transactions/#gas-limit
        public var gasLimit: BigUInt

        /// The valid key of proposer role.
        public var proposalKey: TransactionProposalKey

        /// The address of payer
        public var payer: Address

        /// The list of authorizer's address
        public var authorizers: [Address]

        /// The list of payload signature
        public var payloadSignatures: [TransactionSignature] = []

        /// The list of envelope signature
        public var envelopeSignatures: [TransactionSignature] = []

        public init(script: Flow.Script,
                    arguments: [Flow.Argument],
                    referenceBlockId: Flow.ID,
                    gasLimit: BigUInt,
                    proposalKey: Flow.TransactionProposalKey,
                    payer: Flow.Address,
                    authorizers: [Flow.Address],
                    payloadSignatures: [Flow.TransactionSignature] = [],
                    envelopeSignatures: [Flow.TransactionSignature] = [])
        {
            self.script = script
            self.arguments = arguments
            self.referenceBlockId = referenceBlockId
            self.gasLimit = gasLimit
            self.proposalKey = proposalKey
            self.payer = payer
            self.authorizers = authorizers
            self.payloadSignatures = payloadSignatures
            self.envelopeSignatures = envelopeSignatures
        }

        public init(script: Flow.Script,
                    arguments: [Flow.Argument],
                    referenceBlockId: Flow.ID,
                    gasLimit: UInt64,
                    proposalKey: Flow.TransactionProposalKey,
                    payer: Flow.Address,
                    authorizers: [Flow.Address],
                    payloadSignatures: [Flow.TransactionSignature] = [],
                    envelopeSignatures: [Flow.TransactionSignature] = [])
        {
            self.script = script
            self.arguments = arguments
            self.referenceBlockId = referenceBlockId
            self.gasLimit = BigUInt(gasLimit)
            self.proposalKey = proposalKey
            self.payer = payer
            self.authorizers = authorizers
            self.payloadSignatures = payloadSignatures
            self.envelopeSignatures = envelopeSignatures
        }

        public func buildUpOn(script: Flow.Script? = nil,
                              arguments: [Flow.Argument]? = nil,
                              referenceBlockId: Flow.ID? = nil,
                              gasLimit: BigUInt? = nil,
                              proposalKey: Flow.TransactionProposalKey? = nil,
                              payer: Flow.Address? = nil,
                              authorizers: [Flow.Address]? = nil,
                              payloadSignatures: [Flow.TransactionSignature]? = nil,
                              envelopeSignatures: [Flow.TransactionSignature]? = nil) -> Transaction
        {
            return Transaction(script: script ?? self.script,
                               arguments: arguments ?? self.arguments,
                               referenceBlockId: referenceBlockId ?? self.referenceBlockId,
                               gasLimit: gasLimit ?? self.gasLimit,
                               proposalKey: proposalKey ?? self.proposalKey,
                               payer: payer ?? self.payer,
                               authorizers: authorizers ?? self.authorizers,
                               payloadSignatures: payloadSignatures ?? self.payloadSignatures,
                               envelopeSignatures: envelopeSignatures ?? self.envelopeSignatures)
        }

        /// RLP Encoded data of Envelope
        public var encodedEnvelope: Data? {
            return RLP.encode(payloadEnvelope.rlpList)
        }

        /// RLP Encoded data of Envelope in hex string
        public var envelopeMessage: String? {
            guard let data = RLP.encode(payloadEnvelope.rlpList) else { return nil }
            return data.hexValue
        }

        /// RLP Encoded data of Envelope with `DomainTag.transaction` prefix
        public var signableEnvelope: Data? {
            guard let data = RLP.encode(payloadEnvelope.rlpList) else { return nil }
            return DomainTag.transaction.normalize + data
        }

        /// RLP Encoded data of Payload
        public var encodedPayload: Data? {
            return RLP.encode(payload.rlpList)
        }

        /// RLP Encoded data of Payload in hex string
        public var payloadMessage: String? {
            guard let data = RLP.encode(payload.rlpList) else { return nil }
            return data.hexValue
        }

        /// RLP Encoded data of Payload with `DomainTag.transaction` prefix
        public var signablePlayload: Data? {
            guard let data = RLP.encode(payload.rlpList) else { return nil }
            return DomainTag.transaction.normalize + data
        }

        var payload: Transaction.Payload {
            Flow.Transaction.Payload(script: script.data,
                                     arguments: arguments.compactMap { $0.jsonData },
                                     referenceBlockId: referenceBlockId.data.paddingZeroLeft(blockSize: 32),
                                     gasLimit: gasLimit,
                                     proposalKeyAddress: proposalKey.address.data.paddingZeroLeft(blockSize: 8),
                                     proposalKeyIndex: proposalKey.keyIndex,
                                     proposalKeySequenceNumber: BigUInt(proposalKey.sequenceNumber),
                                     payerData: payer.data.paddingZeroLeft(blockSize: 8),
                                     authorizers: authorizers.map { $0.data.paddingZeroLeft(blockSize: 8) })
        }

        var payloadEnvelope: PayloadEnvelope {
            let signatures = payloadSignatures
                .map { sig in
                    EnvelopeSignature(signerIndex: signers[sig.address] ?? -1,
                                      keyIndex: sig.keyIndex,
                                      signature: sig.signature)
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
            addSigner(address: payer)
            authorizers.forEach { addSigner(address: $0) }
            return signer
        }

        public mutating func updateScript(script: Flow.Script) {
            self.script = script
        }

        public mutating func addPayloadSignature(_ signature: TransactionSignature) {
            payloadSignatures.append(signature)
            payloadSignatures = payloadSignatures.sorted(by: <)
        }

        public mutating func addPayloadSignature(address: Address, keyIndex: Int, signature: Data) {

            // Avoid same signer with multiple signatures
            for sig in payloadSignatures {
                if sig.keyIndex == keyIndex && sig.address == address {
                    return
                }
            }
            
            payloadSignatures.append(
                TransactionSignature(address: address,
                                     signerIndex: signers[address] ?? -1,
                                     keyIndex: keyIndex,
                                     signature: signature)
            )
            payloadSignatures = payloadSignatures.sorted(by: <)
        }

        public mutating func addEnvelopeSignature(address: Address, keyIndex: Int, signature: Data) {
            
            // Avoid same signer with multiple signatures
            for sig in envelopeSignatures {
                if sig.keyIndex == keyIndex && sig.address == address {
                    return
                }
            }
            
            envelopeSignatures.append(
                TransactionSignature(address: address,
                                     signerIndex: signers[address] ?? -1,
                                     keyIndex: keyIndex,
                                     signature: signature)
            )
            envelopeSignatures = envelopeSignatures.sorted(by: <)
        }

        public mutating func addEnvelopeSignature(_ signature: TransactionSignature) {
            envelopeSignatures.append(signature)
            envelopeSignatures = envelopeSignatures.sorted(by: <)
        }

        func getSingerIndex(address: Flow.Address) -> Int? {
            return signers.first { $0.key == address }?.value
        }
    }
}

protocol RLPEncodable {
    var rlpList: [Any] { get }
}

extension Flow.Transaction {
    /// The transaction status
    public enum Status: Int, CaseIterable, Comparable, Equatable, Codable {
        case unknown = 0
        case pending = 1
        case finalized = 2
        case executed = 3
        case sealed = 4
        case expired = 5

        var stringValue: String {
            switch self {
            case .unknown:
                return "Unknown"
            case .pending:
                return "Pending"
            case .executed:
                return "Executed"
            case .sealed:
                return "Sealed"
            case .expired:
                return "Expired"
            case .finalized:
                return "Finalized"
            }
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)
            self.init(value)
        }

        init(_ rawString: String) {
            self = Status.allCases.first { $0.stringValue == rawString } ?? .unknown
        }

        public init(_ rawValue: Int) {
            self = Status.allCases.first { $0.rawValue == rawValue } ?? .unknown
        }

        public static func < (lhs: Flow.Transaction.Status, rhs: Flow.Transaction.Status) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    /// Internal struct for payload RLP encoding
    struct Payload: RLPEncodable {
        let script: Data
        let arguments: [Data]
        let referenceBlockId: Data
        let gasLimit: BigUInt
        let proposalKeyAddress: Data
        let proposalKeyIndex: Int
        let proposalKeySequenceNumber: BigUInt
        let payerData: Data
        let authorizers: [Data]

        var rlpList: [Any] {
            let mirror = Mirror(reflecting: self)
            return mirror.children.compactMap { $0.value }
        }
    }

    /// Internal struct for Envelope RLP encoding
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

public extension Flow {
    /// The transaction result in the chain
    struct TransactionResult: Codable {
        /// The status of transaction
        public let status: Transaction.Status

        /// The error message for the transaction
        public let errorMessage: String

        /// The emitted events by this transaction
        public let events: [Event]

        /// The status code of transaction
        let statusCode: Int

        public let blockId: ID

        public let computationUsed: String

        public init(status: Transaction.Status, errorMessage: String, events: [Event], statusCode: Int, blockId: ID, computationUsed: String) {
            self.status = status
            self.errorMessage = errorMessage
            self.events = events
            self.statusCode = statusCode
            self.blockId = blockId
            self.computationUsed = computationUsed
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            status = try container.decode(Flow.Transaction.Status.self, forKey: .status)
            errorMessage = try container.decode(String.self, forKey: .errorMessage)
            events = try container.decode([Flow.Event].self, forKey: .events)
            statusCode = try container.decode(Int.self, forKey: .statusCode)
            blockId = try container.decode(Flow.ID.self, forKey: .blockId)
            computationUsed = try container.decode(String.self, forKey: .computationUsed)
        }
        
        public var errorCode: FvmErrorCode? {
            guard !errorMessage.isEmpty else { return nil }
            return FvmErrorCode.allCases.first(where: { errorMessage.contains($0.errorTag) })
        }
    }

    /// The class to represent the proposer key information in the transaction
    struct TransactionProposalKey {
        /// The address of account
        public let address: Address

        /// The index of public key in account
        public var keyIndex: Int

        /// The sequence numbers to ensure that each transaction runs at most once
        /// Similarly to transaction nonces in Ethereum
        /// If sequenceNumber is -1, fetch the lastest onchain
        public var sequenceNumber: BigInt

        public init(address: Flow.Address, keyIndex: Int = 0) {
            self.address = address
            self.keyIndex = keyIndex
            sequenceNumber = -1
        }

        public init(address: Flow.Address, keyIndex: Int = 0, sequenceNumber: Int64 = -1) {
            self.address = address
            self.keyIndex = keyIndex
            self.sequenceNumber = BigInt(sequenceNumber)
        }
    }

    struct TransactionSignature: Comparable {
        /// The address of the signature
        public let address: Address

        /// The index of the signed key
        public let keyIndex: Int

        /// Signature Data
        public let signature: Data

        /// Interal index for sort signature
        var signerIndex: Int

        public init(address: Flow.Address, keyIndex: Int, signature: Data) {
            self.address = address
            signerIndex = keyIndex
            self.keyIndex = keyIndex
            self.signature = signature
        }

        internal init(address: Flow.Address, signerIndex: Int, keyIndex: Int, signature: Data) {
            self.address = address
            self.signerIndex = signerIndex
            self.keyIndex = keyIndex
            self.signature = signature
        }

        public static func < (lhs: Flow.TransactionSignature, rhs: Flow.TransactionSignature) -> Bool {
            if lhs.signerIndex == rhs.signerIndex {
                return lhs.keyIndex < rhs.keyIndex
            }
            return lhs.signerIndex < rhs.signerIndex
        }

        internal func buildUpon(address: Flow.Address? = nil,
                                signerIndex: Int? = nil,
                                keyIndex: Int? = nil,
                                signature: Data? = nil) -> TransactionSignature
        {
            return TransactionSignature(address: address ?? self.address,
                                        signerIndex: signerIndex ?? self.signerIndex,
                                        keyIndex: keyIndex ?? self.keyIndex,
                                        signature: signature ?? self.signature)
        }
    }
}

extension Flow.TransactionProposalKey: Codable {
    enum CodingKeys: String, CodingKey {
        case address
        case keyIndex
        case sequenceNumber
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(address, forKey: .address)
        try container.encode(String(keyIndex), forKey: .keyIndex)
        try container.encode(String(sequenceNumber), forKey: .sequenceNumber)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        address = try container.decode(Flow.Address.self, forKey: .address)
        let keyIndex = try container.decode(String.self, forKey: .keyIndex)
        self.keyIndex = Int(keyIndex) ?? -1
        let sequenceNumber = try container.decode(String.self, forKey: .sequenceNumber)
        self.sequenceNumber = BigInt(sequenceNumber) ?? BigInt(-1)
    }
}

extension Flow.TransactionSignature: Codable {
    enum CodingKeys: String, CodingKey {
        case address
        case keyIndex
        case signature
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(address, forKey: .address)
        try container.encode(String(keyIndex), forKey: .keyIndex)
        try container.encode(signature.base64EncodedString(), forKey: .signature)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        address = try container.decode(Flow.Address.self, forKey: .address)
        let keyIndex = try container.decode(String.self, forKey: .keyIndex)
        self.keyIndex = Int(keyIndex) ?? -1
        let signatureString = try container.decode(String.self, forKey: .signature)
        signature = Data(base64Encoded: signatureString) ?? signatureString.hexValue.data
        signerIndex = -1
    }
}
