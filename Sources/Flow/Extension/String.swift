//
//  File.swift
//
//
//  Created by lmcmz on 19/7/21.
//

import Foundation

extension StringProtocol {
    var hexValue: [UInt8] {
//        var startIndex = self.startIndex
//        return (0 ..< count / 2).compactMap { _ in
//            let endIndex = index(after: startIndex)
//            defer { startIndex = index(after: endIndex) }
//            return UInt8(self[startIndex ... endIndex], radix: 16)
//        }
        guard let result = Data.fromHex(self as! String) else {
            return [UInt8]()
        }
        return result.byteArray
    }
}

extension String {
    func hasHexPrefix() -> Bool {
        return hasPrefix("0x")
    }

    func stripHexPrefix() -> String {
        if hasPrefix("0x") {
            let indexStart = index(startIndex, offsetBy: 2)
            return String(self[indexStart...])
        }
        return self
    }

    func addHexPrefix() -> String {
        if !hasPrefix("0x") {
            return "0x" + self
        }
        return self
    }
}
