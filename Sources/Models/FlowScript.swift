//
//  FlowScript
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

/// Flow Script Model
///
/// Represents a Cadence script that can be executed on the Flow blockchain.
/// Handles script text and binary data conversion for network transmission.
///
/// Features:
/// - Text to binary conversion
/// - Script validation
/// - Argument handling
///
/// Example usage:
/// ```swift
/// let script = Flow.Script(text: """
///     pub fun main(): Int {
///         return 42
///     }
/// """)
/// let result = try await flow.executeScriptAtLatestBlock(script: script)
/// ```

import Foundation

public extension Flow {
    /// Represents a Cadence script
    struct Script: FlowEntity, Equatable {
        /// Raw script data
        public var data: Data
        
        /// Script text in UTF-8 encoding
        public var text: String {
            String(data: data, encoding: .utf8) ?? ""
        }

        public init(text: String) {
            data = text.data(using: .utf8) ?? Data()
        }

        public init(data: Data) {
            self.data = data
        }

        init(bytes: [UInt8]) {
            data = bytes.data
        }
    }

    /// The model to handle the `Cadence` code response
    struct ScriptResponse: FlowEntity, Equatable, Codable {
        public var data: Data

        /// Covert `data` into `Flow.Argument` type
        public var fields: Argument?

        public init(data: Data) {
            self.data = data
            fields = try? JSONDecoder().decode(Flow.Argument.self, from: data)
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            data = Data(base64Encoded: string) ?? string.data(using: .utf8) ?? Data()
            fields = try? JSONDecoder().decode(Flow.Argument.self, from: data)
        }
    }
}

extension Flow.ScriptResponse: FlowDecodable {
    public func decode() -> Any? {
        return fields?.decode()
    }

    public func decode<T: Decodable>(_: T.Type) throws -> T {
        guard let result: T = try? fields?.decode() else {
            throw Flow.FError.decodeFailure
        }
        return result
    }

    public func decode<T: Decodable>() throws -> T {
        guard let result: T = try? fields?.decode() else {
            throw Flow.FError.decodeFailure
        }
        return result
    }
}

extension Flow.Script: CustomStringConvertible {
    public var description: String { text }
}

extension Flow.Script: Codable {
    enum CodingKeys: String, CodingKey {
        case data
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(text)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let scriptString = try container.decode(String.self)
        data = Data(base64Encoded: scriptString) ?? scriptString.data(using: .utf8) ?? Data()
    }
}

extension Flow.ScriptResponse: CustomStringConvertible {
    public var description: String {
        guard let object = try? JSONSerialization.jsonObject(with: data),
              let jsonData = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted),
              let jsonString = String(data: jsonData, encoding: .utf8)
        else {
            return ""
        }
        return jsonString
    }
}
