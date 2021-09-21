//
//  BytesHolder.swift
//
//
//  Created by lmcmz on 21/7/21.
//

import Foundation

public typealias Bytes = [UInt8]

public protocol FlowEntity {
    var data: Data { get set }
    var bytes: Bytes { get }
    var hex: String { get }
}

extension FlowEntity {
    public var bytes: Bytes {
        data.bytes
    }

    public var hex: String {
        bytes.hexValue
    }
}
