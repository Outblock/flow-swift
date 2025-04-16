//
//  Signer
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
    struct PublicKey: FlowEntity, Equatable, Codable {
        public var data: Data

        public init(hex: String) {
            data = hex.hexValue.data
        }

        public init(data: Data) {
            self.data = data
        }

        public init(bytes: [UInt8]) {
            data = bytes.data
        }
        
        enum CodingKeys: CodingKey {
            case data
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let decodeData = try? container.decode(Data.self) {
                data = decodeData
            } else {
                let hexString = try container.decode(String.self)
                data = hexString.hexValue.data
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.hex)
        }
    }

    struct Code: FlowEntity, Equatable, Codable {
        public var data: Data

        var text: String {
            String(data: data, encoding: .utf8) ?? ""
        }

        public init(data: Data) {
            self.data = data
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let uftString = try container.decode(String.self)
            data = Data(base64Encoded: uftString) ?? uftString.data(using: .utf8) ?? Data()
        }
    }
}

extension Flow.PublicKey: CustomStringConvertible {
    public var description: String { hex }
}

extension Flow.Code: CustomStringConvertible {
    public var description: String { text }
}
