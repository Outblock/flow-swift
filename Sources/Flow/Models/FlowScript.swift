//
//  FlowScript
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

public extension Flow {
    /// The model to handle `Cadence` code
    struct Script: FlowEntity, Equatable {
        public var data: Data

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
    struct ScriptResponse: FlowEntity, Equatable {
        public var data: Data

        /// Covert `data` into `Flow.Argument` type
        public var fields: Argument?

        init(data: Data) {
            self.data = data
            fields = try? JSONDecoder().decode(Flow.Argument.self, from: data)
        }
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
        data = scriptString.data(using: .utf8) ?? Data()
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
