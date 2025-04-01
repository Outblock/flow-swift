//
//  String.swift
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

public extension String {
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

public extension String {
    func replace(by dict: [String: String]) -> String {
        var string = self
        for (key, value) in dict {
            string = string.replaceExactMatch(target: key, replacement: value)
        }
        return string
    }

    func replace(from dict: [String: String]) -> String {
        var string = self
        for (key, value) in dict {
            string = string.replacingOccurrences(of: key, with: value)
        }
        return string
    }

    func replaceExactMatch(target: String, replacement: String) -> String {
        let pattern = "\\b\(NSRegularExpression.escapedPattern(for: target))\\b"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return self }
        let range = NSRange(startIndex ..< endIndex, in: self)
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replacement)
    }
}
