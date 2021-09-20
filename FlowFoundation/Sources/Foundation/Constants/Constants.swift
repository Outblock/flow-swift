//
//  File.swift
//
//
//  Created by lmcmz on 14/9/21.
//

import Foundation

extension Flow {
    class Constants {
        internal static let transactionPrefix = DomainTag.transaction.normalize.hexValue
        internal static let userPrefix = DomainTag.user.normalize.hexValue
    }
}
