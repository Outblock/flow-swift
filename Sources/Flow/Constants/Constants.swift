//
//  File.swift
//
//
//  Created by lmcmz on 14/9/21.
//

import Foundation

extension Flow {
    class Constants {
        internal static let transactionPrefix = "FLOW-V0.0-transaction".data(using: .utf8)!.byteArray.paddingZeroRight(blockSize: 32).hexValue
        internal static let userPrefix = "FLOW-V0.0-user".data(using: .utf8)!.byteArray.paddingZeroRight(blockSize: 32).hexValue
    }
}
