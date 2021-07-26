//
//  Data.swift
//
//
//  Created by lmcmz on 19/7/21.
//

import Foundation

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
