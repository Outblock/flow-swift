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
    var hexValue: String { get }
    var stringValue: String { get }
}

extension BytesHolder {
    var hexValue: String {
        return bytes.hexValue
    }

    var stringValue: String {
        return String(bytes: bytes, encoding: .utf8) ?? ""
    }
}
