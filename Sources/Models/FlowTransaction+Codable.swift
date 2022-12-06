//
//  CadenceTypeTest
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
