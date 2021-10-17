//
//  File.swift
//  File
//
//  Created by lmcmz on 29/9/21.
//

import Foundation

public protocol FlowSigner {
    var address: Flow.Address { get set }
    var keyIndex: Int { get set }
    func signature(signableData: Data) throws -> Data
}
