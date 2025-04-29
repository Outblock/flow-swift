//
//  File.swift
//  Flow
//
//  Created by Hao Fu on 30/4/2025.
//

import Foundation

extension Flow.Websocket {
    struct TransactionStatusRequest: Codable {
        let txId: String
        
        enum CodingKeys: String, CodingKey {
            case txId = "tx_id"
        }
    }
}
