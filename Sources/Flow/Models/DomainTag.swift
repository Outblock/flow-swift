//
//  DomainTag.swift
//
//
//  Created by lmcmz on 25/7/21.
//

import Foundation

enum DomainTag: String {
    case TRANSACTION_DOMAIN_TAG = "FLOW-V0.0-transaction"

    case USER_DOMAIN_TAG = "FLOW-V0.0-user"

    var normalize: ByteArray? {
        guard let bytes = rawValue.data(using: .utf8) else {
            return nil
        }

        let length = bytes.count
        switch length {
        case _ where length > 32:
            return nil
        case _ where length < 32:
            let paddingBytes = (0 ..< 32 - length).compactMap { _ in UInt8() }
            var result = bytes.byteArray
            result.append(contentsOf: paddingBytes)
            return result
        default:
            return bytes.byteArray
        }
    }
}
