//
//  File.swift
//
//
//  Created by lmcmz on 27/7/21.
//

import Foundation

extension Flow {
    struct Id: BytesHolder, Equatable, Hashable {
        var bytes: [UInt8]

        init(hex: String) {
            bytes = hex.hexValue
        }

        init(bytes: [UInt8]) {
            self.bytes = bytes
        }
    }
}
