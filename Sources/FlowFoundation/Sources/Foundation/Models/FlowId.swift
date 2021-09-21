//
//  File.swift
//
//
//  Created by lmcmz on 27/7/21.
//

import Foundation

extension Flow {
    public struct Id: FlowEntity, Equatable, Hashable {
        public var data: Data

        public init(hex: String) {
            data = hex.hexValue.data
        }

        init(data: Data) {
            self.data = data
        }

        init(bytes: [UInt8]) {
            data = bytes.data
        }
    }
}
