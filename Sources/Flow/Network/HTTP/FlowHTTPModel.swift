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

extension Flow {
    struct BlockHeaderResponse: Codable {
        let header: Flow.BlockHeader
    }

    struct BlockResponse: Codable {
        let header: Flow.BlockHeader
        let payload: BlockPayloadResponse

        func toFlowBlock() -> Flow.Block {
            return .init(id: header.id,
                         parentId: header.parentId,
                         height: header.height,
                         timestamp: header.timestamp,
                         collectionGuarantees: payload.collectionGuarantees,
                         blockSeals: payload.blockSeals,
                         signatures: [])
        }
    }

    struct BlockPayloadResponse: Codable {
        let collectionGuarantees: [Flow.CollectionGuarantee]
        let blockSeals: [BlockSeal]
    }

    struct ScriptRequest: Codable {
        let script: String
        let arguments: [String]

        init(script: Flow.Script, arguments: [Flow.Argument]) {
            self.script = script.data.base64EncodedString()
            self.arguments = arguments.compactMap { $0.jsonString?.data(using: .utf8)?.base64EncodedString() }
        }
    }

    struct TransactionIdResponse: Codable {
        let id: ID
    }
}
