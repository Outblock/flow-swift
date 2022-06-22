//
//  File.swift
//
//
//  Created by Hao Fu on 20/6/2022.
//

import Foundation

public extension Flow {
    enum Transport: Equatable, Hashable {
        case HTTP(_ url: URL)
        case gRPC(_ endpoint: Endpoint)

        public var url: URL? {
            switch self {
            case let .HTTP(url):
                return url
            case .gRPC:
                return nil
            }
        }

        public var gRPCEndpoint: Endpoint? {
            switch self {
            case .HTTP:
                return nil
            case let .gRPC(endpoint):
                return endpoint
            }
        }

        public static func == (lhs: Flow.Transport, rhs: Flow.Transport) -> Bool {
            switch (lhs, rhs) {
            case let (.HTTP(lhsValue), .HTTP(rhsValue)):
                return lhsValue == rhsValue
            case let (.gRPC(lhsValue), .gRPC(rhsValue)):
                return lhsValue == rhsValue
            default:
                return false
            }
        }

        /// Endpoint information for gRPC node
        public struct Endpoint: Hashable, Equatable {
            public let node: String
            public let port: Int?

            public init(node: String, port: Int? = nil) {
                self.node = node
                self.port = port
            }
        }
    }
}
