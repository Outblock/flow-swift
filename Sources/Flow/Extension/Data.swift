//
//  Data.swift
//
//
//  Created by lmcmz on 19/7/21.
//

import Foundation

// extension Sequence where Element == UInt8 {
// }

extension Array where Element == UInt8 {
    var data: Data { .init(self) }
    var hexValue: String { map { .init(format: "%02x", $0) }.joined() }

    func paddingZeroLeft(blockSize: Int) -> [UInt8] {
        if count >= blockSize {
            return self
        }
        let paddingCount = blockSize - (count % blockSize)
        if paddingCount > 0 {
            return [UInt8](repeating: 0, count: paddingCount) + self
        }
        return self
    }

    func paddingZeroRight(blockSize: Int) -> [UInt8] {
        let paddingCount = blockSize - (count % blockSize)
        if paddingCount > 0 {
            return self + [UInt8](repeating: 0, count: paddingCount)
        }
        return self
    }
}

extension Data {
    var byteArray: ByteArray {
        return ByteArray(self)
    }

    static func fromHex(_ hex: String) -> Data? {
        let string = hex.lowercased().stripHexPrefix()
        guard let array = string.data(using: .utf8)?.byteArray else {
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

    var hexValue: String {
        return reduce("") { $0 + String(format: "%02x", $1) }
    }
}

extension Array where Iterator.Element: Hashable {
    var hashValue: Int {
        return reduce(1) { $0.hashValue ^ $1.hashValue }
    }
}
