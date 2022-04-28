//
//  RLP.swift
//
//
//  Created by Julien Niset on 04/10/2018.
//
//  Reference: https://github.com/argentlabs/web3.swift/blob/15691c0015f768b94459963ce4045c914305ed0a/web3swift/src/Utils/RLP.swift

import BigInt
import Foundation

public enum RLP {
    public static func encode(_ item: Any) -> Data? {
        switch item {
        case let int as Int:
            return encodeInt(int)
        case let string as String:
            return encodeString(string)
        case let bint as BigInt:
            return encodeBigInt(bint)
        case let array as [Any]:
            return encodeArray(array)
        case let buint as BigUInt:
            return encodeBigUInt(buint)
        case let data as Data:
            return encodeData(data)
        case let bytes as Bytes:
            return encodeData(bytes)
        default:
            return nil
        }
    }

    static func encodeString(_ string: String) -> Data? {
        if let hexData = Data.fromHex(string) {
            return encodeData(hexData)
        }

        guard let data = string.data(using: String.Encoding.utf8) else {
            return nil
        }
        return encodeData(data)
    }

    static func encodeInt(_ int: Int) -> Data? {
        guard int >= 0 else {
            return nil
        }
        return encodeBigInt(BigInt(int))
    }

    static func encodeBigInt(_ bint: BigInt) -> Data? {
        guard bint >= 0 else {
            // TODO: implement properly to support negatives if RLP supports.. twos complement reverse?
            return nil
        }
        return encodeBigUInt(BigUInt(bint))
    }

    static func encodeBigUInt(_ buint: BigUInt) -> Data? {
        let data = buint.serialize()

        let lastIndex = data.count - 1
        let firstIndex = data.firstIndex(where: { $0 != 0x00 }) ?? lastIndex
        if lastIndex == -1 {
            return Data([0x80])
        }
        let subdata = data.subdata(in: firstIndex ..< lastIndex + 1)

        if subdata.count == 1, subdata[0] == 0x00 {
            return Data([0x80])
        }

        return encodeData(data.subdata(in: firstIndex ..< lastIndex + 1))
    }

    static func encodeData(_ bytes: [UInt8]) -> Data {
        return encodeData(bytes.data)
    }

    static func encodeData(_ data: Data) -> Data {
        if data.count == 1, data[0] <= 0x7F {
            return data // single byte, no header
        }

        var encoded = encodeHeader(size: UInt64(data.count), smallTag: 0x80, largeTag: 0xB7)
        encoded.append(data)
        return encoded
    }

    static func encodeArray(_ elements: [Any]) -> Data? {
        var encodedData = Data()
        for el in elements {
            guard let encoded = encode(el) else {
                return nil
            }
            encodedData.append(encoded)
        }

        var encoded = encodeHeader(size: UInt64(encodedData.count), smallTag: 0xC0, largeTag: 0xF7)
        encoded.append(encodedData)
        return encoded
    }

    static func encodeHeader(size: UInt64, smallTag: UInt8, largeTag: UInt8) -> Data {
        if size < 56 {
            return Data([smallTag + UInt8(size)])
        }

        let sizeData = bigEndianBinary(size)
        var encoded = Data()
        encoded.append(largeTag + UInt8(sizeData.count))
        encoded.append(contentsOf: sizeData)
        return encoded
    }

    static func bigEndianBinary(_ i: UInt64) -> Data {
        var value = i
        var bytes = withUnsafeBytes(of: &value) { Array($0) }
        for (index, byte) in bytes.enumerated().reversed() {
            if index != 0, byte == 0x00 {
                bytes.remove(at: index)
            } else {
                break
            }
        }
        return Data(bytes.reversed())
    }
}
