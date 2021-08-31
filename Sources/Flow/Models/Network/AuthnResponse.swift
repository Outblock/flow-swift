//
//  File.swift
//
//
//  Created by lmcmz on 28/8/21.
//

import Foundation

public struct AuthnResponse: Codable {
    public let fType: String
    public let fVsn: String
    public let status: Status
    public var updates: AuthnRequest?
    public var local: AuthnRequest?
    public var data: AuthnResponse.Data?
    public let reason: String?

    public struct Data: Codable {
        public let address: String?
        public let addr: String?
        public let fType: String?
        public let fVsn: String?
//        let service: []
    }

    public enum Status: String, Codable {
        case pending = "PENDING"
        case approved = "APPROVED"
        case declined = "DECLINED"
    }
}
