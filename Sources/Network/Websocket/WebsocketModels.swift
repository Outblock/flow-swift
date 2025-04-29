//
//  File.swift
//  Flow
//
//  Created by Hao Fu on 29/4/2025.
//

import Foundation

extension Flow.Websocket {
    
    enum Action: String, Codable {
        case subscribe = "subscribe"
        case unsubscribe = "unsubscribe"
        case listSubscriptions = "list_subscriptions"
    }
    
    enum Topic: String, Codable {
        case blockDigests = "block_digests"
        case blockHeaders = "block_headers"
        case blocks = "blocks"
        case events = "events"
        case accountStatuses = "account_statuses"
        case transactionStatuses = "transaction_statuses"
        case sendAndGetTransactionStatuses = "send_and_get_transaction_statuses"
    }
    
    struct SubscribeRequest<T: Encodable>: Encodable {
        let id: String?
        let action: Action
        let topic: Topic?
        let arguments: T?
        
        enum CodingKeys: String, CodingKey {
            case id = "subscription_id"
            case action
            case topic
            case arguments
        }
    }

    struct SubscribeResponse: Decodable {
        let id: String
        let type: Action?
        let error: SocketError?
        
        enum CodingKeys: String, CodingKey {
            case id = "subscription_id"
            case type = "action"
            case error
        }
    }
    
    struct SocketError: Codable {
        let code: Int
        let message: String
    }
    
    struct TopicResponse<T: Decodable>: Decodable {
        let id: String
        let topic: Topic
        let data: T?
        let error: SocketError?
        
        enum CodingKeys: String, CodingKey {
            case id = "subscription_id"
            case topic
            case data = "payload"
            case error
        }
    }
    
    struct ListSubscriptionsResponse: Decodable {
        let subscriptions: [SubscriptionInfo]
    }
    
    struct SubscriptionInfo: Decodable {
        let id: String
        let topic: Topic
        let arguments: AnyDecodable?
    }
}


