//
//  FlowEntity
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

/// Convient alias to make list of UInt8 as Bytes
public typealias Bytes = [UInt8]

/// Protocol to hanld `Flow` network model
public protocol FlowEntity {
    /// The content of the entity
    var data: Data { get set }

    /// Convert `data` into a list of UInt8
    var bytes: Bytes { get }

    /// Convert `data` into hex string
    var hex: String { get }
}

public extension FlowEntity {
    var bytes: Bytes {
        data.bytes
    }

    var hex: String {
        bytes.hexValue
    }
}
