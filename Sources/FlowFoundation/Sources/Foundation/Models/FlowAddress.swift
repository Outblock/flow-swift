//
//  FlowAddress.swift
//
//
//  Created by lmcmz on 23/7/21.
//

import Foundation

extension Flow {
    public struct Address: FlowEntity, Equatable, Hashable, Codable {
        public var data: Data

        public init(hex: String) {
            data = hex.hexValue.data
        }

        public init(data: Data) {
            self.data = data
        }

        internal init(bytes: [UInt8]) {
            data = bytes.data
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(hex.addHexPrefix())
        }
    }
}
