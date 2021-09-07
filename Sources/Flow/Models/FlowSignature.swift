//
//  File.swift
//
//
//  Created by lmcmz on 5/9/21.
//

import Foundation

extension Flow {
    struct Signature: BytesHolder, Equatable {
        var bytes: [UInt8]

        init(hex: String) {
            bytes = hex.hexValue
        }

        init(bytes: [UInt8]) {
            self.bytes = bytes
        }
    }
}
