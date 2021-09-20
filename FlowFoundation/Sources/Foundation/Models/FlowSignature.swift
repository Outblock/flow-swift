//
//  File.swift
//
//
//  Created by lmcmz on 5/9/21.
//

import Foundation

extension Flow {
    struct Signature: FlowEntity, Equatable {
        var data: Data
        var bytes: [UInt8] {
            data.bytes
        }

        public init(data: Data) {
            self.data = data
        }

        public init(hex: String) {
            data = hex.hexValue.data
        }
    }
}
