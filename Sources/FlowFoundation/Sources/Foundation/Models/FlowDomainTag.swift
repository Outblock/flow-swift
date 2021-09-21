//
//  DomainTag.swift
//
//
//  Created by lmcmz on 25/7/21.
//

import Foundation

extension Flow {
    public enum DomainTag: String {
        case transaction = "FLOW-V0.0-transaction"
        case user = "FLOW-V0.0-user"

        public var normalize: Data {
            guard let bytes = rawValue.data(using: .utf8) else {
                return Data()
            }

            return bytes.paddingZeroRight(blockSize: 32)
        }
    }
}
