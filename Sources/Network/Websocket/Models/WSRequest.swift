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

// MARK: - Supporting Types

extension Flow.Websocket {
    enum WebSocketError: Error {
        case serverError(SocketError)
    }
    
    struct EmptyArguments: Codable {}
    
    struct EventArguments: Codable {
        public let type: String?
        public let contractID: String?
        public let address: String?
    }
    
    public struct AccountArguments: Codable {
        public var startBlockId: String? = nil
        public var startBlockHeight: String? = nil
        public var heartbeatInterval: String? = nil
        public var eventTypes: [AccountEventType]? = nil
        public var accountAddresses: [String]? = nil
    }
    
    struct SendTransactionArguments: Codable {
        public let transaction: Flow.Transaction
    }
}

public enum AccountEventType: String, Codable {
    case accountCreated = "flow.AccountCreated"
    case accountKeyAdded = "flow.AccountKeyAdded"
    case accountKeyRemoved = "flow.AccountKeyRemoved"
    case accountContractAdded = "flow.AccountContractAdded"
    case accountContractUpdated = "flow.AccountContractUpdated"
    case accountContractRemoved = "flow.AccountContractRemoved"
    case inboxValuePublished = "flow.InboxValuePublished"
    case inboxValueUnpublished = "flow.InboxValueUnpublished"
    case inboxValueClaimed = "flow.InboxValueClaimed"
}
