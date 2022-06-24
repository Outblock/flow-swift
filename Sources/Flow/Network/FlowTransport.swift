//
//  CadenceTypeTest
//
//  Copyright 2022 Outblock Pty Ltd
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
