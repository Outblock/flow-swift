//
//  FlowScript.swift
//
//
//  Created by lmcmz on 23/7/21.
//

import Foundation

extension Flow {
    struct Script: BytesHolder, Equatable {
        var bytes: [UInt8]

        init(script: String) {
            bytes = script.data(using: .utf8)!.byteArray
        }

        init(bytes: [UInt8]) {
            self.bytes = bytes
        }
    }

    struct ScriptResponse: BytesHolder, Equatable, Hashable {
        var bytes: ByteArray
    }
}
