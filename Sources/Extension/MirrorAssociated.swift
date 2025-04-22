//
//  File.swift
//  Flow
//
//  Created by Hao Fu on 23/4/2025.
//

import Foundation

public protocol MirrorAssociated {
    var associatedValues: [String: FlowEncodable] { get }
}

extension MirrorAssociated {
    public var associatedValues: [String: FlowEncodable] {
        var values = [String: FlowEncodable]()
        if let associated = Mirror(reflecting: self).children.first {
            let children = Mirror(reflecting: associated.value).children
            for case let item in children {
                if let label = item.label, let value = item.value as? FlowEncodable {
                    values[label] = value
                }
            }
        }
        return values
    }
}
