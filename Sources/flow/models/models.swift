//
//  File.swift
//  
//
//  Created by lmcmz on 19/7/21.
//

import Foundation

protocol BytesHolder {
    var bytes: [UInt8] { set get }
    var base16Value: String { get }
    var stringValue: String { get }
}

extension BytesHolder {
    var base16Value: String {
        get {
            return bytes.hexValue
        }
    }
    var stringValue: String {
        get {
            return  String(bytes: bytes, encoding: .utf8) ?? ""
        }
    }
}


struct FlowId : BytesHolder, Equatable {
    var bytes: [UInt8]
    
    init(bytes: [UInt8]) {
        self.bytes = bytes
    }
}

struct FlowBlockHeader {
//    val id: FlowId,
//    val parentId: FlowId,
//    val height: Long
}

