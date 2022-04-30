//
//  File.swift
//
//
//  Created by Hao Fu on 28/1/22.
//

import BigInt
import Foundation

extension Flow.Transaction: Codable {
    enum CodingKeys: String, CodingKey {
        case script
        case arguments
        case referenceBlockId
        case gasLimit
        case proposalKey
        case payerAddress
        case authorizers
        case payloadSignatures
        case envelopeSignatures
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(script, forKey: .script)
        try container.encode(arguments, forKey: .arguments)
        try container.encode(referenceBlockId, forKey: .referenceBlockId)
        try container.encode(UInt64(gasLimit), forKey: .gasLimit)
        try container.encode(proposalKey, forKey: .proposalKey)
        try container.encode(payerAddress, forKey: .payerAddress)
        try container.encode(authorizers, forKey: .authorizers)
        try container.encode(payloadSignatures, forKey: .payloadSignatures)
        try container.encode(envelopeSignatures, forKey: .envelopeSignatures)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        script = try container.decode(Flow.Script.self, forKey: .script)
        arguments = try container.decode([Flow.Argument].self, forKey: .arguments)
        referenceBlockId = try container.decode(Flow.ID.self, forKey: .referenceBlockId)
        gasLimit = BigUInt(try container.decode(UInt64.self, forKey: .gasLimit))
        proposalKey = try container.decode(Flow.TransactionProposalKey.self, forKey: .proposalKey)
        payerAddress = try container.decode(Flow.Address.self, forKey: .payerAddress)
        authorizers = try container.decode([Flow.Address].self, forKey: .authorizers)
        payloadSignatures = try container.decode([Flow.TransactionSignature].self, forKey: .payloadSignatures)
        envelopeSignatures = try container.decode([Flow.TransactionSignature].self, forKey: .envelopeSignatures)
    }
}
