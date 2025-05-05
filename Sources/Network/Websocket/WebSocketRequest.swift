//
//  File.swift
//  Flow
//
//  Created by Hao Fu on 30/4/2025.
//

import Foundation

extension Flow.Websocket {
    
    public enum BlockStatus: String, Codable {
        case finalized
        case sealed
    }
    
    struct TransactionStatusRequest: Encodable {
        let txId: String
        
        enum CodingKeys: String, CodingKey {
            case txId = "tx_id"
        }
    }
    
    struct BlockDigestArguments: Encodable {
        let blockStatus: BlockStatus
        let startBlockHeight: String?
        let startBlockId: String?
    }
}
