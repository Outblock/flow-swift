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
        case payer
        case authorizers
        case payloadSignatures
        case envelopeSignatures
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(script.data.base64EncodedString(), forKey: .script)
        try container.encode(arguments.compactMap { $0.jsonString?.data(using: .utf8)?.base64EncodedString() }, forKey: .arguments)
        try container.encode(referenceBlockId, forKey: .referenceBlockId)
        try container.encode(String(gasLimit), forKey: .gasLimit)
        try container.encode(proposalKey, forKey: .proposalKey)
        try container.encode(payer, forKey: .payer)
        try container.encode(authorizers, forKey: .authorizers)
        try container.encode(payloadSignatures, forKey: .payloadSignatures)
        try container.encode(envelopeSignatures, forKey: .envelopeSignatures)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        script = try container.decode(Flow.Script.self, forKey: .script)
        let argumentsArray = try container.decode([String].self, forKey: .arguments)
        arguments = try argumentsArray.compactMap { Data(base64Encoded: $0) }.compactMap { data in
            try JSONDecoder().decode(Flow.Argument.self, from: data)
        }
        referenceBlockId = try container.decode(Flow.ID.self, forKey: .referenceBlockId)
        let gasLimitString = try container.decode(String.self, forKey: .gasLimit)
        gasLimit = BigUInt(gasLimitString) ?? BigUInt(0)
        proposalKey = try container.decode(Flow.TransactionProposalKey.self, forKey: .proposalKey)
        payer = try container.decode(Flow.Address.self, forKey: .payer)
        authorizers = try container.decode([Flow.Address].self, forKey: .authorizers)
        payloadSignatures = try container.decode([Flow.TransactionSignature].self, forKey: .payloadSignatures)
        envelopeSignatures = try container.decode([Flow.TransactionSignature].self, forKey: .envelopeSignatures)
    }
}
