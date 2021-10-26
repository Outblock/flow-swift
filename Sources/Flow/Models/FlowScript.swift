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

extension Flow {
    /// The model to handle `Cadence` code
    public struct Script: FlowEntity, Equatable {
        public var data: Data

        public init(script: String) {
            data = script.data(using: .utf8) ?? Data()
        }

        public init(data: Data) {
            self.data = data
        }

        init(bytes: [UInt8]) {
            data = bytes.data
        }
    }

    /// The model to handle the `Cadence` code response
    public struct ScriptResponse: FlowEntity, Equatable {
        public var data: Data

        /// Covert `data` into `Flow.Argument` type
        public var fields: Argument?

        init(data: Data) {
            self.data = data
            fields = try? JSONDecoder().decode(Flow.Argument.self, from: data)
        }
    }
}
