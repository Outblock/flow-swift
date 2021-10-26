//
//  FlowDomainTag
//
//  Copyright 2021 Zed Labs Pty Ltd
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

extension Flow {

    /// The prefix when encoding transaction and user with RLP
    public enum DomainTag: String {

        /// The tag for transaction
        case transaction = "FLOW-V0.0-transaction"

        /// The tag for user
        case user = "FLOW-V0.0-user"

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
