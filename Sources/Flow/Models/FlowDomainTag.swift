//
//  FlowDomainTag
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
    /// The prefix when encoding transaction and user with RLP
    enum DomainTag {
        public typealias RawValue = String

        /// The tag for transaction
        case transaction

        /// The tag for user
        case user

        /// Custom domain tag
        case custom(String)

        /// The rawValue for domain tag
        public var rawValue: String {
            switch self {
            case .transaction:
                return "FLOW-V0.0-transaction"
            case .user:
                return "FLOW-V0.0-user"
            case let .custom(tag):
                return tag
            }
        }

        /// Init a domain tag by string
        /// If it's not the default one, then it will return a .custom(string) type
        public init?(rawValue: String) {
            self = [DomainTag.user, DomainTag.transaction].first { $0.rawValue == rawValue } ?? .custom(rawValue)
        }

        /// Convert tag string into data with `.uft8` format
        /// And padding zero to right until 32 bytes long.
        public var normalize: Data {
            guard let bytes = rawValue.data(using: .utf8) else {
                return Data()
            }

            return bytes.paddingZeroRight(blockSize: 32)
        }
    }
}
