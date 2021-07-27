//
//  BytesHolder.swift
//
//
//  Created by lmcmz on 21/7/21.
//

import Foundation

typealias ByteArray = [UInt8]

protocol BytesHolder {
    var bytes: ByteArray { get set }
    var base16Value: String { get }
    var stringValue: String { get }
}

extension BytesHolder {
    var base16Value: String {
        return bytes.hexValue
    }

    var stringValue: String {
        return String(bytes: bytes, encoding: .utf8) ?? ""
    }
}
