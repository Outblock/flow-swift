//
//  FlowScript.swift
//
//
//  Created by lmcmz on 23/7/21.
//

import Foundation

struct FlowScript: BytesHolder, Equatable {
    var bytes: [UInt8]

    init(script: String) {
        bytes = script.hexValue
    }

    init(bytes: [UInt8]) {
        self.bytes = bytes
    }
}

struct FlowScriptResponse: BytesHolder, Equatable, Hashable {
    var bytes: ByteArray
}
