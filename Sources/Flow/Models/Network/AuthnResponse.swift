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
    public var data: AuthData?
    public let reason: String?
}

public struct AuthData: Codable {
//        public let address: String?
    public let addr: String
    public let fType: String
    public let fVsn: String?
    public let services: [Service]?
    public let proposer: Service?
    public let payer: [Service]?
    public let authorization: [Service]?
    public let signature: String?
}

// public struct Proposer: Codable {
//    public let fType: String
//    public let fVsn: String
//    let method: Method
//    let uid: String
//    let endpoint: String
// }

public enum Status: String, Codable {
    case pending = "PENDING"
    case approved = "APPROVED"
    case declined = "DECLINED"
}

public struct Service: Codable {
    let type: Type
    let method: Method
    let uid: String
    let endpoint: String
    let id: String?
    let identity: Identity?
    let provider: Provider?

    public enum Method: String, Codable {
        case post = "HTTP/POST"
    }

    public enum `Type`: String, Codable {
        case authn
        case authz
        case preAuthz = "pre-authz"
        case userSignature = "user-signature"
    }
}

public struct Identity: Codable {
    let address: String
    let keyId: Int
}

public struct Provider: Codable {
    public let fType: String?
    public let fVsn: String?
    let address: String
    let name: String
}
