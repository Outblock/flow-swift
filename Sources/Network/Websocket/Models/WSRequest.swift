//
//  File.swift
//  Flow
//
//  Created by Hao Fu on 6/5/2025.
//

import Foundation

extension Flow {
    public struct WSBlockHeader: Codable {
        /// The identification of block
        public let blockId: ID
        
        /// The height of block
        public let height: String
        
        /// The time when the block is created
        public let timestamp: Date
    }
    
    public struct WSTransactionResponse: Codable {
        public let transactionResult: Flow.TransactionResult
    }
}
