//
//  File.swift
//
//
//  Created by lmcmz on 5/9/21.
//

import Foundation

extension Flow {
    public struct Signature: FlowEntity, Equatable {
        public var data: Data

        public init(data: Data) {
            self.data = data
        }

        public init(hex: String) {
            data = hex.hexValue.data
        }
    }
}
