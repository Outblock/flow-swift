//
//  Data.swift
//
//
//  Created by lmcmz on 19/7/21.
//

import Foundation

// extension Sequence where Element == UInt8 {
// }

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Array where Element == UInt8 {
    var data: Data { .init(self) }
    public var hexValue: String { map { .init(format: "%02x", $0) }.joined() }

    public mutating func padZeroLeft(blockSize: Int) -> [UInt8] {
        while count < blockSize {
            insert(0, at: 0)
        }
        return self
    }

    public mutating func padZeroRight(blockSize: Int) -> [UInt8] {
        while count < blockSize {
            append(0)
        }
        return self
    }

    public func paddingZeroLeft(blockSize: Int) -> [UInt8] {
        var bytes = self
        while bytes.count < blockSize {
            bytes.insert(0, at: 0)
        }
        return bytes
    }

    public func paddingZeroRight(blockSize: Int) -> [UInt8] {
        var bytes = self
        while bytes.count < blockSize {
            bytes.append(0)
        }
        return bytes
    }
}

extension Data {
    var bytes: Bytes {
        return Bytes(self)
    }

    static func fromHex(_ hex: String) -> Data? {
        let string = hex.lowercased().stripHexPrefix()
        guard let array = string.data(using: .utf8)?.bytes else {
            return nil
        }
        if array.count == 0 {
            if hex == "0x" || hex == "" {
                return Data()
            } else {
                return nil
            }
        }
        return array.data
    }

    public var hexValue: String {
        return reduce("") { $0 + String(format: "%02x", $1) }
    }

    public mutating func padZeroLeft(blockSize: Int) -> Data {
        while count < blockSize {
            insert(0, at: 0)
        }
        return self
    }

    public mutating func padZeroRight(blockSize: Int) -> Data {
        while count < blockSize {
            append(0)
        }
        return self
    }

    public func paddingZeroLeft(blockSize: Int) -> Data {
        var bytes = self
        while bytes.count < blockSize {
            bytes.insert(0, at: 0)
        }
        return bytes
    }

    public func paddingZeroRight(blockSize: Int) -> Data {
        var bytes = self
        while bytes.count < blockSize {
            bytes.append(0)
        }
        return bytes
    }
}

extension Array where Iterator.Element: Hashable {
    var hashValue: Int {
        return reduce(1) { $0.hashValue ^ $1.hashValue }
    }
}
