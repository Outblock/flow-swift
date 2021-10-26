//
//  String.swift
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

extension String {

    /// Convert hex string to bytes
    var hexValue: [UInt8] {
        var startIndex = self.startIndex
        return (0 ..< count / 2).compactMap { _ in
            let endIndex = index(after: startIndex)
            defer { startIndex = index(after: endIndex) }
            return UInt8(self[startIndex ... endIndex], radix: 16)
        }
    }

    /// Determine string has hexadecimal prefix.
    /// - returns: `Bool` type.
    func hasHexPrefix() -> Bool {
        return hasPrefix("0x")
    }

    /// If string has hexadecimal prefix, remove it
    /// - returns: A string without hexadecimal prefix
    func stripHexPrefix() -> String {
        if hasPrefix("0x") {
            let indexStart = index(startIndex, offsetBy: 2)
            return String(self[indexStart...])
        }
        return self
    }

    /// Add hexadecimal prefix to a string.
    /// If it already has it, do nothing
    /// - returns: A string with hexadecimal prefix
    func addHexPrefix() -> String {
        if !hasPrefix("0x") {
            return "0x" + self
        }
        return self
    }
}
