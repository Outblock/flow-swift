//
//  FlowAddress.swift
//
//
//  Created by lmcmz on 23/7/21.
//

import Foundation

extension Flow {
    public struct Address: BytesHolder, Equatable, Hashable, Codable {
        internal var bytes: [UInt8]

        internal init(hex: String) {
            bytes = hex.hexValue
        }

        init(bytes: [UInt8]) {
            self.bytes = bytes
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(hexValue.addHexPrefix())
        }
    }
}
