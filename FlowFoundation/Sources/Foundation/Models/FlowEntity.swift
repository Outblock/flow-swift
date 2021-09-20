//
//  BytesHolder.swift
//
//
//  Created by lmcmz on 21/7/21.
//

import Foundation

typealias Bytes = [UInt8]

protocol FlowEntity {
    var data: Data { get set }
    var bytes: Bytes { get }
    var hex: String { get }
}

extension FlowEntity {
    var bytes: Bytes {
        data.bytes
    }

    var hex: String {
        bytes.hexValue
    }
}
