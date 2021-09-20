//
//  File.swift
//
//
//  Created by lmcmz on 28/8/21.
//

import Foundation

extension FCL {
    public struct AuthnResponse: Codable {
        public let fType: String
        public let fVsn: String
        public let status: Status
        public var updates: Service?
        public var local: Service?
        public var data: AuthData?
        public let reason: String?
    }

    public struct AuthData: Codable {
        //        public let address: String?
        public let addr: String?
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
        let fType: String?
        let fVsn: String?
        let type: Name?
        let method: Method
        let endpoint: String
        let uid: String?
        let id: String?
        public let identity: Identity?
        public let provider: Provider?

        public enum Method: String, Codable {
            case post = "HTTP/POST"
            case get = "HTTP/GET"
            case iframe = "VIEW/IFRAME"
        }

        public enum Name: String, Codable {
            case authn
            case authz
            case preAuthz = "pre-authz"
            case userSignature = "user-signature"

            case backChannel = "back-channel-rpc"
        }
    }

    public struct Identity: Codable {
        public let address: String
        let keyId: Int
    }

    public struct Provider: Codable {
        public let fType: String?
        public let fVsn: String?
        public let address: String
        public let name: String
    }
}
