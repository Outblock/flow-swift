//
//  FlowSignature
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
    /// The model to handle the signature data, which can present as a hex string
    public struct Signature: FlowEntity, Equatable {
        public var data: Data

        public init(data: Data) {
            self.data = data
        }

        public init(hex: String) {
            data = hex.hexValue.data
        }
    }
}

extension Flow.Signature: CustomStringConvertible {
    public var description: String { data.hexValue }
}
