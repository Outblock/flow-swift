//
//  File.swift
//  Flow
//
//  Created by Hao Fu on 29/4/2025.
//

import Foundation

extension Flow.Websocket {
    
    public enum Action: String, Codable {
        case subscribe = "subscribe"
        case unsubscribe = "unsubscribe"
        case listSubscriptions = "list_subscriptions"
    }
    
    public enum Topic: String, Codable {
        case blockDigests = "block_digests"
        case blockHeaders = "block_headers"
        case blocks = "blocks"
        case events = "events"
        case accountStatuses = "account_statuses"
        case transactionStatuses = "transaction_statuses"
        case sendAndGetTransactionStatuses = "send_and_get_transaction_statuses"
    }
    
    public struct SubscribeRequest<T: Encodable>: Encodable {
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

    public struct SubscribeResponse: Decodable {
        let subscriptionId: String
        let action: Action
        let error: SocketError?
    }
    
    public struct SocketError: Codable {
        let code: Int
        let message: String
    }
    
    public struct TopicResponse<T: Decodable>: Decodable {
        let subscriptionId: String
        let topic: Topic
        let payload: T?
        let error: SocketError?
    }
    
    public struct ListSubscriptionsResponse: Decodable {
        let subscriptions: [SubscriptionInfo]
    }
    
    public struct SubscriptionInfo: Decodable {
        let id: String
        let topic: Topic
        let arguments: AnyDecodable?
    }
}