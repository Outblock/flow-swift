//
//  Extension.swift
//
//
//  Created by lmcmz on 19/7/21.
//

import Foundation

extension StringProtocol {
    var hexValue: [UInt8] {
        var startIndex = self.startIndex
        return (0 ..< count / 2).compactMap { _ in
            let endIndex = index(after: startIndex)
            defer { startIndex = index(after: endIndex) }
            return UInt8(self[startIndex ... endIndex], radix: 16)
        }
    }
}

extension String {
    mutating func addPrefixIfNeeded(prefix: String) {
        guard !hasPrefix(prefix) else { return }
        self = prefix + self
    }

    func addPrefixIfNeeded(prefix: String) -> String {
        guard !hasPrefix(prefix) else {
            return self
        }

        return prefix + self
    }
}

extension Sequence where Element == UInt8 {
    var data: Data { .init(self) }
    var hexValue: String { map { .init(format: "%02x", $0) }.joined() }
}

extension Data {
    var byteArray: ByteArray {
        return ByteArray(self)
    }
}

extension Array where Iterator.Element: Hashable {
    var hashValue: Int {
        return reduce(1) { $0.hashValue ^ $1.hashValue }
    }
}
