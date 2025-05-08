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
    
    public struct AccountStatusResponse: Codable {
        public let blockId: String
        public let height: String
        public let accountEvents: [String: [AccountStatusEvent]]
    }
    
    public struct AccountStatusEvent: Codable {
        public let type: String
        public let transactionId: String
        public let transactionIndex: String
        public let eventIndex: String
        public let payload: String
    }
}
