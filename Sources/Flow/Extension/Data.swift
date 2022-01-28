//
//  Data.swift
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

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

public extension Array where Element == UInt8 {
    /// Convert to `Data` type
    internal var data: Data { .init(self) }

    /// Convert bytes to hex string
    var hexValue: String { map { .init(format: "%02x", $0) }.joined() }

    /// Mutate data with adding zero padding to the left until fulfil the block size
    /// - parameters:
    ///     - blockSize: The size of block.
    /// - returns: self in `Data` type.
    @discardableResult
    mutating func padZeroLeft(blockSize: Int) -> [UInt8] {
        while count < blockSize {
            insert(0, at: 0)
        }
        return self
    }

    /// Mutate data with adding zero padding to the right until fulfil the block size
    /// - parameters:
    ///     - blockSize: The size of block.
    /// - returns: self in `Data` type.
    @discardableResult
    mutating func padZeroRight(blockSize: Int) -> [UInt8] {
        while count < blockSize {
            append(0)
        }
        return self
    }

    /// Add zero padding to the left until fulfil the block size
    /// - parameters:
    ///     - blockSize: The size of block.
    /// - returns: A new `[UInt8]` type with padding zero.
    func paddingZeroLeft(blockSize: Int) -> [UInt8] {
        var bytes = self
        while bytes.count < blockSize {
            bytes.insert(0, at: 0)
        }
        return bytes
    }

    /// Add zero padding to the right until fulfil the block size
    /// - parameters:
    ///     - blockSize: The size of block.
    /// - returns: A new `[UInt8]` type with padding zero.
    func paddingZeroRight(blockSize: Int) -> [UInt8] {
        var bytes = self
        while bytes.count < blockSize {
            bytes.append(0)
        }
        return bytes
    }
}

public extension Data {
    /// Convert data to list of byte
    internal var bytes: Bytes {
        return Bytes(self)
    }

    /// Initial the data with hex string
    internal static func fromHex(_ hex: String) -> Data? {
        let string = hex.lowercased().stripHexPrefix()
        guard let array = string.data(using: .utf8)?.bytes else {
            return nil
        }
        if array.isEmpty {
            if hex == "0x" || hex == "" {
                return Data()
            } else {
                return nil
            }
        }
        return array.data
    }

    /// Convert data to hex string
    var hexValue: String {
        return reduce("") { $0 + String(format: "%02x", $1) }
    }

    /// Mutate data with adding zero padding to the left until fulfil the block size
    /// - parameters:
    ///     - blockSize: The size of block.
    /// - returns: self in `Data` type.
    mutating func padZeroLeft(blockSize: Int) -> Data {
        while count < blockSize {
            insert(0, at: 0)
        }
        return self
    }

    /// Mutate data with adding zero padding to the right until fulfil the block size
    /// - parameters:
    ///     - blockSize: The size of block.
    /// - returns: self in `Data` type.
    mutating func padZeroRight(blockSize: Int) -> Data {
        while count < blockSize {
            append(0)
        }
        return self
    }

    /// Add zero padding to the left until fulfil the block size
    /// - parameters:
    ///     - blockSize: The size of block.
    /// - returns: A new `Data` type with padding zero.
    func paddingZeroLeft(blockSize: Int) -> Data {
        var bytes = self
        while bytes.count < blockSize {
            bytes.insert(0, at: 0)
        }
        return bytes
    }

    /// Add zero padding to the right until fulfil the block size
    /// - parameters:
    ///     - blockSize: The size of block.
    /// - returns: A new `Data` type with padding zero.
    func paddingZeroRight(blockSize: Int) -> Data {
        var bytes = self
        while bytes.count < blockSize {
            bytes.append(0)
        }
        return bytes
    }
}
