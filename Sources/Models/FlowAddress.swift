//
//  FlowAddress
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

/// Flow Address Model
///
/// Represents account addresses on the Flow blockchain.
/// Handles address formatting, validation, and conversion.
///
/// Features:
/// - Hex string parsing
/// - Address validation
/// - String representation
/// - Equatable comparison
///
/// Example usage:
/// ```swift
/// let address = Flow.Address(hex: "0x1234")
/// let account = try await flow.getAccountAtLatestBlock(address: address)
/// ```

public extension Flow {
    /// The data structure of address in Flow blockchain
    /// At the most time, it represents account address
    struct Address: FlowEntity, Equatable, Hashable {
        static let byteLength = 8

        /// Raw address bytes
        public var data: Data

        /// Hexadecimal string representation
        public var hex: String {
            data.hexValue.addHexPrefix()
        }

        public init(hex: String) {
            self.init(data: hex.hexValue.data)
        }

        public init(data: Data) {
            if data.bytes.count == 8 {
                self.data = data
            }
            self.data = data.paddingZeroLeft(blockSize: Flow.Address.byteLength).prefix(Flow.Address.byteLength)
        }

        internal init(bytes: [UInt8]) {
            self.init(data: bytes.data)
        }
    }
}

extension Flow.Address: Codable {
    enum CodingKeys: String, CodingKey {
        case data
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(hex.addHexPrefix())
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let scriptString = try container.decode(String.self)
        data = scriptString.hexValue.data
    }
}

extension Flow.Address: CustomStringConvertible {
    public var description: String { hex.addHexPrefix() }
}
