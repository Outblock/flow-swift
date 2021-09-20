//
//  File.swift
//
//
//  Created by lmcmz on 19/7/21.
//

import Foundation

extension String {
    var bytes: [UInt8] {
        guard let result = Data.fromHex(self) else {
            return [UInt8]()
        }
        return result.bytes
    }

    var hexValue: [UInt8] {
        var startIndex = self.startIndex
        return (0 ..< count / 2).compactMap { _ in
            let endIndex = index(after: startIndex)
            defer { startIndex = index(after: endIndex) }
            return UInt8(self[startIndex ... endIndex], radix: 16)
        }
    }

    enum ExtendedEncoding {
        case hexadecimal
    }

    func data(using _: ExtendedEncoding) -> Data? {
        let hexString = dropFirst(hasPrefix("0x") ? 2 : 0)

        guard hexString.count % 2 == 0 else { return nil }

        var data = Data(capacity: hexString.count / 2)

        var indexIsEven = true
        for i in hexString.indices {
            if indexIsEven {
                let byteRange = i ... hexString.index(after: i)
                guard let byte = UInt8(hexString[byteRange], radix: 16) else { return nil }
                data.append(byte)
            }
            indexIsEven.toggle()
        }
        return data
    }

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
