//
//  FlowAddress.swift
//
//
//  Created by lmcmz on 23/7/21.
//

import Foundation

struct FlowAddress: BytesHolder, Equatable {
    var bytes: [UInt8]

    init(hex: String) {
        bytes = hex.hexValue
    }

    init(bytes: [UInt8]) {
        self.bytes = bytes
    }
}
