//
//  File.swift
//  
//
//  Created by Hao Fu on 23/6/2022.
//

import Foundation
import BigInt

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
            self.arguments = arguments.compactMap{ $0.jsonString?.data(using: .utf8)?.base64EncodedString() }
        }
    }
    
    struct TransactionIdResponse: Codable {
        let id: ID
    }
}
